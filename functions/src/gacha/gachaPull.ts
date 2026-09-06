import { randomInt } from 'crypto';
import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { admin, db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { CURRENCY_ITEM_FIELD } from '../common/currency';
import { withIdempotency } from '../common/idempotency';
import { applyReward } from '../common/rewards';
import { BaseRequest } from '../common/types';
import { BANNERS_BY_ID, GACHA_EXCHANGE, GACHA_RATES_VERSION } from './bannerData';
import { rollMany } from './gachaRoll';

export interface GachaPullReq extends BaseRequest {
  bannerId: string;
  count: 1 | 10;
}

export interface GachaPullResultItem {
  characterId: string;
  rarity: number;
  isNew: boolean;
  convertedFragments?: number;
}

export interface GachaPullRes {
  results: GachaPullResultItem[];
  exchangePointAfter: number;
  ratesVersion: string;
}

function rand(): number {
  return randomInt(1_000_000) / 1_000_000;
}

/** 06_BACKEND.md §4.7. */
export async function gachaPullHandler(request: CallableRequest<GachaPullReq>): Promise<GachaPullRes> {
  const uid = requireAuth(request);
  const { bannerId, count } = request.data;
  if (count !== 1 && count !== 10) throw new HttpsError('invalid-argument', 'VALIDATION_FAILED');

  const banner = BANNERS_BY_ID[bannerId];
  if (!banner) throw new HttpsError('not-found', 'VALIDATION_FAILED');

  const now = Date.now();
  if (banner.startAtUtc && now < Date.parse(banner.startAtUtc)) throw new HttpsError('failed-precondition', 'BANNER_CLOSED');
  if (banner.endAtUtc && now > Date.parse(banner.endAtUtc)) throw new HttpsError('failed-precondition', 'BANNER_CLOSED');

  const costEntry = count === 1 ? banner.cost.single : banner.cost.ten;

  return withIdempotency<GachaPullRes>(uid, request.data.idempotencyKey, 'gachaPull', async (tx) => {
    const userRef = db.doc(`users/${uid}`);
    const costIsCurrency = !!CURRENCY_ITEM_FIELD[costEntry.item];
    const costItemRef = costIsCurrency ? null : db.doc(`users/${uid}/items/${costEntry.item}`);

    const [userSnap, costItemSnap] = await Promise.all([
      tx.get(userRef),
      costItemRef ? tx.get(costItemRef) : Promise.resolve(undefined),
    ]);

    const heldCost = costIsCurrency
      ? ((userSnap.data()?.currency?.[CURRENCY_ITEM_FIELD[costEntry.item]] as number) ?? 0)
      : ((costItemSnap?.data()?.amount as number) ?? 0);
    if (heldCost < costEntry.amount) throw new HttpsError('failed-precondition', 'NOT_ENOUGH_CURRENCY');

    const rolls = rollMany(banner.rates, count, rand);

    // 이 배치 안에서 같은 캐릭터가 여러 번 나올 수 있다 -- 첫 등장만
    // "신규"일 수 있으므로 실제 보유 여부를 미리 다 읽어와서(read는 전부
    // write보다 먼저) 처리 중엔 로컬 Set으로만 추적한다.
    const uniqueIds = [...new Set(rolls.map((r) => r.characterId))];
    const ownershipSnaps = await Promise.all(uniqueIds.map((id) => tx.get(db.doc(`users/${uid}/characters/${id}`))));
    const alreadyOwned = new Set(uniqueIds.filter((_, i) => ownershipSnaps[i].exists));

    // ---- 여기부터 write만 ----
    applyReward(tx, uid, { item: costEntry.item, amount: -costEntry.amount });

    const grantedThisBatch = new Set<string>();
    const results: GachaPullResultItem[] = [];
    let totalFragments = 0;
    const fragmentItem = banner.duplicateConversion.item;

    for (const roll of rolls) {
      const isNew = !alreadyOwned.has(roll.characterId) && !grantedThisBatch.has(roll.characterId);
      const characterRef = db.doc(`users/${uid}/characters/${roll.characterId}`);
      if (isNew) {
        grantedThisBatch.add(roll.characterId);
        tx.set(characterRef, {
          obtainedAt: admin.firestore.FieldValue.serverTimestamp(),
          affinity: 0,
          skinId: null,
          equipmentId: null,
          dupCount: 0,
        });
        results.push({ characterId: roll.characterId, rarity: roll.rarity, isNew: true });
      } else {
        const key = `rarity${roll.rarity}` as 'rarity3' | 'rarity2' | 'rarity1';
        const fragments = banner.duplicateConversion[key] ?? 0;
        totalFragments += fragments;
        tx.update(characterRef, { dupCount: admin.firestore.FieldValue.increment(1) });
        results.push({ characterId: roll.characterId, rarity: roll.rarity, isNew: false, convertedFragments: fragments });
      }
    }

    if (totalFragments > 0) {
      applyReward(tx, uid, { item: fragmentItem, amount: totalFragments });
    }

    let exchangePointAfter = (userSnap.data()?.currency?.exchangePoint as number) ?? 0;
    if (banner.givesExchangePoint) {
      const gained = GACHA_EXCHANGE.pointPerPull * count;
      applyReward(tx, uid, { item: 'ITM_EXCHANGE_POINT', amount: gained });
      exchangePointAfter += gained;
    }

    return { result: { results, exchangePointAfter, ratesVersion: GACHA_RATES_VERSION } };
  });
}

export const gachaPull = onCall(gachaPullHandler);
