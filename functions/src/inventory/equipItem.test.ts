import { randomUUID } from 'crypto';
import { db } from '../common/admin';
import { fakeAuthedRequest } from '../battle/testSupport';
import { equipItemHandler } from './equipItem';

async function seedCharacterAndEquipment(uid: string): Promise<void> {
  await db.doc(`users/${uid}/characters/CHR_ACORN`).set({ equipmentId: null });
  await db.doc(`users/${uid}/characters/CHR_DROPLET`).set({ equipmentId: null });
  await db.doc(`users/${uid}/equipments/EQ_1`).set({ equipmentId: 'DEF_EQ', enhanceLevel: 0, equippedTo: null });
  await db.doc(`users/${uid}/equipments/EQ_2`).set({ equipmentId: 'DEF_EQ', enhanceLevel: 0, equippedTo: null });
}

function req(uid: string, characterId: string, equipmentInstanceId: string | null) {
  return fakeAuthedRequest(uid, { idempotencyKey: randomUUID(), appVersion: '1.0.0', dataVersion: '1', characterId, equipmentInstanceId });
}

test('equips an owned item onto an owned character, linking both directions', async () => {
  const uid = 'equip-user-1';
  await seedCharacterAndEquipment(uid);

  await equipItemHandler(req(uid, 'CHR_ACORN', 'EQ_1'));

  const character = await db.doc(`users/${uid}/characters/CHR_ACORN`).get();
  const equipment = await db.doc(`users/${uid}/equipments/EQ_1`).get();
  expect(character.data()?.equipmentId).toBe('EQ_1');
  expect(equipment.data()?.equippedTo).toBe('CHR_ACORN');
});

test('rejects equipping onto a character that is not owned', async () => {
  const uid = 'equip-user-2';
  await seedCharacterAndEquipment(uid);
  await expect(equipItemHandler(req(uid, 'CHR_NOT_OWNED', 'EQ_1'))).rejects.toThrow(/NOT_OWNED/);
});

test('rejects equipping an item that is not owned', async () => {
  const uid = 'equip-user-3';
  await seedCharacterAndEquipment(uid);
  await expect(equipItemHandler(req(uid, 'CHR_ACORN', 'EQ_NOT_OWNED'))).rejects.toThrow(/NOT_OWNED/);
});

test('re-equipping a character with a different item unequips the old item', async () => {
  const uid = 'equip-user-4';
  await seedCharacterAndEquipment(uid);
  await equipItemHandler(req(uid, 'CHR_ACORN', 'EQ_1'));

  await equipItemHandler(req(uid, 'CHR_ACORN', 'EQ_2'));

  const oldEquipment = await db.doc(`users/${uid}/equipments/EQ_1`).get();
  const newEquipment = await db.doc(`users/${uid}/equipments/EQ_2`).get();
  const character = await db.doc(`users/${uid}/characters/CHR_ACORN`).get();
  expect(oldEquipment.data()?.equippedTo).toBeNull();
  expect(newEquipment.data()?.equippedTo).toBe('CHR_ACORN');
  expect(character.data()?.equipmentId).toBe('EQ_2');
});

test('equipping an item already worn by another character displaces that character', async () => {
  const uid = 'equip-user-5';
  await seedCharacterAndEquipment(uid);
  await equipItemHandler(req(uid, 'CHR_ACORN', 'EQ_1'));

  await equipItemHandler(req(uid, 'CHR_DROPLET', 'EQ_1'));

  const acorn = await db.doc(`users/${uid}/characters/CHR_ACORN`).get();
  const droplet = await db.doc(`users/${uid}/characters/CHR_DROPLET`).get();
  expect(acorn.data()?.equipmentId).toBeNull();
  expect(droplet.data()?.equipmentId).toBe('EQ_1');
});

test('passing null unequips the character', async () => {
  const uid = 'equip-user-6';
  await seedCharacterAndEquipment(uid);
  await equipItemHandler(req(uid, 'CHR_ACORN', 'EQ_1'));

  await equipItemHandler(req(uid, 'CHR_ACORN', null));

  const character = await db.doc(`users/${uid}/characters/CHR_ACORN`).get();
  const equipment = await db.doc(`users/${uid}/equipments/EQ_1`).get();
  expect(character.data()?.equipmentId).toBeNull();
  expect(equipment.data()?.equippedTo).toBeNull();
});
