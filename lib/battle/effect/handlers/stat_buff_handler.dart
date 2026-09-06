import '../../entity/battle_entity.dart';
import '../../stat/modifier.dart';
import '../../stat/modifier_source.dart';
import '../../world/battle_world.dart';
import '../effect.dart';
import '../effect_instance.dart';
import '../effect_params.dart';

/// 04_DATA_SCHEMA.md §6.1 STAT_BUFF. `durationTicks: 0`은 "조건 유지되는
/// 동안"(조건부 상시)이라 StatusSystem이 자동 만료시키지 않는다 — 조건이
/// 실제로 꺼졌을 때 다시 지우는 건 그 조건을 아는 호출부(스킬 트리거,
/// T-18)의 몫이라 여기서는 만들지 않는다.
class StatBuffHandler extends EffectHandler {
  @override
  String get type => 'STAT_BUFF';

  @override
  void apply(BattleWorld w, BattleEntity target, EffectParams p, ModifierSource src) {
    target.effects.removeWhere((e) => e.type == type && e.source.id == src.id);
    target.stats.removeBySource(src.kind, src.id);
    for (final m in p.mods) {
      target.stats.addModifier(
        StatModifier(
          stat: m.stat,
          op: m.op,
          value: m.value,
          source: src,
          exclusiveGroup: m.exclusiveGroup,
        ),
      );
    }
    target.effects.add(
      EffectInstance(type: type, source: src, params: p, ticksLeft: p.durationTicks),
    );
    // 03_BATTLE_ENGINE.md §9.1: "버프 적용... 수행"도 활약으로 친다.
    w.recordWeatherActivity(target);
  }

  @override
  void onRemove(BattleWorld w, BattleEntity target, EffectInstance inst) {
    target.stats.removeBySource(inst.source.kind, inst.source.id);
  }
}
