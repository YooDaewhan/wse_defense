import { db } from '../common/admin';
import { PRODUCTS_BY_ID } from './productData';
import { grantPurchaseIfNeeded } from './purchaseGrant';
import { reportPurchaseStatus } from './reportPurchaseStatus';

/** 09_MILESTONES.md T-50 완료조건: "취소·환불 상태 반영". */
test('marks a purchase refunded without clawing back an already-granted reward', async () => {
  const uid = 'refund-user-1';
  await db.doc(`users/${uid}`).set({ currency: { gold: 0 } });
  await db.doc(`users/${uid}/purchases/order-1`).set({ productId: 'gem_pack_small', granted: true, status: 'granted' });

  await reportPurchaseStatus(uid, 'order-1', 'refunded');

  const purchase = await db.doc(`users/${uid}/purchases/order-1`).get();
  expect(purchase.data()?.status).toBe('refunded');
  expect(purchase.data()?.granted).toBe(true); // 이미 지급된 보상은 회수하지 않음
});

test('a purchase refunded before it was ever granted is never granted', async () => {
  const uid = 'refund-user-2';
  await db.doc(`users/${uid}`).set({ currency: { gold: 0 } });
  await db.doc(`users/${uid}/purchases/order-2`).set({ productId: 'gem_pack_small', granted: false, status: 'verified' });

  await reportPurchaseStatus(uid, 'order-2', 'refunded');
  const granted = await grantPurchaseIfNeeded(uid, 'order-2', PRODUCTS_BY_ID.gem_pack_small);

  expect(granted).toBe(false);
  const account = await db.doc(`users/${uid}`).get();
  expect(account.data()?.currency.gold).toBe(0);
});
