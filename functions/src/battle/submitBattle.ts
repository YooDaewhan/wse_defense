import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { admin, db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { withIdempotency } from '../common/idempotency';
import { AccountPatch } from '../common/types';
import { CHARACTER_RESUMMON_COOLDOWN_SEC } from './characterData';
import { TICKS_PER_SEC } from './constants';
import { decodeInputLog } from './inputLog';
import { BattleDoc, StageMeta, SubmitBattleReq, SubmitBattleRes } from './types';
import {
  isOutlierResult,
  validateV10FormationOnlySummons,
  validateV12Checksum,
  validateV3Outcome,
  validateV4MinClearTime,
  validateV5MaxClearTime,
  validateV6PrayerBudget,
  validateV7SummonCadence,
  validateV8UltimateBudget,
  validateV9KillCount,
} from './validators';

interface InternalResult {
  accepted: boolean;
  /** V0~V13 중 어느 항목에서 반려됐는지 — 원장/로그 전용, 클라이언트에는 절대
   * 노출하지 않는다(06_BACKEND.md §4.4 "어떤 검증에 걸렸는지 노출 금지"). */
  rejectedAt?: string;
  rewards: Array<{ item: string; amount: number }>;
  firstClear: boolean;
  patch: AccountPatch;
}

/** V0~V12 순서대로 검사하고, 첫 실패 지점을 반환한다(순수 함수 — 이미 읽어온
 * battle/meta/req만 본다). null이면 전부 통과. */
function findFirstFailedValidation(battle: BattleDoc, meta: StageMeta, req: SubmitBattleReq, now: number): string | null {
  if (battle.state !== 'issued' || now >= battle.expireAt) return 'V0';
  if (req.formationHash !== battle.formationHash) return 'V1';
  if (req.dataVersion !== battle.dataVersion) return 'V2';
  if (!validateV3Outcome(req.outcome)) return 'V3';
  if (!validateV4MinClearTime(req.summary.endTick, meta)) return 'V4';
  if (!validateV5MaxClearTime(req.summary.endTick, meta)) return 'V5';
  if (!validateV6PrayerBudget(req.summary, meta)) return 'V6';

  let decodedInputs;
  try {
    decodedInputs = decodeInputLog(req.inputLog, req.summary.endTick).inputs;
  } catch {
    return 'V11';
  }

  if (!validateV7SummonCadence(decodedInputs, req.summary.totalSummons, battle.formationSnapshot, CHARACTER_RESUMMON_COOLDOWN_SEC)) {
    return 'V7';
  }
  if (!validateV8UltimateBudget(req.summary)) return 'V8';
  if (!validateV9KillCount(req.summary, meta)) return 'V9';
  if (!validateV10FormationOnlySummons(decodedInputs, battle.formationSnapshot)) return 'V10';
  if (!validateV12Checksum(req.inputLog, battle.seed, req.formationHash, req.summary.checksum)) return 'V12';
  return null;
}

export async function submitBattleHandler(request: CallableRequest<SubmitBattleReq>): Promise<SubmitBattleRes> {
  const uid = requireAuth(request);
  const req = request.data;

  const internal = await withIdempotency<InternalResult>(uid, req.idempotencyKey, 'submitBattle', async (tx) => {
    const battleRef = db.doc(`users/${uid}/battles/${req.battleId}`);
    const userRef = db.doc(`users/${uid}`);

    // Firestore 트랜잭션은 모든 read가 write보다 먼저 끝나야 하므로 필요한
    // 문서를 전부 먼저 읽는다.
    const battleSnap = await tx.get(battleRef);
    if (!battleSnap.exists) {
      return { result: { accepted: false, rejectedAt: 'V0', rewards: [], firstClear: false, patch: {} } };
    }
    const battle = battleSnap.data() as BattleDoc;
    const [metaSnap, userSnap] = await Promise.all([tx.get(db.doc(`stagesMeta/${battle.stageId}`)), tx.get(userRef)]);
    const meta = metaSnap.data() as StageMeta;

    const failedAt = findFirstFailedValidation(battle, meta, req, Date.now());
    if (failedAt !== null) {
      tx.update(battleRef, { state: 'submitted', result: { accepted: false, reason: failedAt } });
      return { result: { accepted: false, rejectedAt: failedAt, rewards: [], firstClear: false, patch: {} } };
    }

    if (isOutlierResult(req.summary, meta)) {
      tx.set(
        db.doc(`antiCheat/${uid}`),
        {
          flags: admin.firestore.FieldValue.increment(1),
          lastFlagAt: admin.firestore.FieldValue.serverTimestamp(),
          samples: admin.firestore.FieldValue.arrayUnion({ battleId: req.battleId, reason: 'outlier', at: Date.now() }),
        },
        { merge: true },
      );
    }

    const clearedStages = (userSnap.data()?.progress?.clearedStages ?? {}) as Record<string, { bestClearSec: number }>;
    const firstClear = req.outcome === 'ALLY_WIN' && !clearedStages[battle.stageId];
    const rewards = req.outcome === 'ALLY_WIN' ? (firstClear ? meta.firstRewards : meta.repeatRewards) : [];

    if (req.outcome === 'ALLY_WIN') {
      const clearSec = req.summary.endTick / TICKS_PER_SEC;
      const prevBest = clearedStages[battle.stageId]?.bestClearSec;
      tx.update(userRef, {
        [`progress.clearedStages.${battle.stageId}`]: {
          stars: 1,
          bestClearSec: prevBest === undefined ? clearSec : Math.min(prevBest, clearSec),
        },
      });
      for (const r of rewards) {
        tx.update(userRef, { [`currency.${r.item}`]: admin.firestore.FieldValue.increment(r.amount) });
      }
    }

    tx.update(battleRef, {
      state: 'submitted',
      result: { accepted: true, outcome: req.outcome, rewards, firstClear },
    });

    const patch: AccountPatch = { currency: Object.fromEntries(rewards.map((r) => [r.item, r.amount])) };
    return { result: { accepted: true, rewards, firstClear, patch } };
  });

  if (!internal.accepted) {
    throw new HttpsError('failed-precondition', 'VALIDATION_FAILED');
  }
  return { accepted: true, rewards: internal.rewards, firstClear: internal.firstClear, patch: internal.patch };
}

export const submitBattle = onCall(submitBattleHandler);
