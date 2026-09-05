import '../stat/modifier_source.dart';
import 'effect_params.dart';

/// 유닛에 붙은 활성 효과 하나. `durationTicks == 0`은 "조건부 상시"라
/// StatusSystem이 자동으로 만료시키지 않는다(수동 제거만).
class EffectInstance {
  EffectInstance({
    required this.type,
    required this.source,
    required this.params,
    required this.ticksLeft,
  });

  final String type; // "STUN", "SLOW", ...
  final ModifierSource source;
  final EffectParams params;
  int ticksLeft;

  /// HEAL(토닥임)처럼 매 틱이 아니라 intervalTicks마다 처리해야 하는
  /// 핸들러가 쓰는 누적 카운터.
  int tickAccumulator = 0;
}
