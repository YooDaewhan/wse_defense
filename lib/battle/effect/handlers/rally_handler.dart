import '../../constants.dart';
import '../../entity/battle_entity.dart';
import '../../stat/modifier.dart';
import '../../stat/modifier_source.dart';
import '../../stat/stat_key.dart';
import '../../system/pending_damage.dart';
import '../../world/battle_world.dart';
import '../effect.dart';
import '../effect_instance.dart';
import '../effect_params.dart';

/// 03_BATTLE_ENGINE.md §10.1 기운내기(RALLY): 자기 최대HP `selfCostPct`
/// 소비. **HP가 그 비용 이하면 발동 자체가 안 된다**(버프도, 비용도
/// 없음). 비용은 `DamageKind.selfCost`로 큐잉해 DamageSystem이 처리하게
/// 한다 — 그래야 "자기비용은 자연 넉백·날씨 활약을 만들지 않는다"(T-45에서
/// 이미 그렇게 분기해둔 경로)가 저절로 성립한다.
class RallyHandler extends EffectHandler {
  @override
  String get type => 'RALLY';

  @override
  void apply(BattleWorld w, BattleEntity target, EffectParams p, ModifierSource src) {
    final maxHp = target.stats.get(StatKey.maxHp);
    final cost = maxHp * p.selfCostPct ~/ pctScale;
    if (target.hp <= cost) return; // 발동 안 함 -- 버프도 비용도 없음

    target.effects.removeWhere((e) => e.type == type && e.source.id == src.id);
    target.stats.removeBySource(src.kind, src.id);
    for (final m in p.mods) {
      target.stats.addModifier(
        StatModifier(stat: m.stat, op: m.op, value: m.value, source: src, exclusiveGroup: m.exclusiveGroup),
      );
    }
    target.effects.add(EffectInstance(type: type, source: src, params: p, ticksLeft: p.durationTicks));

    w.pendingDamage.add(
      PendingDamage(targetId: target.id, sourceId: target.id, amount: cost, kind: DamageKind.selfCost),
    );
    w.recordWeatherActivity(target); // 버프 적용 자체는 활약으로 인정
  }

  @override
  void onRemove(BattleWorld w, BattleEntity target, EffectInstance inst) {
    target.stats.removeBySource(inst.source.kind, inst.source.id);
  }
}
