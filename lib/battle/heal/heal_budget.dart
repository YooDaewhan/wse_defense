import '../entity/battle_entity.dart';

/// 03_BATTLE_ENGINE.md §9.2: "날씨 회복 + 토닥임 합산 총 주기 회복은 대상
/// 최대HP의 2%/초 상한". 밀리퍼센트 단위 요청량을, 이번 "초"(월드 tick
/// 기준 정확히 30틱 간격으로 리셋 — 회복 효과 각각의 시작 시점과는 무관)에
/// 남은 예산만큼만 승인하고 그만큼 예산을 소비한다. 요청이 예산을 넘으면
/// 초과분은 그냥 버려진다(다음 초까지 이월 없음).
int grantFromHealBudget(BattleEntity target, int requestedPct, int capPct) {
  if (requestedPct <= 0) return 0;
  final remaining = capPct - target.healBudgetUsedPctThisSecond;
  if (remaining <= 0) return 0;
  final granted = requestedPct > remaining ? remaining : requestedPct;
  target.healBudgetUsedPctThisSecond += granted;
  return granted;
}
