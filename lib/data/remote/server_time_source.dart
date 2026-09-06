import 'package:cloud_functions/cloud_functions.dart';

/// [lib/app/bootstrap.dart]와 같은 이유로 단위 테스트하지 않는 얇은 배관 —
/// `getServerTime` 콜러블을 그대로 감싼다.
Future<DateTime> fetchServerTimeUtc() async {
  final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3').httpsCallable('getServerTime');
  final result = await callable.call<Map<String, dynamic>>();
  final nowMs = result.data['nowMs'] as int;
  return DateTime.fromMillisecondsSinceEpoch(nowMs, isUtc: true);
}
