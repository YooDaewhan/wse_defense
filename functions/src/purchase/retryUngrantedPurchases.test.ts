import { db } from '../common/admin';
import { retryUngrantedPurchasesOnce } from './retryUngrantedPurchases';

/** 09_MILESTONES.md T-50 완료조건: "미지급 재처리" -- verifyPurchase의
 * 지급 단계가 죽어서 status:'verified'인 채 granted:false로 남은 주문을
 * 스케줄 함수가 찾아 이어서 지급한다. */
test('grants a purchase left verified but ungranted', async () => {
  const uid = 'retry-user-1';
  await db.doc(`users/${uid}`).set({ currency: { gold: 0 } });
  await db.doc(`users/${uid}/purchases/order-1`).set({ productId: 'gem_pack_small', granted: false, status: 'verified' });

  const count = await retryUngrantedPurchasesOnce();

  expect(count).toBeGreaterThanOrEqual(1);
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.gold).toBe(1000);
  const purchase = await db.doc(`users/${uid}/purchases/order-1`).get();
  expect(purchase.data()?.granted).toBe(true);
  expect(purchase.data()?.status).toBe('granted');
});

test('running the retry twice does not double-grant', async () => {
  const uid = 'retry-user-2';
  await db.doc(`users/${uid}`).set({ currency: { gold: 0 } });
  await db.doc(`users/${uid}/purchases/order-2`).set({ productId: 'gem_pack_small', granted: false, status: 'verified' });

  await retryUngrantedPurchasesOnce();
  await retryUngrantedPurchasesOnce();

  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.gold).toBe(1000);
});

test('never grants an order already marked refunded', async () => {
  const uid = 'retry-user-3';
  await db.doc(`users/${uid}`).set({ currency: { gold: 0 } });
  await db.doc(`users/${uid}/purchases/order-3`).set({ productId: 'gem_pack_small', granted: false, status: 'refunded' });

  await retryUngrantedPurchasesOnce();

  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.gold).toBe(0);
});
