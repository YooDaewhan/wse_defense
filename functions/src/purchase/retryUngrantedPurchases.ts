import { onSchedule } from 'firebase-functions/v2/scheduler';
import { db } from '../common/admin';
import { PRODUCTS_BY_ID } from './productData';
import { grantPurchaseIfNeeded } from './purchaseGrant';

/**
 * 06_BACKEND.md §4.9 `retryUngrantedPurchases`(30분마다). 09_MILESTONES.md
 * T-50 완료조건 "미지급 재처리" -- verifyPurchase의 지급 단계가 죽어서
 * status:'verified'인 채 granted:false로 남은 주문을 모든 유저에 걸쳐
 * 찾아 이어서 지급한다.
 */
export async function retryUngrantedPurchasesOnce(): Promise<number> {
  const snap = await db.collectionGroup('purchases').where('status', '==', 'verified').get();
  let grantedCount = 0;
  for (const doc of snap.docs) {
    const uid = doc.ref.parent.parent?.id;
    if (!uid) continue;
    const product = PRODUCTS_BY_ID[doc.data().productId as string];
    if (!product) continue;
    if (await grantPurchaseIfNeeded(uid, doc.id, product)) grantedCount++;
  }
  return grantedCount;
}

export const retryUngrantedPurchases = onSchedule('every 30 minutes', async () => {
  await retryUngrantedPurchasesOnce();
});
