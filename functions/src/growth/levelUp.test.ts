import { randomUUID } from 'crypto';
import { db } from '../common/admin';
import { fakeAuthedRequest } from '../battle/testSupport';
import { levelUpHandler } from './levelUp';
import { BOND_MAX_LEVEL, costForLevelUp, FOCUS_GOLD_COST } from './growthConfig';

async function seedAccount(uid: string, gold: number, growth: Record<string, number> = {}): Promise<void> {
  await db.doc(`users/${uid}`).set({ currency: { gold }, growth: { bondLevel: 1, focusLevel: 1, campDefenseLevel: 1, ...growth } });
}

test('deducts gold and increments the level in one transaction', async () => {
  const uid = 'levelup-user-1';
  const cost = costForLevelUp(FOCUS_GOLD_COST, 1);
  await seedAccount(uid, cost + 50);

  const res = await levelUpHandler(fakeAuthedRequest(uid, { idempotencyKey: randomUUID(), appVersion: '1.0.0', dataVersion: '1', target: 'FOCUS' }));

  expect(res.newLevel).toBe(2);
  expect(res.goldSpent).toBe(cost);
  const doc = await db.doc(`users/${uid}`).get();
  expect(doc.data()?.currency.gold).toBe(50);
  expect(doc.data()?.growth.focusLevel).toBe(2);
});

test('rejects when gold is not enough, and changes nothing', async () => {
  const uid = 'levelup-user-2';
  const cost = costForLevelUp(FOCUS_GOLD_COST, 1);
  await seedAccount(uid, cost - 1);

  await expect(
    levelUpHandler(fakeAuthedRequest(uid, { idempotencyKey: randomUUID(), appVersion: '1.0.0', dataVersion: '1', target: 'FOCUS' })),
  ).rejects.toThrow(/NOT_ENOUGH_CURRENCY/);

  const doc = await db.doc(`users/${uid}`).get();
  expect(doc.data()?.currency.gold).toBe(cost - 1);
  expect(doc.data()?.growth.focusLevel).toBe(1);
});

test('rejects bond level-up past the max level', async () => {
  const uid = 'levelup-user-3';
  await seedAccount(uid, 1_000_000, { bondLevel: BOND_MAX_LEVEL });

  await expect(
    levelUpHandler(fakeAuthedRequest(uid, { idempotencyKey: randomUUID(), appVersion: '1.0.0', dataVersion: '1', target: 'BOND' })),
  ).rejects.toThrow();
});

test('idempotent: retrying with the same idempotencyKey does not deduct gold twice', async () => {
  const uid = 'levelup-user-4';
  const cost = costForLevelUp(FOCUS_GOLD_COST, 1);
  await seedAccount(uid, cost + 50);
  const req = fakeAuthedRequest(uid, { idempotencyKey: randomUUID(), appVersion: '1.0.0', dataVersion: '1', target: 'FOCUS' as const });

  await levelUpHandler(req);
  await levelUpHandler(req);

  const doc = await db.doc(`users/${uid}`).get();
  expect(doc.data()?.currency.gold).toBe(50); // 두 번이 아니라 한 번만 차감
  expect(doc.data()?.growth.focusLevel).toBe(2);
});
