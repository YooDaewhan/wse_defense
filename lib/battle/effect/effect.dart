import '../entity/battle_entity.dart';
import '../stat/modifier_source.dart';
import '../world/battle_world.dart';
import 'effect_instance.dart';
import 'effect_params.dart';

/// 03_BATTLE_ENGINE.md §10.
abstract class EffectHandler {
  String get type; // "STUN", "SLOW", "PUSH", "HEAL", ...

  /// 적용 시도. 이미 있으면 갱신 정책에 따라 처리.
  void apply(BattleWorld w, BattleEntity target, EffectParams p, ModifierSource src);

  /// 매 틱 처리 (필요한 경우만)
  void onTick(BattleWorld w, BattleEntity target, EffectInstance inst) {}

  /// 제거 시 정리
  void onRemove(BattleWorld w, BattleEntity target, EffectInstance inst) {}
}
