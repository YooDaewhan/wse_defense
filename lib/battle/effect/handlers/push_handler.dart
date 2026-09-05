import '../../constants.dart';
import '../../entity/battle_entity.dart';
import '../../stat/modifier_source.dart';
import '../../system/knockback_trigger.dart';
import '../../world/battle_world.dart';
import '../effect.dart';
import '../effect_params.dart';

/// 03_BATTLE_ENGINE.md §10.1 밀치기: 강제 넉백. 보스는 거리 50%(공용
/// [triggerForcedKnockback]가 처리), `forcedKbImmuneUntilTick` 확인.
/// 이 효과 자체도 대상별로 3초(pushCooldownTicks) 재적용 대기를 따로 둔다
/// (넉백 시스템의 1초 면역과는 별개 — 밀치기 스킬 고유의 쿨다운).
///
/// 순간적으로 트리거만 걸고 끝나는 효과라 EffectInstance를 남기지 않는다
/// (onTick/onRemove 기본 구현 그대로 사용).
class PushHandler extends EffectHandler {
  @override
  String get type => 'PUSH';

  @override
  void apply(BattleWorld w, BattleEntity target, EffectParams p, ModifierSource src) {
    if (w.tick < target.pushImmuneUntilTick) return;

    final before = target.knockbackTicksLeft;
    triggerForcedKnockback(w, target, p.distance);
    if (target.knockbackTicksLeft <= before) return; // 트리거 실패(면역/이미 넉백 등)

    target.pushImmuneUntilTick = w.tick + pushCooldownTicks;
  }
}
