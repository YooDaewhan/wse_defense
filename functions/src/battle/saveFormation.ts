import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { admin, db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { withIdempotency } from '../common/idempotency';
import { BaseRequest } from '../common/types';
import { FORMATION_PRESET_COUNT, FORMATION_SLOT_COUNT, RawFormationSlot, validateFormationOwnership } from './formationValidation';

export interface SaveFormationReq extends BaseRequest {
  presetIndex: number;
  slots: RawFormationSlot[];
}

export interface SaveFormationRes {
  presetIndex: number;
}

/**
 * 06_BACKEND.md §2 `users/{uid}/formations/{presetIndex}`. 10_WIRING_PLAN.md
 * "편성 서버 동기화" 격차를 메운다 -- FormationScreen(T-57)은 지금까지
 * 로컬 Hive에만 저장했고, `startBattle`이 실제로 읽는 이 문서는
 * `bootstrapAccount`가 만든 빈 슬롯 그대로 남아 있어서 실제 출격이
 * 전부 NOT_OWNED로 막혔다.
 */
export async function saveFormationHandler(request: CallableRequest<SaveFormationReq>): Promise<SaveFormationRes> {
  const uid = requireAuth(request);
  const { presetIndex, slots } = request.data;

  if (!Number.isInteger(presetIndex) || presetIndex < 0 || presetIndex >= FORMATION_PRESET_COUNT) {
    throw new HttpsError('invalid-argument', 'VALIDATION_FAILED');
  }
  if (!Array.isArray(slots) || slots.length !== FORMATION_SLOT_COUNT) {
    throw new HttpsError('invalid-argument', 'VALIDATION_FAILED');
  }

  await validateFormationOwnership(uid, slots);

  return withIdempotency<SaveFormationRes>(uid, request.data.idempotencyKey, 'saveFormation', async (tx) => {
    tx.set(db.doc(`users/${uid}/formations/${presetIndex}`), {
      slots,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { result: { presetIndex } };
  });
}

export const saveFormation = onCall(saveFormationHandler);
