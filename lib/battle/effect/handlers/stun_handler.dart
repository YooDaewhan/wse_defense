import '../../constants.dart';
import '../../entity/battle_entity.dart';
import '../../entity/entity_state.dart';
import '../../stat/modifier_source.dart';
import '../../world/battle_world.dart';
import '../effect.dart';
import '../effect_instance.dart';
import '../effect_params.dart';

/// 03_BATTLE_ENGINE.md §10.1 멈칫: 같은 효과는 max(잔여, 신규)로 갱신하고
/// 합산하지 않는다. 종료 후 30틱 재적용 면역. `action=stunned`는 이미
/// AttackSystem(T-09)/MovementSystem(T-08)이 확인하므로 그쪽 타이머들이
/// 저절로 멈춘다 — 여기서 추가로 막을 게 없다.
class StunHandler extends EffectHandler {
  @override
  String get type => 'STUN';

  @override
  void apply(BattleWorld w, BattleEntity target, EffectParams p, ModifierSource src) {
    if (w.tick < target.stunImmuneUntilTick) return; // 면역 중

    final existing = _find(target);
    if (existing != null) {
      if (p.durationTicks > existing.ticksLeft) existing.ticksLeft = p.durationTicks;
    } else {
      target.effects.add(
        EffectInstance(type: type, source: src, params: p, ticksLeft: p.durationTicks),
      );
    }
    target.action = EntityAction.stunned;
  }

  @override
  void onRemove(BattleWorld w, BattleEntity target, EffectInstance inst) {
    target.action = EntityAction.idle;
    target.stunImmuneUntilTick = w.tick + stunImmuneTicks;
  }

  EffectInstance? _find(BattleEntity target) {
    for (final e in target.effects) {
      if (e.type == type) return e;
    }
    return null;
  }
}
