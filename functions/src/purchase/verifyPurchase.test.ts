import { db } from '../common/admin';
import { fakeAuthedRequest } from '../battle/testSupport';
import { verifyPurchaseHandler } from './verifyPurchase';

async function seedAccount(uid: string): Promise<void> {
  await db.doc(`users/${uid}`).set({ currency: { gold: 0, recruitTicket: 0, collectFragment: 0, exchangePoint: 0 } });
}

function req(uid: string, receipt: string, productId = 'gem_pack_small') {
  return fakeAuthedRequest(uid, {
    idempotencyKey: 'unused',
    appVersion: '1.0.0',
    dataVersion: '1',
    productId,
    platform: 'GOOGLE_PLAY' as const,
    receipt,
  });
}

/** 09_MILESTONES.md T-50 완료조건: "영수증 서버 검증, 주문별 1회 지급,
 * 미지급 재처리, 취소·환불 상태 반영". */
test('a valid receipt verifies and grants the product', async () => {
  const uid = 'purchase-user-1';
  await seedAccount(uid);

  const res = await verifyPurchaseHandler(req(uid, 'order-1'));

  expect(res.granted).toBe(true);
  expect(res.orderId).toBe('order-1');
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.gold).toBe(1000);
  const purchase = await db.doc(`users/${uid}/purchases/order-1`).get();
  expect(purchase.data()?.granted).toBe(true);
  expect(purchase.data()?.status).toBe('granted');
});

test('retrying the same order does not grant twice', async () => {
  const uid = 'purchase-user-2';
  await seedAccount(uid);

  await verifyPurchaseHandler(req(uid, 'order-2'));
  const second = await verifyPurchaseHandler(req(uid, 'order-2'));

  expect(second.granted).toBe(true);
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.gold).toBe(1000); // 두 번 지급 안 됨
});

test('rejects an invalid receipt and grants nothing', async () => {
  const uid = 'purchase-user-3';
  await seedAccount(uid);

  await expect(verifyPurchaseHandler(req(uid, 'INVALID:order-3'))).rejects.toThrow();

  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.gold).toBe(0);
  const purchase = await db.doc(`users/${uid}/purchases/INVALID:order-3`).get();
  expect(purchase.exists).toBe(false);
});

test('rejects an unknown productId', async () => {
  const uid = 'purchase-user-4';
  await expect(verifyPurchaseHandler(req(uid, 'order-4', 'ITM_NOT_REAL'))).rejects.toThrow();
});
