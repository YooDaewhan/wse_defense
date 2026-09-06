import '../../application/app_scope.dart';
import '../../domain/account/account_state.dart';
import 'api.dart' as api;

/// 10_WIRING_PLAN.md T-60: [BattleSubmitQueue]가 저장해 둔(Map) payload를
/// 다시 typed `submitBattle` 호출로 되돌리고, 성공하면 그 자리에서
/// AccountState에 보상을 반영한다 -- 즉시 성공이든(정상 경로) 나중에 큐를
/// 통해 재시도해서 성공이든(오프라인 복귀) 이 함수 하나만 거치면 항상
/// 같은 방식으로 AccountState가 갱신된다.
///
/// 실제 네트워크 호출을 감싸는 얇은 플러밍이라(lib/app/bootstrap.dart와
/// 같은 이유) 단위 테스트하지 않는다 -- payload 파싱은 submitBattle을
/// 호출할 때 쓰는 값 그대로 왕복시키는 것뿐이고, patch 반영 자체는
/// `AccountState.applyPatch`(테스트 있음)에 위임한다.
Future<void> Function(Map<String, dynamic> payload) submitBattlePayloadFn(AppScope scope) {
  return (payload) async {
    final result = await api.submitBattle(
      api.RequestMeta(
        idempotencyKey: payload['idempotencyKey'] as String,
        appVersion: payload['appVersion'] as String,
        dataVersion: payload['dataVersion'] as String,
      ),
      battleId: payload['battleId'] as String,
      outcome: payload['outcome'] as String,
      summary: Map<String, dynamic>.from(payload['summary'] as Map),
      inputLog: payload['inputLog'] as String,
      formationHash: payload['formationHash'] as String,
    );
    scope.setAccount(scope.account.applyPatch(result['patch'] as Map<String, dynamic>?));
  };
}
