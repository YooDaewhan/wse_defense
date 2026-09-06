import '../../constants.dart';
import '../../entity/battle_entity.dart';
import '../../stat/modifier_source.dart';
import '../../stat/stat_key.dart';
import '../../world/battle_world.dart';
import '../effect.dart';
import '../effect_instance.dart';
import '../effect_params.dart';

/// 03_BATTLE_ENGINE.md §10.1 껍질(SHELL): "`shieldHp` 별도 필드. 초과분
/// 본체 이월. 자연 넉백은 본체 HP 기준." — 흡수·이월·자연넉백 판정은
/// 전부 `BattleEntity.shieldHp`/`DamageSystem`이 이미 하고 있는 일이라
/// (T-10) 여기서는 그 필드를 채우고 만료 시 정리하기만 한다.
class ShellHandler extends EffectHandler {
  @override
  String get type => 'SHELL';

  @override
  void apply(BattleWorld w, BattleEntity target, EffectParams p, ModifierSource src) {
    final maxHp = target.stats.get(StatKey.maxHp);
    final granted = p.amount + maxHp * p.pctOfMaxHp ~/ pctScale;
    target.shieldHp += granted;
    target.effects.add(EffectInstance(type: type, source: src, params: p, ticksLeft: p.durationTicks));
  }

  @override
  void onRemove(BattleWorld w, BattleEntity target, EffectInstance inst) {
    final maxHp = target.stats.get(StatKey.maxHp);
    final granted = inst.params.amount + maxHp * inst.params.pctOfMaxHp ~/ pctScale;
    target.shieldHp -= granted;
    if (target.shieldHp < 0) target.shieldHp = 0;
  }
}
