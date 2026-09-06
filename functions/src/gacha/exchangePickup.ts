import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { admin, db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { withIdempotency } from '../common/idempotency';
import { applyReward } from '../common/rewards';
import { BaseRequest } from '../common/types';
import { BANNERS_BY_ID, GACHA_EXCHANGE } from './bannerData';

export interface ExchangePickupReq extends BaseRequest {
  bannerId: string;
  characterId: string;
}

export interface ExchangePickupRes {
  characterId: string;
  convertedFragments?: number;
  exchangePointAfter: number;
}

/** 06_BACKEND.md §4.7 연장, banners.json `exchange`(요구 포인트 200, 이월).
 * 09_MILESTONES.md T-49 완료조건: "200 차감, 초과분 유지, 중간 픽업 획득 시
 * 초기화 없음" -- 전액이 아니라 정확히 requiredPoints만 빼서 200 넘는
 * 잔여분은 그대로 이월된다. */
export async function exchangePickupHandler(request: CallableRequest<ExchangePickupReq>): Promise<ExchangePickupRes> {
  const uid = requireAuth(request);
  const { bannerId, characterId } = request.data;

  const banner = BANNERS_BY_ID[bannerId];
  if (!banner) throw new HttpsError('not-found', 'VALIDATION_FAILED');
  if (!banner.exchangeTargets.includes(characterId)) throw new HttpsError('invalid-argument', 'VALIDATION_FAILED');

  const rateEntry = banner.rates.find((r) => r.pool.includes(characterId));
  if (!rateEntry) throw new HttpsError('invalid-argument', 'VALIDATION_FAILED');

  return withIdempotency<ExchangePickupRes>(uid, request.data.idempotencyKey, 'exchangePickup', async (tx) => {
    const userRef = db.doc(`users/${uid}`);
    const characterRef = db.doc(`users/${uid}/characters/${characterId}`);
    const [userSnap, characterSnap] = await Promise.all([tx.get(userRef), tx.get(characterRef)]);

    const held = (userSnap.data()?.currency?.exchangePoint as number) ?? 0;
    if (held < GACHA_EXCHANGE.requiredPoints) throw new HttpsError('failed-precondition', 'NOT_ENOUGH_CURRENCY');

    applyReward(tx, uid, { item: 'ITM_EXCHANGE_POINT', amount: -GACHA_EXCHANGE.requiredPoints });

    let convertedFragments: number | undefined;
    if (characterSnap.exists) {
      const key = `rarity${rateEntry.rarity}` as 'rarity3' | 'rarity2' | 'rarity1';
      convertedFragments = banner.duplicateConversion[key] ?? 0;
      tx.update(characterRef, { dupCount: admin.firestore.FieldValue.increment(1) });
      if (convertedFragments > 0) {
        applyReward(tx, uid, { item: banner.duplicateConversion.item, amount: convertedFragments });
      }
    } else {
      tx.set(characterRef, {
        obtainedAt: admin.firestore.FieldValue.serverTimestamp(),
        affinity: 0,
        skinId: null,
        equipmentId: null,
        dupCount: 0,
      });
    }

    const exchangePointAfter = held - GACHA_EXCHANGE.requiredPoints;
    return {
      result:
        convertedFragments === undefined
          ? { characterId, exchangePointAfter }
          : { characterId, convertedFragments, exchangePointAfter },
    };
  });
}

export const exchangePickup = onCall(exchangePickupHandler);
