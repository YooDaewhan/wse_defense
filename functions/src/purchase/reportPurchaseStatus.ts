import { db } from '../common/admin';

export type PurchaseStatusUpdate = 'refunded' | 'canceled';

/**
 * 06_BACKEND.md §4.8 4단계: 취소·환불 웹훅(RTDN / App Store Server
 * Notifications) 수신 시 상태만 반영한다("환불 시 지급물 회수는 정책에
 * 따라. 최소한 상태는 기록해 둔다") -- 이미 지급된 보상은 회수하지 않고,
 * 이후 verifyPurchase 재시도와 retryUngrantedPurchases가 이 상태를 보고
 * 지급을 건너뛰게만 한다.
 *
 * ponytail: 실제 RTDN/App Store Server Notification 서명 검증과 그걸 받는
 * onRequest 엔드포인트는 스토어 콘솔 설정이 필요해 범위 밖 -- 이 함수는
 * 그 웹훅이 호출할 순수 상태 반영 로직만 담당한다.
 */
export async function reportPurchaseStatus(uid: string, orderId: string, status: PurchaseStatusUpdate): Promise<void> {
  await db.doc(`users/${uid}/purchases/${orderId}`).set({ status }, { merge: true });
}
