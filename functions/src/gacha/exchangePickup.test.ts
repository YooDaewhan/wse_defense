import { randomUUID } from 'crypto';
import { db } from '../common/admin';
import { fakeAuthedRequest } from '../battle/testSupport';
import { exchangePickupHandler } from './exchangePickup';
import { gachaPullHandler } from './gachaPull';

async function seedExchangePoints(uid: string, amount: number): Promise<void> {
  await db.doc(`users/${uid}`).set({ currency: { gold: 0, recruitTicket: 0, exchangePoint: amount } });
}

function req(uid: string, characterId: string) {
  return fakeAuthedRequest(uid, {
    idempotencyKey: randomUUID(),
    appVersion: '1.0.0',
    dataVersion: '1',
    bannerId: 'BNR_THEME_BEAR',
    characterId,
  });
}

/** 09_MILESTONES.md T-49 완료조건: "200 차감, 초과분 유지, 중간 픽업 획득 시
 * 초기화 없음". */
test('deducts exactly 200 and keeps the excess (carry-over)', async () => {
  const uid = 'exchange-user-1';
  await seedExchangePoints(uid, 250);

  const res = await exchangePickupHandler(req(uid, 'CHR_BEAR'));

  expect(res.exchangePointAfter).toBe(50);
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.exchangePoint).toBe(50);
});

test('grants the character as new when not already owned', async () => {
  const uid = 'exchange-user-2';
  await seedExchangePoints(uid, 200);

  const res = await exchangePickupHandler(req(uid, 'CHR_BEAR'));

  expect(res.convertedFragments).toBeUndefined();
  const character = await db.doc(`users/${uid}/characters/CHR_BEAR`).get();
  expect(character.exists).toBe(true);
});

test('converts to fragments when already owned, instead of a duplicate grant', async () => {
  const uid = 'exchange-user-3';
  await seedExchangePoints(uid, 200);
  await db.doc(`users/${uid}/characters/CHR_BEAR`).set({ dupCount: 0 });

  const res = await exchangePickupHandler(req(uid, 'CHR_BEAR'));

  expect(res.convertedFragments).toBe(30); // BNR_THEME_BEAR duplicateConversion.rarity3
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.collectFragment).toBe(30);
});

test('rejects when fewer than 200 points are held, and changes nothing', async () => {
  const uid = 'exchange-user-4';
  await seedExchangePoints(uid, 199);

  await expect(exchangePickupHandler(req(uid, 'CHR_BEAR'))).rejects.toThrow(/NOT_ENOUGH_CURRENCY/);

  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.exchangePoint).toBe(199);
});

test('rejects a characterId outside the banner\'s exchangeTargets', async () => {
  const uid = 'exchange-user-5';
  await seedExchangePoints(uid, 200);

  await expect(exchangePickupHandler(req(uid, 'CHR_ACORN'))).rejects.toThrow();
});

test('idempotent: retrying with the same idempotencyKey does not deduct twice', async () => {
  const uid = 'exchange-user-6';
  await seedExchangePoints(uid, 200);
  const request = req(uid, 'CHR_BEAR');

  const first = await exchangePickupHandler(request);
  const second = await exchangePickupHandler(request);

  expect(second).toEqual(first);
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.exchangePoint).toBe(0);
});

test('a natural pickup grant from gachaPull does not reset the accumulated exchangePoint', async () => {
  const uid = 'exchange-user-7';
  await db.doc(`users/${uid}`).set({ currency: { gold: 0, recruitTicket: 20, exchangePoint: 40 } });

  await gachaPullHandler(
    fakeAuthedRequest(uid, {
      idempotencyKey: randomUUID(),
      appVersion: '1.0.0',
      dataVersion: '1',
      bannerId: 'BNR_THEME_BEAR',
      count: 10,
    }),
  );

  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.exchangePoint).toBe(50); // 40 + pointPerPull(1)*10, 초기화 없음
});
