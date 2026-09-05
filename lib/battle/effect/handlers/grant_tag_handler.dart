import '../../entity/battle_entity.dart';
import '../../stat/modifier_source.dart';
import '../../tag/tag_contribution.dart';
import '../../world/battle_world.dart';
import '../effect.dart';
import '../effect_instance.dart';
import '../effect_params.dart';

/// 03_BATTLE_ENGINE.md §10.1 GRANT_TAG: 태그 부여 -> 유닛 스코프는
/// `onUnitTagsChanged`가 즉시 반영한다. FIELD 스코프는 그 함수가 손대지
/// 않으므로(T-15) 다음 resolveField() 주기(2초)까지 자연히 미뤄진다.
class GrantTagHandler extends EffectHandler {
  @override
  String get type => 'GRANT_TAG';

  @override
  void apply(BattleWorld w, BattleEntity target, EffectParams p, ModifierSource src) {
    target.tagContribs.add(
      TagContribution(
        tagIndex: p.tagIndex,
        amount: p.tagAmount,
        kind: TagSourceKind.buff,
        sourceId: src.id,
      ),
    );
    w.tagEffectResolver.onUnitTagsChanged(w, target);
    target.effects.add(
      EffectInstance(type: type, source: src, params: p, ticksLeft: p.durationTicks),
    );
  }

  @override
  void onRemove(BattleWorld w, BattleEntity target, EffectInstance inst) {
    target.tagContribs.removeWhere(
      (c) => c.sourceId == inst.source.id && c.kind == TagSourceKind.buff,
    );
    w.tagEffectResolver.onUnitTagsChanged(w, target);
  }
}
