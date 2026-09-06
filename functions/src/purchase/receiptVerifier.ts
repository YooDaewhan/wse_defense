export interface ReceiptVerification {
  valid: boolean;
  orderId: string;
}

/**
 * ponytail: Google Play Developer API / App Store Server API 실연동은
 * 스토어 크리덴셜·SDK가 필요해 이 저장소 범위 밖 -- 실 연동 전까지는
 * 클라가 보낸 영수증 문자열을 이미 검증된 주문 ID로 그대로 신뢰하는
 * 자리표시자만 둔다(`INVALID:` 접두사만 위조로 취급해 거부, 테스트용).
 * 실 연동 시 이 함수 내부만 실제 플랫폼 API 호출로 교체하면 된다.
 */
export async function verifyReceipt(
  _platform: string,
  _productId: string,
  receipt: string,
): Promise<ReceiptVerification> {
  if (receipt.startsWith('INVALID:')) return { valid: false, orderId: receipt };
  return { valid: true, orderId: receipt };
}
