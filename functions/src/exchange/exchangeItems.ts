import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { admin, db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { withIdempotency } from '../common/idempotency';
import { applyReward } from '../common/rewards';
import { AccountPatch, BaseRequest, Delta } from '../common/types';
import { gameDateKey, gameWeekKey, nextGameDayResetMs } from '../schedule/gameDay';
import { CURRENCY_ITEM_FIELD } from '../common/currency';
import { ENTRIES_BY_ID, ExchangeEntry } from './exchangeData';

export interface ExchangeItemsReq extends BaseRequest {
  entryId: string;
  /** 승급/조각 교환처럼 한 번에 여러 번 처리할 때. 기본 1. */
  times?: number;
}

export interface ExchangeItemsRes {
  granted: Delta[];
  patch: AccountPatch;
}

/** 'perEntry'면 그 문서를 여러 entry가 공유하므로 `exchangeUsed.{entryId}`
 * 아래에 중첩해서 저장하고(dailyCounters/weeklyCounters), 'dedicated'면
 * 문서 자체가 이 entry 전용이라 최상위 `usedCount`에 바로 둔다
 * (exchangeCounters/{entryId}).
 *
 * 주의: Firestore Admin SDK에서 점(.)이 든 문자열 키를 `set(..., {merge:
 * true})`에 그대로 넘기면 중첩 경로가 아니라 "그 점까지 포함한 리터럴
 * 필드명"으로 저장된다(점 표기 단축은 `update()`에서만 동작) — 그래서
 * 여기서는 항상 진짜 중첩 객체를 만들어 쓴다. */
interface UsageCounter {
  ref: FirebaseFirestore.DocumentReference;
  kind: 'perEntry' | 'dedicated';
  expireAt?: number;
}

/** limit>0인 항목만 사용 횟수를 추적한다 — 무제한(limit=0)은 카운터 자체가 필요 없다. */
function usageCounterOf(uid: string, entry: ExchangeEntry, now: Date): UsageCounter | null {
  if (entry.limit <= 0) return null;
  switch (entry.resetPeriod) {
    case 'DAILY':
      return {
        ref: db.doc(`users/${uid}/dailyCounters/${gameDateKey(now)}`),
        kind: 'perEntry',
        expireAt: nextGameDayResetMs(now),
      };
    case 'WEEKLY':
      return { ref: db.doc(`users/${uid}/weeklyCounters/${gameWeekKey(now)}`), kind: 'perEntry' };
    default: // NONE | EVENT: 평생 한도
      return { ref: db.doc(`users/${uid}/exchangeCounters/${entry.id}`), kind: 'dedicated' };
  }
}

function readUsage(data: FirebaseFirestore.DocumentData | undefined, counter: UsageCounter, entryId: string): number {
  if (!data) return 0;
  const raw = counter.kind === 'dedicated' ? data.usedCount : (data.exchangeUsed ?? {})[entryId];
  return typeof raw === 'number' ? raw : 0;
}

/** 06_BACKEND.md §4.6: 클라이언트가 보낸 cost/gain을 신뢰하지 않고 서버
 * 사본(exchangeData.ts)에서 entry를 조회해 처리한다. */
export async function exchangeItemsHandler(request: CallableRequest<ExchangeItemsReq>): Promise<ExchangeItemsRes> {
  const uid = requireAuth(request);
  const { entryId } = request.data;
  const times = request.data.times ?? 1;
  if (!Number.isInteger(times) || times < 1) throw new HttpsError('invalid-argument', 'VALIDATION_FAILED');

  const entry = ENTRIES_BY_ID[entryId];
  if (!entry) throw new HttpsError('not-found', 'VALIDATION_FAILED');

  return withIdempotency<ExchangeItemsRes>(uid, request.data.idempotencyKey, 'exchangeItems', async (tx) => {
    const now = new Date();
    const userRef = db.doc(`users/${uid}`);
    const counter = usageCounterOf(uid, entry, now);

    const nonCurrencyCostItems = entry.cost.filter((c) => !CURRENCY_ITEM_FIELD[c.item]);
    const [userSnap, counterSnap, costItemSnaps] = await Promise.all([
      tx.get(userRef),
      counter ? tx.get(counter.ref) : Promise.resolve(undefined),
      Promise.all(nonCurrencyCostItems.map((c) => tx.get(db.doc(`users/${uid}/items/${c.item}`)))),
    ]);

    if (counter) {
      const used = readUsage(counterSnap?.data(), counter, entry.id);
      if (used + times > entry.limit) {
        throw new HttpsError('resource-exhausted', 'DAILY_LIMIT_REACHED');
      }
    }

    const heldAmount = (item: string): number => {
      const currencyField = CURRENCY_ITEM_FIELD[item];
      if (currencyField) return (userSnap.data()?.currency?.[currencyField] as number) ?? 0;
      const idx = nonCurrencyCostItems.findIndex((c) => c.item === item);
      return (costItemSnaps[idx]?.data()?.amount as number) ?? 0;
    };

    for (const c of entry.cost) {
      if (heldAmount(c.item) < c.amount * times) {
        throw new HttpsError('failed-precondition', 'NOT_ENOUGH_CURRENCY');
      }
    }

    for (const c of entry.cost) {
      applyReward(tx, uid, { item: c.item, amount: -c.amount * times });
    }

    const granted: Delta[] = [];
    if (entry.gain.type === 'EQUIPMENT') {
      for (let i = 0; i < times; i++) {
        tx.set(db.collection(`users/${uid}/equipments`).doc(), {
          equipmentId: entry.gain.id,
          enhanceLevel: 0,
          equippedTo: null,
          obtainedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      granted.push({ item: entry.gain.id, amount: times });
    } else {
      const reward: Delta = { item: entry.gain.id, amount: entry.gain.amount * times };
      applyReward(tx, uid, reward);
      granted.push(reward);
    }

    if (counter) {
      const used = readUsage(counterSnap?.data(), counter, entry.id);
      // `set({merge:true})`로 중첩 맵 필드 하나만 콕 집어 갱신하면(예:
      // `{exchangeUsed: {[entryId]: n}}`) 그 필드 전체가 그 값으로
      // 대체돼서 같은 문서에 얹혀 있는 다른 entry의 카운트가 지워진다
      // (T-31에서 실제로 겪은 문제와 같음) — 기존 맵을 통째로 읽어와
      // 펼친 뒤 한 키만 바꿔서 다시 통째로 쓴다.
      const update: Record<string, unknown> =
        counter.kind === 'dedicated'
          ? { usedCount: used + times }
          : { exchangeUsed: { ...((counterSnap?.data()?.exchangeUsed as Record<string, number>) ?? {}), [entry.id]: used + times } };
      if (counter.expireAt !== undefined) update.expireAt = counter.expireAt;
      tx.set(counter.ref, update, { merge: true });
    }

    const patch: AccountPatch =
      entry.gain.type === 'CURRENCY' && CURRENCY_ITEM_FIELD[entry.gain.id]
        ? { currency: { [CURRENCY_ITEM_FIELD[entry.gain.id]]: entry.gain.amount * times } }
        : {};

    return { result: { granted, patch } };
  });
}

export const exchangeItems = onCall(exchangeItemsHandler);
