import { randomUUID } from 'crypto';
import { db } from '../common/admin';
import { fakeAuthedRequest } from '../battle/testSupport';
import { BANNERS_BY_ID, GACHA_RATES_VERSION } from './bannerData';
import { gachaPullHandler } from './gachaPull';

async function seedTickets(uid: string, amount: number): Promise<void> {
  await db.doc(`users/${uid}`).set({ currency: { gold: 0, recruitTicket: amount } });
}

async function ownAllPoolCharacters(uid: string, bannerId: string): Promise<void> {
  const banner = BANNERS_BY_ID[bannerId]!;
  for (const rate of banner.rates) {
    for (const characterId of rate.pool) {
      await db.doc(`users/${uid}/characters/${characterId}`).set({ dupCount: 0 });
    }
  }
}

function req(uid: string, bannerId: string, count: 1 | 10) {
  return fakeAuthedRequest(uid, { idempotencyKey: randomUUID(), appVersion: '1.0.0', dataVersion: '1', bannerId, count });
}

/** 09_MILESTONES.md T-48 완료조건: "1회/10회, 교환 포인트 적립·이월,
 * ratesVersion 원장 기록". */
test('a single pull from an empty roster always grants a new character and deducts 1 ticket', async () => {
  const uid = 'gacha-user-1';
  await seedTickets(uid, 1);

  const res = await gachaPullHandler(req(uid, 'BNR_STANDARD', 1));

  expect(res.results).toHaveLength(1);
  expect(res.results[0].isNew).toBe(true);
  expect(res.ratesVersion).toBe(GACHA_RATES_VERSION);

  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.recruitTicket).toBe(0);
});

test('a ten-pull returns exactly 10 results and deducts 10 tickets', async () => {
  const uid = 'gacha-user-2';
  await seedTickets(uid, 10);

  const res = await gachaPullHandler(req(uid, 'BNR_STANDARD', 10));

  expect(res.results).toHaveLength(10);
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.recruitTicket).toBe(0);
});

test('starting from an empty roster, every distinct character\'s first appearance is new', async () => {
  const uid = 'gacha-user-3';
  await seedTickets(uid, 10);

  const res = await gachaPullHandler(req(uid, 'BNR_STANDARD', 10));

  const distinctIds = new Set(res.results.map((r) => r.characterId));
  const newCount = res.results.filter((r) => r.isNew).length;
  expect(newCount).toBe(distinctIds.size); // 처음 등장한 것만 신규, 나머지는 중복 전환
});

test('already owning every pool character converts every pull to fragments, not new grants', async () => {
  const uid = 'gacha-user-4';
  await seedTickets(uid, 1);
  await ownAllPoolCharacters(uid, 'BNR_STANDARD');

  const res = await gachaPullHandler(req(uid, 'BNR_STANDARD', 1));

  expect(res.results[0].isNew).toBe(false);
  expect(res.results[0].convertedFragments).toBeGreaterThan(0);
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.collectFragment).toBe(res.results[0].convertedFragments);
});

test('THEME banner accumulates exchangePoint, STANDARD banner does not', async () => {
  const uid = 'gacha-user-5';
  await seedTickets(uid, 20);

  const standard = await gachaPullHandler(req(uid, 'BNR_STANDARD', 10));
  expect(standard.exchangePointAfter).toBe(0);

  const theme = await gachaPullHandler(req(uid, 'BNR_THEME_BEAR', 10));
  expect(theme.exchangePointAfter).toBe(10); // pointPerPull(1) * count(10)

  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.exchangePoint).toBe(10);
});

test('exchangePoint carries over across multiple pulls (no reset)', async () => {
  const uid = 'gacha-user-6';
  await seedTickets(uid, 20);

  const first = await gachaPullHandler(req(uid, 'BNR_THEME_BEAR', 10));
  expect(first.exchangePointAfter).toBe(10);
  const second = await gachaPullHandler(req(uid, 'BNR_THEME_BEAR', 10));
  expect(second.exchangePointAfter).toBe(20); // 이어서 누적, 초기화 없음
});

test('rejects when there are not enough recruit tickets, and changes nothing', async () => {
  const uid = 'gacha-user-7';
  await seedTickets(uid, 5);

  await expect(gachaPullHandler(req(uid, 'BNR_STANDARD', 10))).rejects.toThrow(/NOT_ENOUGH_CURRENCY/);

  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.recruitTicket).toBe(5);
});

test('rejects an unknown bannerId', async () => {
  const uid = 'gacha-user-8';
  await seedTickets(uid, 10);
  await expect(gachaPullHandler(req(uid, 'BNR_NOT_REAL', 1))).rejects.toThrow();
});

test('idempotent: retrying with the same idempotencyKey does not pull twice', async () => {
  const uid = 'gacha-user-9';
  await seedTickets(uid, 1);
  const request = req(uid, 'BNR_STANDARD', 1);

  const first = await gachaPullHandler(request);
  const second = await gachaPullHandler(request);

  expect(second).toEqual(first);
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.recruitTicket).toBe(0); // 두 번 안 깎임(1개뿐이라 음수면 실패했을 것)
});
