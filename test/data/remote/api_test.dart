import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/data/remote/api.dart';

/// 10_WIRING_PLAN.md T-59 완료조건: "에러를 FirebaseFunctionsException
/// 그대로 던지지 말고 화면이 쓸 수 있는 형태로 정리". `mapServerErrorCode`
/// 는 그 정리 로직의 순수 핵심부라 `FirebaseFunctionsException`(protected
/// 생성자라 테스트에서 직접 못 만듦) 없이도 검증할 수 있다.
void main() {
  test('maps every server ErrorCode to its ApiErrorCode', () {
    const cases = {
      'AUTH_REQUIRED': ApiErrorCode.authRequired,
      'APP_VERSION_TOO_OLD': ApiErrorCode.appVersionTooOld,
      'DATA_VERSION_MISMATCH': ApiErrorCode.dataVersionMismatch,
      'NOT_ENOUGH_CURRENCY': ApiErrorCode.notEnoughCurrency,
      'NOT_OWNED': ApiErrorCode.notOwned,
      'ALREADY_APPLIED': ApiErrorCode.alreadyApplied,
      'BATTLE_NOT_FOUND': ApiErrorCode.battleNotFound,
      'BATTLE_EXPIRED': ApiErrorCode.battleExpired,
      'BATTLE_ALREADY_SUBMITTED': ApiErrorCode.battleAlreadySubmitted,
      'VALIDATION_FAILED': ApiErrorCode.validationFailed,
      'DAILY_LIMIT_REACHED': ApiErrorCode.dailyLimitReached,
      'BANNER_CLOSED': ApiErrorCode.bannerClosed,
      'RATE_LIMITED': ApiErrorCode.rateLimited,
      'MAINTENANCE': ApiErrorCode.maintenance,
      'INTERNAL': ApiErrorCode.internal,
    };

    for (final entry in cases.entries) {
      final result = mapServerErrorCode('failed-precondition', entry.key);
      expect(result.code, entry.value, reason: '${entry.key} should map to ${entry.value}');
      expect(result.message, entry.key);
    }
  });

  test('falls back to authRequired for an unauthenticated grpc code with no recognized message', () {
    final result = mapServerErrorCode('unauthenticated', 'some-unrelated-message');
    expect(result.code, ApiErrorCode.authRequired);
  });

  test('falls back to network for unavailable/deadline-exceeded grpc codes', () {
    expect(mapServerErrorCode('unavailable', 'x').code, ApiErrorCode.network);
    expect(mapServerErrorCode('deadline-exceeded', 'x').code, ApiErrorCode.network);
  });

  test('falls back to unknown for anything unrecognized', () {
    expect(mapServerErrorCode('internal', 'SOMETHING_NEW').code, ApiErrorCode.unknown);
  });

  test('normalizeApiError treats a non-FirebaseFunctionsException as a network failure', () {
    final result = normalizeApiError(StateError('offline'));
    expect(result.code, ApiErrorCode.network);
  });

  test('RequestMeta serializes exactly the three BaseRequest fields', () {
    const meta = RequestMeta(idempotencyKey: 'key-1', appVersion: '1.0.0', dataVersion: '1');
    expect(meta.toJson(), {'idempotencyKey': 'key-1', 'appVersion': '1.0.0', 'dataVersion': '1'});
  });
}
