import '../constants.dart';
import '../tag/tag_query.dart';
import 'battle_world.dart';

enum SummonResult {
  ok,
  invalidSlot,
  costExceedsCap,
  notEnoughPrayer,
  onCooldown,
  unitCapReached,
}

/// 03_BATTLE_ENGINE.md §8.1. 실패 시 기도력 차감 없음 — 성공할 때만 차감한다.
///
/// `TagEffectResolver.resolveUnitOnSpawn`(T-15)과
/// `SkillTriggerRunner.onSpawn`(T-18)은 아직 없어 생략한다.
SummonResult trySummon(BattleWorld w, int slotIndex) {
  if (slotIndex < 0 || slotIndex >= w.formation.length) {
    return SummonResult.invalidSlot;
  }
  final slot = w.formation[slotIndex];
  final cost = slot.def.base.summonCost; // 태그·장비 반영된 최종값(태그 반영은 T-15 이후)
  final cap = w.currentPrayerCap;

  if (cost > cap) return SummonResult.costExceedsCap;
  if (w.prayerPower < cost) return SummonResult.notEnoughPrayer;
  if (slot.cooldownLeft > 0) return SummonResult.onCooldown;
  if (w.allyAliveCount >= unitCap) return SummonResult.unitCapReached;

  w.prayerPower -= cost; // ★ 성공 시에만 차감
  slot.cooldownLeft = slot.def.base.resummonCooldownSec * ticksPerSec;
  w.spawnEntity(slot.def, Side.ally, w.allyBase.x);
  return SummonResult.ok;
}
