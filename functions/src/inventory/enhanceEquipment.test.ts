import { randomUUID } from 'crypto';
import { db } from '../common/admin';
import { fakeAuthedRequest } from '../battle/testSupport';
import { equipItemHandler } from './equipItem';
import { enhanceEquipmentHandler, MAX_ENHANCE_LEVEL } from './enhanceEquipment';

function req(uid: string, equipmentInstanceId: string) {
  return fakeAuthedRequest(uid, { idempotencyKey: randomUUID(), appVersion: '1.0.0', dataVersion: '1', equipmentInstanceId });
}

async function seedAccount(uid: string, gold: number, shards: Record<string, number> = {}): Promise<void> {
  await db.doc(`users/${uid}`).set({ currency: { gold } });
  for (const [item, amount] of Object.entries(shards)) {
    await db.doc(`users/${uid}/items/${item}`).set({ amount });
  }
}

/** 09_MILESTONES.md T-44 완료조건: "+10까지 강화, 실패 없음". EQP_ACORN_SHIELD
 * (FIELD 계열, 태그 미부여)로 강화 배관만 검증 — 태그 부여 로직 자체는
 * 클라이언트 순수 함수(effectiveGrantTags, T-43)에서 이미 검증했다. */
test('deducts T1 shards + gold and increments enhanceLevel (target level 1-5 uses T1)', async () => {
  const uid = 'enhance-user-1';
  // currentLevel=0 -> target=1: T1 amount = 3+1*2=5, gold=100*1=100
  await seedAccount(uid, 100, { ITM_SHARD_FIELD_T1: 5 });
  await db.doc(`users/${uid}/equipments/EQ_1`).set({ equipmentId: 'EQP_ACORN_SHIELD', enhanceLevel: 0, equippedTo: null });

  const res = await enhanceEquipmentHandler(req(uid, 'EQ_1'));

  expect(res.newEnhanceLevel).toBe(1);
  const equipment = await db.doc(`users/${uid}/equipments/EQ_1`).get();
  const account = await db.doc(`users/${uid}`).get();
  const shard = await db.doc(`users/${uid}/items/ITM_SHARD_FIELD_T1`).get();
  expect(equipment.data()?.enhanceLevel).toBe(1);
  expect(account.data()?.currency.gold).toBe(0);
  expect(shard.data()?.amount).toBe(0);
});

test('switches to T2 shards once past level 5 (target level 6-10)', async () => {
  const uid = 'enhance-user-2';
  // currentLevel=5 -> target=6: T2 amount=2+6=8, gold=100*6=600
  await seedAccount(uid, 600, { ITM_SHARD_FIELD_T2: 8 });
  await db.doc(`users/${uid}/equipments/EQ_1`).set({ equipmentId: 'EQP_ACORN_SHIELD', enhanceLevel: 5, equippedTo: null });

  const res = await enhanceEquipmentHandler(req(uid, 'EQ_1'));

  expect(res.newEnhanceLevel).toBe(6);
  const shardT2 = await db.doc(`users/${uid}/items/ITM_SHARD_FIELD_T2`).get();
  expect(shardT2.data()?.amount).toBe(0);
});

test('rejects when shards are insufficient even if gold is enough, and changes nothing', async () => {
  const uid = 'enhance-user-3';
  await seedAccount(uid, 100_000, { ITM_SHARD_FIELD_T1: 4 }); // 5개 필요한데 4개뿐
  await db.doc(`users/${uid}/equipments/EQ_1`).set({ equipmentId: 'EQP_ACORN_SHIELD', enhanceLevel: 0, equippedTo: null });

  await expect(enhanceEquipmentHandler(req(uid, 'EQ_1'))).rejects.toThrow(/NOT_ENOUGH_CURRENCY/);

  const equipment = await db.doc(`users/${uid}/equipments/EQ_1`).get();
  expect(equipment.data()?.enhanceLevel).toBe(0);
});

test('T-44: never fails from a random roll -- succeeds all the way to +10 given enough resources', async () => {
  const uid = 'enhance-user-4';
  await seedAccount(uid, 1_000_000, { ITM_SHARD_FIELD_T1: 1000, ITM_SHARD_FIELD_T2: 1000 });
  await db.doc(`users/${uid}/equipments/EQ_1`).set({ equipmentId: 'EQP_ACORN_SHIELD', enhanceLevel: 0, equippedTo: null });

  for (let i = 0; i < MAX_ENHANCE_LEVEL; i++) {
    const res = await enhanceEquipmentHandler(req(uid, 'EQ_1'));
    expect(res.newEnhanceLevel).toBe(i + 1);
  }

  const equipment = await db.doc(`users/${uid}/equipments/EQ_1`).get();
  expect(equipment.data()?.enhanceLevel).toBe(MAX_ENHANCE_LEVEL);
});

test('rejects enhancing past the +10 cap', async () => {
  const uid = 'enhance-user-5';
  await seedAccount(uid, 1_000_000, { ITM_SHARD_FIELD_T2: 1000 });
  await db
    .doc(`users/${uid}/equipments/EQ_1`)
    .set({ equipmentId: 'EQP_ACORN_SHIELD', enhanceLevel: MAX_ENHANCE_LEVEL, equippedTo: null });

  await expect(enhanceEquipmentHandler(req(uid, 'EQ_1'))).rejects.toThrow();
});

test('rejects enhancing an item that is not owned', async () => {
  const uid = 'enhance-user-6';
  await seedAccount(uid, 100_000);
  await expect(enhanceEquipmentHandler(req(uid, 'EQ_NOT_OWNED'))).rejects.toThrow(/NOT_OWNED/);
});

test('idempotent: retrying with the same idempotencyKey does not enhance twice', async () => {
  const uid = 'enhance-user-7';
  await seedAccount(uid, 100, { ITM_SHARD_FIELD_T1: 5 });
  await db.doc(`users/${uid}/equipments/EQ_1`).set({ equipmentId: 'EQP_ACORN_SHIELD', enhanceLevel: 0, equippedTo: null });
  const request = req(uid, 'EQ_1');

  await enhanceEquipmentHandler(request);
  await enhanceEquipmentHandler(request);

  const equipment = await db.doc(`users/${uid}/equipments/EQ_1`).get();
  const shard = await db.doc(`users/${uid}/items/ITM_SHARD_FIELD_T1`).get();
  expect(equipment.data()?.enhanceLevel).toBe(1); // 2가 아니라 1
  expect(shard.data()?.amount).toBe(0); // 두 번 안 깎임(5개를 두 번 뺐다면 음수)
});

test('T-44: transferring an enhanced item to a different character preserves its enhance level', async () => {
  const uid = 'enhance-user-8';
  await seedAccount(uid, 100, { ITM_SHARD_FIELD_T1: 5 });
  await db.doc(`users/${uid}/characters/CHR_ACORN`).set({ equipmentId: null });
  await db.doc(`users/${uid}/characters/CHR_DROPLET`).set({ equipmentId: null });
  await db.doc(`users/${uid}/equipments/EQ_1`).set({ equipmentId: 'EQP_ACORN_SHIELD', enhanceLevel: 0, equippedTo: null });

  await enhanceEquipmentHandler(req(uid, 'EQ_1'));
  await equipItemHandler(
    fakeAuthedRequest(uid, {
      idempotencyKey: randomUUID(),
      appVersion: '1.0.0',
      dataVersion: '1',
      characterId: 'CHR_ACORN',
      equipmentInstanceId: 'EQ_1',
    }),
  );

  await equipItemHandler(
    fakeAuthedRequest(uid, {
      idempotencyKey: randomUUID(),
      appVersion: '1.0.0',
      dataVersion: '1',
      characterId: 'CHR_DROPLET',
      equipmentInstanceId: 'EQ_1',
    }),
  );

  const equipment = await db.doc(`users/${uid}/equipments/EQ_1`).get();
  expect(equipment.data()?.enhanceLevel).toBe(1); // 이관해도 유지
  expect(equipment.data()?.equippedTo).toBe('CHR_DROPLET');
});
