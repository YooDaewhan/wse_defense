import { randomUUID } from 'crypto';
import { db } from '../common/admin';
import { fakeAuthedRequest } from '../battle/testSupport';
import { enhanceEquipmentHandler } from './enhanceEquipment';

function req(uid: string, equipmentInstanceId: string) {
  return fakeAuthedRequest(uid, { idempotencyKey: randomUUID(), appVersion: '1.0.0', dataVersion: '1', equipmentInstanceId });
}

test('deducts gold and increments enhanceLevel in one transaction', async () => {
  const uid = 'enhance-user-1';
  await db.doc(`users/${uid}`).set({ currency: { gold: 200 } });
  await db.doc(`users/${uid}/equipments/EQ_1`).set({ equipmentId: 'DEF_EQ', enhanceLevel: 0, equippedTo: null });

  const res = await enhanceEquipmentHandler(req(uid, 'EQ_1'));

  expect(res.newEnhanceLevel).toBe(1);
  expect(res.goldSpent).toBe(100);
  const equipment = await db.doc(`users/${uid}/equipments/EQ_1`).get();
  const account = await db.doc(`users/${uid}`).get();
  expect(equipment.data()?.enhanceLevel).toBe(1);
  expect(account.data()?.currency.gold).toBe(100);
});

test('rejects when gold is not enough, and changes nothing', async () => {
  const uid = 'enhance-user-2';
  await db.doc(`users/${uid}`).set({ currency: { gold: 50 } });
  await db.doc(`users/${uid}/equipments/EQ_1`).set({ equipmentId: 'DEF_EQ', enhanceLevel: 0, equippedTo: null });

  await expect(enhanceEquipmentHandler(req(uid, 'EQ_1'))).rejects.toThrow(/NOT_ENOUGH_CURRENCY/);

  const equipment = await db.doc(`users/${uid}/equipments/EQ_1`).get();
  const account = await db.doc(`users/${uid}`).get();
  expect(equipment.data()?.enhanceLevel).toBe(0);
  expect(account.data()?.currency.gold).toBe(50);
});

test('rejects enhancing an item that is not owned', async () => {
  const uid = 'enhance-user-3';
  await db.doc(`users/${uid}`).set({ currency: { gold: 100_000 } });
  await expect(enhanceEquipmentHandler(req(uid, 'EQ_NOT_OWNED'))).rejects.toThrow(/NOT_OWNED/);
});

test('idempotent: retrying with the same idempotencyKey does not enhance twice', async () => {
  const uid = 'enhance-user-4';
  await db.doc(`users/${uid}`).set({ currency: { gold: 200 } });
  await db.doc(`users/${uid}/equipments/EQ_1`).set({ equipmentId: 'DEF_EQ', enhanceLevel: 0, equippedTo: null });
  const request = req(uid, 'EQ_1');

  await enhanceEquipmentHandler(request);
  await enhanceEquipmentHandler(request);

  const equipment = await db.doc(`users/${uid}/equipments/EQ_1`).get();
  const account = await db.doc(`users/${uid}`).get();
  expect(equipment.data()?.enhanceLevel).toBe(1);
  expect(account.data()?.currency.gold).toBe(100);
});
