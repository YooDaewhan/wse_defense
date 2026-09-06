import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { applyReward } from '../common/rewards';
import { withIdempotency } from '../common/idempotency';
import { bumpMissionProgress } from '../mission/missionProgress';
import { AccountPatch, BaseRequest } from '../common/types';
import { EQUIPMENT_BY_ID } from '../exchange/equipmentData';

export interface EnhanceEquipmentReq extends BaseRequest {
  equipmentInstanceId: string;
}

export interface EnhanceEquipmentRes {
  newEnhanceLevel: number;
  patch: AccountPatch;
}

export const MAX_ENHANCE_LEVEL = 10;

/** 07_DUNGEON_EXCHANGE.md §6.3: "+1~+5: T1 조각×(3+level×2)+골드 /
 * +6~+10: T2 조각×(2+level)+골드". `level`은 이번에 도달하는 목표
 * 레벨(1-based) — 문서가 currentLevel/targetLevel 중 뭘 뜻하는지 명시하지
 * 않아 이렇게 해석했다. 골드 수치 자체는 문서에 없어 T-39 placeholder를
 * 그대로 이어간다(주석 명시).
 */
function shardCostFor(currentLevel: number): { tier: 'T1' | 'T2'; amount: number } {
  const target = currentLevel + 1;
  return target <= 5 ? { tier: 'T1', amount: 3 + target * 2 } : { tier: 'T2', amount: 2 + target };
}

function goldCostFor(currentLevel: number): number {
  return 100 * (currentLevel + 1);
}

/** 09_MILESTONES.md T-44: "+10까지 강화, 실패 없음". 자원이 충분하면 항상
 * 성공한다 — 실패 확률 롤 자체가 없다(기획서 유지). */
export async function enhanceEquipmentHandler(request: CallableRequest<EnhanceEquipmentReq>): Promise<EnhanceEquipmentRes> {
  const uid = requireAuth(request);
  const { equipmentInstanceId } = request.data;
  // withIdempotency의 재시도(멱등키 재사용) 호출은 아래 콜백을 다시 안
  // 부르니 이 값도 그대로 false로 남아 미션 진행도가 두 번 안 올라간다.
  let enhancedThisCall = false;

  const res = await withIdempotency<EnhanceEquipmentRes>(uid, request.data.idempotencyKey, 'enhanceEquipment', async (tx) => {
    const equipmentRef = db.doc(`users/${uid}/equipments/${equipmentInstanceId}`);
    const userRef = db.doc(`users/${uid}`);
    const [equipmentSnap, userSnap] = await Promise.all([tx.get(equipmentRef), tx.get(userRef)]);
    if (!equipmentSnap.exists) throw new HttpsError('failed-precondition', 'NOT_OWNED');

    const currentLevel = (equipmentSnap.data()?.enhanceLevel as number) ?? 0;
    if (currentLevel >= MAX_ENHANCE_LEVEL) throw new HttpsError('failed-precondition', 'VALIDATION_FAILED');

    const equipmentCatalogId = equipmentSnap.data()?.equipmentId as string;
    const meta = EQUIPMENT_BY_ID[equipmentCatalogId];
    if (!meta) throw new HttpsError('failed-precondition', 'VALIDATION_FAILED');

    const shardCost = shardCostFor(currentLevel);
    const shardItemId = `ITM_SHARD_${meta.shardFamily}_${shardCost.tier}`;
    const shardRef = db.doc(`users/${uid}/items/${shardItemId}`);
    const shardSnap = await tx.get(shardRef);

    const gold = (userSnap.data()?.currency?.gold as number) ?? 0;
    const goldCost = goldCostFor(currentLevel);
    const shardHeld = (shardSnap.data()?.amount as number) ?? 0;
    if (gold < goldCost || shardHeld < shardCost.amount) {
      throw new HttpsError('failed-precondition', 'NOT_ENOUGH_CURRENCY');
    }

    const newEnhanceLevel = currentLevel + 1;
    tx.update(equipmentRef, { enhanceLevel: newEnhanceLevel });
    applyReward(tx, uid, { item: 'ITM_GOLD', amount: -goldCost });
    applyReward(tx, uid, { item: shardItemId, amount: -shardCost.amount });
    enhancedThisCall = true;

    return {
      result: { newEnhanceLevel, patch: { currency: { gold: gold - goldCost } } },
    };
  });

  if (enhancedThisCall) await bumpMissionProgress(uid, 'ENHANCE_EQUIPMENT'); // T-54 MSN_GROWTH 대체 조건
  return res;
}

export const enhanceEquipment = onCall(enhanceEquipmentHandler);
