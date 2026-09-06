import { randomUUID } from 'crypto';
import { db } from '../common/admin';
import { fakeAuthedRequest } from '../battle/testSupport';
import { exchangeItemsHandler } from './exchangeItems';

async function seedItem(uid: string, itemId: string, amount: number): Promise<void> {
  // 실서비스에서는 bootstrapAccount가 항상 먼저 users/{uid}를 만들어 두지만,
  // 여기서는 서브컬렉션 문서만 만들어도(부모 문서 없이) 통과하므로 명시적으로
  // 만들어 둔다 — applyReward의 통화 지급 분기가 tx.update를 쓰기 때문에
  // (존재를 전제) 부모 문서가 없으면 실패한다.
  const userRef = db.doc(`users/${uid}`);
  if (!(await userRef.get()).exists) {
    await userRef.set({ currency: { gold: 0 } });
  }
  await db.doc(`users/${uid}/items/${itemId}`).set({ amount, updatedAt: Date.now() });
}

function req(uid: string, entryId: string, times?: number) {
  return fakeAuthedRequest(uid, { idempotencyKey: randomUUID(), appVersion: '1.0.0', dataVersion: '1', entryId, times });
}

/** 09_MILESTONES.md T-43 완료조건: "T3×10→장비 1종 획득", "T1×5→T2, T2×5→T3
 * 승급", "limit/resetPeriod 서버 검증". */
test('T1x5 -> T2x1 upgrade deducts T1 and grants T2', async () => {
  const uid = 'exch-user-1';
  await seedItem(uid, 'ITM_SHARD_SUN_T1', 5);

  const res = await exchangeItemsHandler(req(uid, 'UPG_SUN_T1_T2'));

  expect(res.granted).toEqual([{ item: 'ITM_SHARD_SUN_T2', amount: 1 }]);
  const t1 = await db.doc(`users/${uid}/items/ITM_SHARD_SUN_T1`).get();
  const t2 = await db.doc(`users/${uid}/items/ITM_SHARD_SUN_T2`).get();
  expect(t1.data()?.amount).toBe(0);
  expect(t2.data()?.amount).toBe(1);
});

test('T2x5 -> T3x1 upgrade works the same way', async () => {
  const uid = 'exch-user-2';
  await seedItem(uid, 'ITM_SHARD_SUN_T2', 5);

  const res = await exchangeItemsHandler(req(uid, 'UPG_SUN_T2_T3'));

  expect(res.granted).toEqual([{ item: 'ITM_SHARD_SUN_T3', amount: 1 }]);
});

test('rejects an upgrade when shards are insufficient, and changes nothing', async () => {
  const uid = 'exch-user-3';
  await seedItem(uid, 'ITM_SHARD_SUN_T1', 4);

  await expect(exchangeItemsHandler(req(uid, 'UPG_SUN_T1_T2'))).rejects.toThrow(/NOT_ENOUGH_CURRENCY/);

  const t1 = await db.doc(`users/${uid}/items/ITM_SHARD_SUN_T1`).get();
  expect(t1.data()?.amount).toBe(4);
});

test('T3x10 -> equipment exchange creates a new equipment instance at enhanceLevel 0', async () => {
  const uid = 'exch-user-4';
  await seedItem(uid, 'ITM_SHARD_SUN_T3', 10);

  await exchangeItemsHandler(req(uid, 'EX_ANIMAL_MASK'));

  const t3 = await db.doc(`users/${uid}/items/ITM_SHARD_SUN_T3`).get();
  expect(t3.data()?.amount).toBe(0);

  const equipments = await db.collection(`users/${uid}/equipments`).get();
  expect(equipments.size).toBe(1);
  expect(equipments.docs[0].data()).toMatchObject({ equipmentId: 'EQP_ANIMAL_MASK', enhanceLevel: 0, equippedTo: null });
});

test('a WEEKLY-limited entry can be used up to its limit, then is rejected', async () => {
  const uid = 'exch-user-5';
  await seedItem(uid, 'ITM_SHARD_SUN_T1', 20 * 6);

  for (let i = 0; i < 5; i++) {
    await exchangeItemsHandler(req(uid, 'EX_SUN_GOLD_POUCH'));
  }
  await expect(exchangeItemsHandler(req(uid, 'EX_SUN_GOLD_POUCH'))).rejects.toThrow(/DAILY_LIMIT_REACHED/);

  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.gold).toBe(6000 * 5); // 6번째는 반영 안 됨
});

test('CURRENCY gain updates users/{uid}.currency directly', async () => {
  const uid = 'exch-user-6';
  await seedItem(uid, 'ITM_SHARD_SUN_T1', 20);

  const res = await exchangeItemsHandler(req(uid, 'EX_SUN_GOLD_POUCH'));

  expect(res.granted).toEqual([{ item: 'ITM_GOLD', amount: 6000 }]);
  expect(res.patch.currency?.gold).toBe(6000);
});

test('times batches cost and gain together in one call', async () => {
  const uid = 'exch-user-7';
  await seedItem(uid, 'ITM_SHARD_SUN_T1', 15);

  const res = await exchangeItemsHandler(req(uid, 'UPG_SUN_T1_T2', 3));

  expect(res.granted).toEqual([{ item: 'ITM_SHARD_SUN_T2', amount: 3 }]);
  const t1 = await db.doc(`users/${uid}/items/ITM_SHARD_SUN_T1`).get();
  expect(t1.data()?.amount).toBe(0);
});

test('idempotent: retrying with the same idempotencyKey does not exchange twice', async () => {
  const uid = 'exch-user-8';
  await seedItem(uid, 'ITM_SHARD_SUN_T1', 5);
  const request = req(uid, 'UPG_SUN_T1_T2');

  const first = await exchangeItemsHandler(request);
  const second = await exchangeItemsHandler(request);

  expect(second).toEqual(first);
  const t2 = await db.doc(`users/${uid}/items/ITM_SHARD_SUN_T2`).get();
  expect(t2.data()?.amount).toBe(1); // 2가 아니라 1
});

test('rejects an unknown entryId', async () => {
  const uid = 'exch-user-9';
  await expect(exchangeItemsHandler(req(uid, 'EX_NOT_REAL'))).rejects.toThrow();
});
