import '../../entity/battle_entity.dart';
import '../../stat/modifier.dart';
import '../../stat/modifier_source.dart';
import '../../stat/stat_key.dart';
import '../../world/battle_world.dart';
import '../effect.dart';
import '../effect_instance.dart';
import '../effect_params.dart';

/// 03_BATTLE_ENGINE.md §10.1 느릿: 이동 -30%, 공격 주기 x1.25(=빈도 -20%).
///
/// "다음 공격부터 반영"은 이 핸들러가 할 일이 없다 — AttackSystem(T-09)이
/// windup 시작 시에만 `attackPeriod`를 스냅샷하므로, 진행 중인 사이클
/// 도중에 여기서 MULT 모디파이어를 추가해도 그 사이클엔 영향이 없고
/// 자연스럽게 다음 windup부터 반영된다.
class SlowHandler extends EffectHandler {
  @override
  String get type => 'SLOW';

  @override
  void apply(BattleWorld w, BattleEntity target, EffectParams p, ModifierSource src) {
    // 갱신 정책: 새 적용이 기존 인스턴스를 대체한다(멈칫과 달리 max 규칙 없음).
    target.effects.removeWhere((e) => e.type == type);
    target.stats.removeBySource(src.kind, src.id);
    target.stats.addModifier(
      StatModifier(stat: StatKey.moveSpeed, op: ModOp.pctAdd, value: p.movePct, source: src),
    );
    target.stats.addModifier(
      StatModifier(
        stat: StatKey.attackPeriod,
        op: ModOp.mult,
        value: p.attackPeriodMult,
        source: src,
      ),
    );
    target.effects.add(
      EffectInstance(type: type, source: src, params: p, ticksLeft: p.durationTicks),
    );
  }

  @override
  void onRemove(BattleWorld w, BattleEntity target, EffectInstance inst) {
    target.stats.removeBySource(inst.source.kind, inst.source.id);
  }
}
