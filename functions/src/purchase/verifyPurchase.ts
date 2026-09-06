import { createHash } from 'crypto';
import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { admin, db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { BaseRequest } from '../common/types';
import { PRODUCTS_BY_ID } from './productData';
import { grantPurchaseIfNeeded } from './purchaseGrant';
import { verifyReceipt } from './receiptVerifier';

export interface VerifyPurchaseReq extends BaseRequest {
  productId: string;
  platform: 'GOOGLE_PLAY' | 'APP_STORE';
  receipt: string;
}

export interface VerifyPurchaseRes {
  orderId: string;
  granted: boolean;
}

/**
 * 06_BACKEND.md §4.8. 09_MILESTONES.md T-50 완료조건: "영수증 서버 검증,
 * 주문별 1회 지급, 미지급 재처리, 취소·환불 상태 반영".
 *
 * 검증 기록(purchases/{orderId} 생성)과 실제 지급(grantPurchaseIfNeeded)을
 * 일부러 별도 트랜잭션으로 나눈다 -- 한 트랜잭션이면 원자적이라 "지급
 * 실패"가 있을 수 없어 재처리 스케줄 함수가 할 일이 없어진다. 지급 단계
 * 도중 함수가 죽으면 검증 기록만 남고(status:'verified', granted:false)
 * retryUngrantedPurchases가 이어서 지급한다.
 */
export async function verifyPurchaseHandler(request: CallableRequest<VerifyPurchaseReq>): Promise<VerifyPurchaseRes> {
  const uid = requireAuth(request);
  const { productId, platform, receipt } = request.data;

  const product = PRODUCTS_BY_ID[productId];
  if (!product) throw new HttpsError('not-found', 'VALIDATION_FAILED');

  const verification = await verifyReceipt(platform, productId, receipt);
  if (!verification.valid) throw new HttpsError('failed-precondition', 'VALIDATION_FAILED');

  const purchaseRef = db.doc(`users/${uid}/purchases/${verification.orderId}`);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(purchaseRef);
    if (snap.exists) return; // 이미 검증 기록 있음(재시도) -- 지급 여부는 아래서 처리
    tx.set(purchaseRef, {
      productId,
      platform,
      verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      granted: false,
      status: 'verified',
      receiptHash: createHash('sha256').update(receipt).digest('hex'),
    });
  });

  const granted = await grantPurchaseIfNeeded(uid, verification.orderId, product);
  return { orderId: verification.orderId, granted };
}

export const verifyPurchase = onCall(verifyPurchaseHandler);
