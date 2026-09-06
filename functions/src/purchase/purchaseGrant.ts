import { Transaction } from 'firebase-admin/firestore';
import { db } from '../common/admin';
import { applyReward } from '../common/rewards';
import { ProductDef } from './productData';

/**
 * verifyPurchase와 스케줄 재처리(retryUngrantedPurchases)가 공유하는 지급
 * 로직 -- 검증 기록(status:'verified')은 이미 있고 아직 granted:false인
 * 주문에 실제 보상을 적용한다. 이미 지급됐거나 취소·환불된 주문은
 * 건드리지 않는다.
 */
export async function grantPurchaseIfNeeded(uid: string, orderId: string, product: ProductDef): Promise<boolean> {
  const purchaseRef = db.doc(`users/${uid}/purchases/${orderId}`);
  return db.runTransaction(async (tx: Transaction) => {
    const snap = await tx.get(purchaseRef);
    if (!snap.exists) return false;
    const data = snap.data()!;
    if (data.granted) return true;
    if (data.status === 'refunded' || data.status === 'canceled') return false;

    for (const grant of product.grants) applyReward(tx, uid, grant);
    tx.update(purchaseRef, { granted: true, status: 'granted' });
    return true;
  });
}
