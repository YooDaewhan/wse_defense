import { randomUUID } from 'crypto';
import { db } from '../common/admin';
import { fakeAuthedRequest } from './testSupport';
import { FORMATION_SLOT_COUNT, RawFormationSlot } from './formationValidation';
import { saveFormationHandler } from './saveFormation';

function emptySlots(): RawFormationSlot[] {
  return Array.from({ length: FORMATION_SLOT_COUNT }, () => ({ characterId: null, equipmentInstanceId: null }));
}

function req(uid: string, presetIndex: number, slots: RawFormationSlot[]) {
  return fakeAuthedRequest(uid, { idempotencyKey: randomUUID(), appVersion: '1.0.0', dataVersion: '1', presetIndex, slots });
}

/** 10_WIRING_PLAN.md "편성 서버 동기화": FormationScreen(로컬 Hive)이
 * 실제로 startBattle이 읽는 users/{uid}/formations/{presetIndex}에
 * 반영되게 한다. */
test('saves owned characters into the given preset slot', async () => {
  const uid = 'saveformation-user-1';
  await db.doc(`users/${uid}/characters/CHR_ACORN`).set({ dupCount: 0 });
  const slots = emptySlots();
  slots[0] = { characterId: 'CHR_ACORN', equipmentInstanceId: null };

  const res = await saveFormationHandler(req(uid, 1, slots));

  expect(res.presetIndex).toBe(1);
  const doc = await db.doc(`users/${uid}/formations/1`).get();
  expect(doc.data()?.slots[0].characterId).toBe('CHR_ACORN');
});

test('rejects a slot referencing a character the account does not own, and saves nothing', async () => {
  const uid = 'saveformation-user-2';
  const slots = emptySlots();
  slots[0] = { characterId: 'CHR_NOT_OWNED', equipmentInstanceId: null };

  await expect(saveFormationHandler(req(uid, 0, slots))).rejects.toThrow(/NOT_OWNED/);

  const doc = await db.doc(`users/${uid}/formations/0`).get();
  expect(doc.exists).toBe(false);
});

test('rejects the same character appearing in two slots', async () => {
  const uid = 'saveformation-user-3';
  await db.doc(`users/${uid}/characters/CHR_ACORN`).set({ dupCount: 0 });
  const slots = emptySlots();
  slots[0] = { characterId: 'CHR_ACORN', equipmentInstanceId: null };
  slots[1] = { characterId: 'CHR_ACORN', equipmentInstanceId: null };

  await expect(saveFormationHandler(req(uid, 0, slots))).rejects.toThrow(/VALIDATION_FAILED/);
});

test('rejects an equipment instance not equipped to that exact character', async () => {
  const uid = 'saveformation-user-4';
  await db.doc(`users/${uid}/characters/CHR_ACORN`).set({ dupCount: 0 });
  await db.doc(`users/${uid}/equipments/EQ_1`).set({ equipmentId: 'EQP_X', enhanceLevel: 0, equippedTo: 'CHR_DROPLET' });
  const slots = emptySlots();
  slots[0] = { characterId: 'CHR_ACORN', equipmentInstanceId: 'EQ_1' };

  await expect(saveFormationHandler(req(uid, 0, slots))).rejects.toThrow(/NOT_OWNED/);
});

test('rejects a preset index outside 0..2', async () => {
  const uid = 'saveformation-user-5';
  await expect(saveFormationHandler(req(uid, 3, emptySlots()))).rejects.toThrow(/VALIDATION_FAILED/);
});

test('rejects a slots array with the wrong length', async () => {
  const uid = 'saveformation-user-6';
  await expect(saveFormationHandler(req(uid, 0, emptySlots().slice(0, 5)))).rejects.toThrow(/VALIDATION_FAILED/);
});

test('idempotent: retrying with the same idempotencyKey does not error, and the saved slots are unchanged', async () => {
  const uid = 'saveformation-user-7';
  await db.doc(`users/${uid}/characters/CHR_ACORN`).set({ dupCount: 0 });
  const slots = emptySlots();
  slots[0] = { characterId: 'CHR_ACORN', equipmentInstanceId: null };
  const request = req(uid, 0, slots);

  const first = await saveFormationHandler(request);
  const second = await saveFormationHandler(request);

  expect(second).toEqual(first);
  const doc = await db.doc(`users/${uid}/formations/0`).get();
  expect(doc.data()?.slots[0].characterId).toBe('CHR_ACORN');
});
