import '../../entity/battle_entity.dart';
import '../../stat/modifier_source.dart';
import '../../world/battle_world.dart';
import '../effect.dart';
import '../effect_instance.dart';
import '../effect_params.dart';

/// 03_BATTLE_ENGINE.md §10.1 뚫기(PIERCE): "`pierceTargets: [DEF]`만
/// 무시. 넉백 무적·껍질·보스 피해상한은 무시 못한다." — 스탯 모디파이어가
/// 아니라 공격자에게 붙는 순수 마커라, 실제 DEF 무시는
/// `damage_system.dart`의 `computeDamage`가 `atk.effects`에 이 타입이
/// 있는지 직접 확인한다(껍질 흡수·넉백 판정 등 다른 단계는 그대로 거친다
/// — "이 목록만 무시"의 나머지는 손대지 않는다는 뜻).
class PierceHandler extends EffectHandler {
  @override
  String get type => 'PIERCE';

  @override
  void apply(BattleWorld w, BattleEntity target, EffectParams p, ModifierSource src) {
    target.effects.removeWhere((e) => e.type == type && e.source.id == src.id);
    target.effects.add(EffectInstance(type: type, source: src, params: p, ticksLeft: p.durationTicks));
  }
}
