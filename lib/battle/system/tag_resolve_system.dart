import '../constants.dart';
import '../tag/tag_query.dart';
import '../world/battle_world.dart';
import 'battle_system.dart';

/// 03_BATTLE_ENGINE.md 시스템 표 #5: FIELD_SAMPLE_TICKS(60틱=2초)마다만
/// 필드 스코프를 재평가한다. UNIT/FORMATION 스코프는 스폰 시점/버프 변경
/// 시점에 즉시 반영되므로(TagEffectResolver.resolveUnitOnSpawn/
/// onUnitTagsChanged) 여기서 다시 건드리지 않는다.
class TagResolveSystem implements BattleSystem {
  @override
  void execute(BattleWorld w) {
    if (w.tick % fieldSampleTicks != 0) return;
    w.tagEffectResolver.resolveField(w, Side.ally);
    w.tagEffectResolver.resolveField(w, Side.enemy);
  }
}
