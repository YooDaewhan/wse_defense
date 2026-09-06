import '../../constants.dart';
import '../../entity/battle_entity.dart';
import '../../heal/heal_budget.dart';
import '../../stat/modifier_source.dart';
import '../../stat/stat_key.dart';
import '../../world/battle_world.dart';
import '../effect.dart';
import '../effect_instance.dart';
import '../effect_params.dart';

/// 03_BATTLE_ENGINE.md §10.1 토닥임(HOT): 같은 종류(exclusiveGroup, 보통
/// `"HOT_<skillId>"`)의 동일 회복은 중첩하지 않고 대상당 가장 강한 주기
/// 회복만 유지한다. 매 intervalTicks마다 회복하되 최대HP를 넘지 않는다.
class HealHandler extends EffectHandler {
  @override
  String get type => 'HEAL';

  @override
  void apply(BattleWorld w, BattleEntity target, EffectParams p, ModifierSource src) {
    final strength = p.amount.abs() + p.pctOfMaxHp.abs();

    if (p.exclusiveGroup != null) {
      for (final existing in List.of(target.effects)) {
        if (existing.type != type) continue;
        if (existing.params.exclusiveGroup != p.exclusiveGroup) continue;
        final existingStrength =
            existing.params.amount.abs() + existing.params.pctOfMaxHp.abs();
        if (existingStrength >= strength) return; // 기존이 더 강하거나 동급 -> 새 걸 무시
        target.effects.remove(existing); // 새 게 더 강함 -> 기존 제거
      }
    }

    target.effects.add(
      EffectInstance(type: type, source: src, params: p, ticksLeft: p.durationTicks),
    );
  }

  @override
  void onTick(BattleWorld w, BattleEntity target, EffectInstance inst) {
    inst.tickAccumulator++;
    if (inst.tickAccumulator < inst.params.intervalTicks) return;
    inst.tickAccumulator = 0;

    // 03_BATTLE_ENGINE.md §9.2: 날씨의 아군 회복 보정(healReceived)이 여기도
    // 걸린다. "회복 총량 상한 2%/초"는 정률(pctOfMaxHp) 회복분만 예산을
    // 태운다 — 고정치(amount) 회복은 문서가 상한을 %로만 얘기해 스코프 밖.
    final maxHp = target.stats.get(StatKey.maxHp);
    final healReceivedPct = target.stats.get(StatKey.healReceived);
    final scaledFlat = inst.params.amount * (pctScale + healReceivedPct) ~/ pctScale;
    final scaledPctOfMax = inst.params.pctOfMaxHp * (pctScale + healReceivedPct) ~/ pctScale;
    final grantedPct = grantFromHealBudget(target, scaledPctOfMax, w.config.weatherConfig.healCapPctPerSec);

    final healAmount = scaledFlat + maxHp * grantedPct ~/ pctScale;
    final before = target.hp;
    var next = target.hp + healAmount;
    if (next > maxHp) next = maxHp; // 최대HP 초과 불가
    target.hp = next;

    // §9.1: "실제 HP 회복... 수행" — 이미 최대HP라 그대로인 회복은 활약이
    // 아니다.
    if (next > before) w.recordWeatherActivity(target);
  }
}
