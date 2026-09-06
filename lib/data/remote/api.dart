import 'package:cloud_functions/cloud_functions.dart';

/// 10_WIRING_PLAN.md T-59. 06_BACKEND.md §5의 Callable 16종(스케줄 함수
/// `retryUngrantedPurchases`는 클라이언트가 직접 부르지 않으므로 제외)을
/// 부르는 얇은 래퍼 — 함수마다 리포지토리 클래스를 만들지 않고, 함수
/// 하나당 Dart 함수 하나만 둔다. 리전은 06_BACKEND.md §5에 맞춰 항상
/// `asia-northeast3`로 고정한다.
const _region = 'asia-northeast3';

/// `BaseRequest`(06_BACKEND.md §4.1) 공통 3필드 — 매 호출마다 반복 타이핑을
/// 피하려고 값 객체 하나로 묶었다(리포지토리가 아니라 순수 데이터).
class RequestMeta {
  const RequestMeta({required this.idempotencyKey, required this.appVersion, required this.dataVersion});

  final String idempotencyKey;
  final String appVersion;
  final String dataVersion;

  Map<String, dynamic> toJson() => {
    'idempotencyKey': idempotencyKey,
    'appVersion': appVersion,
    'dataVersion': dataVersion,
  };
}

/// 서버 `ErrorCode`(functions/src/common/types.ts)를 그대로 옮긴 것 --
/// 화면은 `FirebaseFunctionsException`을 몰라도 되고 이 enum만 보고
/// 분기한다. `network`/`unknown`은 서버에 없는, 클라이언트 쪽에서만
/// 생기는 상태다.
enum ApiErrorCode {
  authRequired,
  appVersionTooOld,
  dataVersionMismatch,
  notEnoughCurrency,
  notOwned,
  alreadyApplied,
  battleNotFound,
  battleExpired,
  battleAlreadySubmitted,
  validationFailed,
  dailyLimitReached,
  bannerClosed,
  rateLimited,
  maintenance,
  internal,
  /// 오프라인 등 요청이 서버에 닿지도 못한 경우 — `BattleSubmitQueue`(T-60)
  /// 가 이 코드만 보고 재시도 큐에 넣을지 판단한다.
  network,
  unknown,
}

const _codeByServerMessage = {
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

/// 화면이 실제로 받아 다루는 예외 — `FirebaseFunctionsException`을 그대로
/// 던지지 않는다(완료조건). [message]는 로그용 원본이라 사용자에게 그대로
/// 보여주지 않는다(현지화 문구는 [code]로 화면이 고른다).
class ApiException implements Exception {
  const ApiException(this.code, this.message);

  final ApiErrorCode code;
  final String message;

  @override
  String toString() => 'ApiException($code, $message)';
}

/// 서버 `ErrorCode`(HttpsError의 message 인자)를 우선 찾고, 못 찾으면 grpc
/// 스타일 [grpcCode]로, 그것도 못 찾으면 알 수 없는 실패로 본다. 순수
/// 함수라 `FirebaseFunctionsException`을 직접 만들 필요 없이 테스트할 수
/// 있다.
ApiException mapServerErrorCode(String grpcCode, String serverMessage) {
  final byMessage = _codeByServerMessage[serverMessage];
  if (byMessage != null) return ApiException(byMessage, serverMessage);
  if (grpcCode == 'unauthenticated') return ApiException(ApiErrorCode.authRequired, serverMessage);
  if (grpcCode == 'unavailable' || grpcCode == 'deadline-exceeded') {
    return ApiException(ApiErrorCode.network, serverMessage);
  }
  return ApiException(ApiErrorCode.unknown, serverMessage);
}

/// [error]가 [FirebaseFunctionsException]이면 [mapServerErrorCode]로 넘기고,
/// 그 외(오프라인 등 요청이 서버에 닿지도 못한 경우)는 네트워크 실패로 본다.
ApiException normalizeApiError(Object error) {
  if (error is FirebaseFunctionsException) {
    return mapServerErrorCode(error.code, error.message ?? error.code);
  }
  return ApiException(ApiErrorCode.network, '$error');
}

Future<Map<String, dynamic>> _call(String name, Map<String, dynamic> data) async {
  try {
    final callable = FirebaseFunctions.instanceFor(region: _region).httpsCallable(name);
    final result = await callable.call<Object?>(data);
    return Map<String, dynamic>.from(result.data as Map);
  } catch (e) {
    throw normalizeApiError(e);
  }
}

// ---- account -------------------------------------------------------------

Future<Map<String, dynamic>> bootstrapAccount({required String appVersion, required String dataVersion}) =>
    _call('bootstrapAccount', {'appVersion': appVersion, 'dataVersion': dataVersion});

// ---- battle ----------------------------------------------------------------

Future<Map<String, dynamic>> startBattle(
  RequestMeta meta, {
  required String mode,
  required String stageId,
  required int presetIndex,
  int? difficulty,
  String? trialCharacterId,
}) => _call('startBattle', {
  ...meta.toJson(),
  'mode': mode,
  'stageId': stageId,
  'presetIndex': presetIndex,
  'difficulty': ?difficulty,
  'trialCharacterId': ?trialCharacterId,
});

Future<Map<String, dynamic>> submitBattle(
  RequestMeta meta, {
  required String battleId,
  required String outcome,
  required Map<String, dynamic> summary,
  required String inputLog,
  required String formationHash,
}) => _call('submitBattle', {
  ...meta.toJson(),
  'battleId': battleId,
  'outcome': outcome,
  'summary': summary,
  'inputLog': inputLog,
  'formationHash': formationHash,
});

// ---- growth ------------------------------------------------------------

Future<Map<String, dynamic>> levelUp(RequestMeta meta, {required String target}) =>
    _call('levelUp', {...meta.toJson(), 'target': target});

// ---- inventory -----------------------------------------------------------

Future<Map<String, dynamic>> equipItem(
  RequestMeta meta, {
  required String characterId,
  required String? equipmentInstanceId,
}) => _call('equipItem', {...meta.toJson(), 'characterId': characterId, 'equipmentInstanceId': equipmentInstanceId});

Future<Map<String, dynamic>> enhanceEquipment(RequestMeta meta, {required String equipmentInstanceId}) =>
    _call('enhanceEquipment', {...meta.toJson(), 'equipmentInstanceId': equipmentInstanceId});

// ---- schedule --------------------------------------------------------------

/// `getServerTime`은 유일하게 요청 바디가 없는 Callable이라 [RequestMeta]도
/// 안 받는다 — 응답도 화면이 바로 쓰기 좋게 `DateTime`으로 바꿔서 돌려준다.
Future<DateTime> getServerTime() async {
  final data = await _call('getServerTime', const {});
  return DateTime.fromMillisecondsSinceEpoch(data['nowMs'] as int, isUtc: true);
}

// ---- dungeon ---------------------------------------------------------------

Future<Map<String, dynamic>> sweepDungeon(
  RequestMeta meta, {
  required String dungeonId,
  required int difficulty,
  required int times,
}) => _call('sweepDungeon', {...meta.toJson(), 'dungeonId': dungeonId, 'difficulty': difficulty, 'times': times});

Future<Map<String, dynamic>> claimDeepForestRewards(RequestMeta meta, {required int upToFloor}) =>
    _call('claimDeepForestRewards', {...meta.toJson(), 'upToFloor': upToFloor});

// ---- exchange ----------------------------------------------------------

Future<Map<String, dynamic>> exchangeItems(RequestMeta meta, {required String entryId, int? times}) =>
    _call('exchangeItems', {...meta.toJson(), 'entryId': entryId, 'times': ?times});

// ---- gacha -------------------------------------------------------------

Future<Map<String, dynamic>> gachaPull(RequestMeta meta, {required String bannerId, required int count}) =>
    _call('gachaPull', {...meta.toJson(), 'bannerId': bannerId, 'count': count});

Future<Map<String, dynamic>> exchangePickup(RequestMeta meta, {required String bannerId, required String characterId}) =>
    _call('exchangePickup', {...meta.toJson(), 'bannerId': bannerId, 'characterId': characterId});

// ---- purchase ------------------------------------------------------------

Future<Map<String, dynamic>> verifyPurchase(
  RequestMeta meta, {
  required String productId,
  required String platform,
  required String receipt,
}) => _call('verifyPurchase', {...meta.toJson(), 'productId': productId, 'platform': platform, 'receipt': receipt});

// ---- mission / mail --------------------------------------------------------

Future<Map<String, dynamic>> claimMission(RequestMeta meta, {required String missionId}) =>
    _call('claimMission', {...meta.toJson(), 'missionId': missionId});

Future<Map<String, dynamic>> claimMail(RequestMeta meta, {required String mailId}) =>
    _call('claimMail', {...meta.toJson(), 'mailId': mailId});
