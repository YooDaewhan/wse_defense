import '../../constants.dart';
import '../../entity/battle_entity.dart';
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

    final maxHp = target.stats.get(StatKey.maxHp);
    final healAmount = inst.params.amount + maxHp * inst.params.pctOfMaxHp ~/ pctScale;
    var next = target.hp + healAmount;
    if (next > maxHp) next = maxHp; // 최대HP 초과 불가
    target.hp = next;
  }
}
