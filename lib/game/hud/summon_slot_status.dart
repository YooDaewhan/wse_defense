import '../../battle/constants.dart';
import '../../battle/world/battle_world.dart';

/// 05_FRONTEND.md §7 "소환 슬롯 상태 표시" 5종.
enum SummonSlotStatus {
  ready,
  notEnoughPrayer,
  onCooldown,
  costExceedsCap,
  unitCapReached,

  /// 편성 슬롯 범위를 벗어남 — 실제 UI에는 나타나지 않는(빈 칸) 방어값.
  invalidSlot,
}

/// `trySummon`(world/summon.dart)과 완전히 같은 순서로 판정하는 읽기 전용
/// 미리보기 — 상태 표시가 실제로 탭했을 때 벌어질 일과 어긋나지 않도록
/// 같은 우선순위를 그대로 따른다. world를 바꾸지 않는다.
SummonSlotStatus summonSlotStatus(BattleWorld w, int slotIndex) {
  if (slotIndex < 0 || slotIndex >= w.formation.length) {
    return SummonSlotStatus.invalidSlot;
  }
  final slot = w.formation[slotIndex];
  final cost = slot.def.base.summonCost;
  final cap = w.currentPrayerCap;

  if (cost > cap) return SummonSlotStatus.costExceedsCap;
  if (w.prayerPower < cost) return SummonSlotStatus.notEnoughPrayer;
  if (slot.cooldownLeft > 0) return SummonSlotStatus.onCooldown;
  if (w.allyAliveCount >= unitCap) return SummonSlotStatus.unitCapReached;
  return SummonSlotStatus.ready;
}

/// 05_FRONTEND.md §7: "기도력 게이지는 다음 소환 가능 시점을 눈금으로
/// 표시한다" — 기도력 부족으로 막힌 슬롯 하나가 감당 가능해지기까지 남은
/// 틱 수. ResourceSystem과 동일한 회복 공식(초당 회복량)을 그대로 쓴다.
/// 감당 가능(또는 애초에 기도력 부족이 원인이 아님)하면 0.
int ticksUntilAffordable(BattleWorld w, int slotIndex) {
  if (slotIndex < 0 || slotIndex >= w.formation.length) return 0;
  final cost = w.formation[slotIndex].def.base.summonCost;
  final missing = cost - w.prayerPower;
  if (missing <= 0) return 0;

  final perSec = w.config.focusBaseRegen + w.config.focusBoostBonus[w.focusBoostStage];
  final weathered = perSec * w.weatherRegenPct ~/ pctScale;
  if (weathered <= 0) return 1 << 30; // 회복이 없으면 사실상 무한대

  return (missing * ticksPerSec + weathered - 1) ~/ weathered; // 올림
}
