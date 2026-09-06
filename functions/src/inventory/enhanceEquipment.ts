import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { admin, db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { withIdempotency } from '../common/idempotency';
import { AccountPatch, BaseRequest } from '../common/types';

export interface EnhanceEquipmentReq extends BaseRequest {
  equipmentInstanceId: string;
}

export interface EnhanceEquipmentRes {
  newEnhanceLevel: number;
  goldSpent: number;
  patch: AccountPatch;
}

/** 장비 강화 비용 실제 밸런스 데이터는 아직 없다(태그 부여까지 포함한 진짜
 * 강화 시스템은 07_DUNGEON_EXCHANGE.md의 T-44 스코프). 여기서는 골드 차감
 * +레벨 증가가 한 트랜잭션으로 커밋되는 배관만 맞춘다 — 선형 placeholder. */
function enhanceCost(currentLevel: number): number {
  return 100 * (currentLevel + 1);
}

export async function enhanceEquipmentHandler(request: CallableRequest<EnhanceEquipmentReq>): Promise<EnhanceEquipmentRes> {
  const uid = requireAuth(request);
  const { equipmentInstanceId } = request.data;

  return withIdempotency<EnhanceEquipmentRes>(uid, request.data.idempotencyKey, 'enhanceEquipment', async (tx) => {
    const equipmentRef = db.doc(`users/${uid}/equipments/${equipmentInstanceId}`);
    const userRef = db.doc(`users/${uid}`);
    const [equipmentSnap, userSnap] = await Promise.all([tx.get(equipmentRef), tx.get(userRef)]);
    if (!equipmentSnap.exists) throw new HttpsError('failed-precondition', 'NOT_OWNED');

    const currentLevel = (equipmentSnap.data()?.enhanceLevel as number) ?? 0;
    const gold = (userSnap.data()?.currency?.gold as number) ?? 0;
    const cost = enhanceCost(currentLevel);
    if (gold < cost) throw new HttpsError('failed-precondition', 'NOT_ENOUGH_CURRENCY');

    const newEnhanceLevel = currentLevel + 1;
    tx.update(equipmentRef, { enhanceLevel: newEnhanceLevel });
    tx.update(userRef, { 'currency.gold': admin.firestore.FieldValue.increment(-cost) });

    return {
      result: { newEnhanceLevel, goldSpent: cost, patch: { currency: { gold: gold - cost } } },
    };
  });
}

export const enhanceEquipment = onCall(enhanceEquipmentHandler);
