import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { withIdempotency } from '../common/idempotency';
import { AccountPatch, BaseRequest } from '../common/types';

export interface EquipItemReq extends BaseRequest {
  characterId: string;
  /** null = 장착 해제 */
  equipmentInstanceId: string | null;
}

export interface EquipItemRes {
  patch: AccountPatch;
}

/** 06_BACKEND.md §2 스키마: characters/{id}.equipmentId <-> equipments/{id}.equippedTo
 * 양방향 링크. 새 장비가 다른 캐릭터에 이미 장착돼 있었으면 그 캐릭터의
 * 링크를 해제하고, 이 캐릭터가 다른 장비를 끼고 있었으면 그 장비의 링크도
 * 해제한다 — 전부 한 트랜잭션. */
export async function equipItemHandler(request: CallableRequest<EquipItemReq>): Promise<EquipItemRes> {
  const uid = requireAuth(request);
  const { characterId, equipmentInstanceId } = request.data;

  return withIdempotency<EquipItemRes>(uid, request.data.idempotencyKey, 'equipItem', async (tx) => {
    const characterRef = db.doc(`users/${uid}/characters/${characterId}`);
    const characterSnap = await tx.get(characterRef);
    if (!characterSnap.exists) throw new HttpsError('failed-precondition', 'NOT_OWNED');

    const previousEquipmentId = (characterSnap.data()?.equipmentId as string | null) ?? null;

    const newEquipmentSnap = equipmentInstanceId
      ? await tx.get(db.doc(`users/${uid}/equipments/${equipmentInstanceId}`))
      : null;
    if (equipmentInstanceId && !newEquipmentSnap?.exists) throw new HttpsError('failed-precondition', 'NOT_OWNED');

    const previousEquipmentSnap =
      previousEquipmentId && previousEquipmentId !== equipmentInstanceId
        ? await tx.get(db.doc(`users/${uid}/equipments/${previousEquipmentId}`))
        : null;

    const displacedCharacterId = newEquipmentSnap?.data()?.equippedTo as string | null | undefined;
    const displacedCharacterSnap =
      displacedCharacterId && displacedCharacterId !== characterId
        ? await tx.get(db.doc(`users/${uid}/characters/${displacedCharacterId}`))
        : null;

    tx.update(characterRef, { equipmentId: equipmentInstanceId });
    if (equipmentInstanceId) {
      tx.update(db.doc(`users/${uid}/equipments/${equipmentInstanceId}`), { equippedTo: characterId });
    }
    if (previousEquipmentSnap?.exists) {
      tx.update(previousEquipmentSnap.ref, { equippedTo: null });
    }
    if (displacedCharacterSnap?.exists) {
      tx.update(displacedCharacterSnap.ref, { equipmentId: null });
    }

    return { result: { patch: {} } };
  });
}

export const equipItem = onCall(equipItemHandler);
