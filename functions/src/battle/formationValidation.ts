import { HttpsError } from 'firebase-functions/v2/https';
import { db } from '../common/admin';

export interface RawFormationSlot {
  characterId: string | null;
  equipmentInstanceId: string | null;
}

/** account/bootstrapAccount.ts가 만드는 프리셋 개수·슬롯 수와 반드시
 * 일치해야 한다. */
export const FORMATION_PRESET_COUNT = 3;
export const FORMATION_SLOT_COUNT = 10;

/**
 * 06_BACKEND.md §4.3 3단계 소유 검증 -- `startBattle`(저장된 프리셋을
 * 읽어서 검증)과 `saveFormation`(클라가 방금 보낸 걸 저장하기 전에 검증)
 * 둘 다 이 함수 하나를 쓴다. 캐릭터/장비 소유 여부, 슬롯 중복만 확인하고
 * 슬롯 수·프리셋 인덱스 범위 확인은 호출부(둘이 사전조건이 다르다)가
 * 한다.
 */
export async function validateFormationOwnership(uid: string, slots: RawFormationSlot[]): Promise<void> {
  const seenCharacters = new Set<string>();

  for (const slot of slots) {
    if (!slot.characterId) continue;
    if (seenCharacters.has(slot.characterId)) throw new HttpsError('failed-precondition', 'VALIDATION_FAILED');
    seenCharacters.add(slot.characterId);

    const characterDoc = await db.doc(`users/${uid}/characters/${slot.characterId}`).get();
    if (!characterDoc.exists) throw new HttpsError('failed-precondition', 'NOT_OWNED');

    if (slot.equipmentInstanceId) {
      const equipmentDoc = await db.doc(`users/${uid}/equipments/${slot.equipmentInstanceId}`).get();
      if (!equipmentDoc.exists || equipmentDoc.data()?.equippedTo !== slot.characterId) {
        throw new HttpsError('failed-precondition', 'NOT_OWNED');
      }
    }
  }
}
