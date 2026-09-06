import '../../entity/battle_entity.dart';
import '../../stat/modifier.dart';
import '../../stat/modifier_source.dart';
import '../../stat/stat_key.dart';
import '../../world/battle_world.dart';
import '../effect.dart';
import '../effect_instance.dart';
import '../effect_params.dart';

/// 03_BATTLE_ENGINE.md §10.1 기죽이기(ATK_DOWN): "같은 계열 최강 효과만
/// 적용" — `exclusiveGroup: 'ATK_DOWN'`을 고정으로 걸어서 여러 출처의
/// 기죽이기가 동시에 걸려도 `StatSheet`가 절대값이 가장 큰 것 하나만
/// 남긴다(§10.2, T-05~T-09에서 이미 구현된 일반 메커니즘 재사용).
class AtkDownHandler extends EffectHandler {
  @override
  String get type => 'ATK_DOWN';

  @override
  void apply(BattleWorld w, BattleEntity target, EffectParams p, ModifierSource src) {
    target.effects.removeWhere((e) => e.type == type && e.source.id == src.id);
    target.stats.removeBySource(src.kind, src.id);
    target.stats.addModifier(
      StatModifier(stat: StatKey.atk, op: ModOp.pctAdd, value: p.atkPct, source: src, exclusiveGroup: 'ATK_DOWN'),
    );
    target.effects.add(EffectInstance(type: type, source: src, params: p, ticksLeft: p.durationTicks));
  }

  @override
  void onRemove(BattleWorld w, BattleEntity target, EffectInstance inst) {
    target.stats.removeBySource(inst.source.kind, inst.source.id);
  }
}
