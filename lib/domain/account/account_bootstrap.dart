import 'account_state.dart';

/// 10_WIRING_PLAN.md T-63 준비: `bootstrapAccount`(06_BACKEND.md §6.1)의
/// 응답(`data`: profile/growth/currency/progress/settings)과 별도로 읽은
/// 캐릭터 보유 목록을 하나의 [AccountState]로 합친다. 순수 함수라 실제
/// Firebase 호출(main.dart)과 분리해 테스트한다.
AccountState accountStateFromBootstrap(Map<String, dynamic> data, Set<String> ownedCharacterIds) {
  final clearedStages = Map<String, dynamic>.from(data['progress']?['clearedStages'] as Map? ?? {});
  return const AccountState(gold: 0, ownedCharacterIds: {})
      .applyPatch({'currency': data['currency'], 'growth': data['growth']})
      .copyWith(ownedCharacterIds: ownedCharacterIds, clearedStageIds: clearedStages.keys.toSet());
}
