import '../effect/effect_registry.dart';
import '../world/battle_world.dart';
import 'battle_system.dart';

/// 03_BATTLE_ENGINE.md 시스템 표 #8: 상태 효과의 틱 처리(지속피해·주기회복)
/// + 만료 제거. 별도 EffectExpireSystem(#4)을 두지 않고 여기서 같이
/// 처리한다 — 이 티켓 범위에서 굳이 시스템을 둘로 쪼갤 이유가 없다.
///
/// `durationTicks == 0`(조건부 상시)인 인스턴스는 ticksLeft가 0이어도
/// 자동 만료되지 않는다 — 해당 효과 종류가 스스로 챙길 몫.
class StatusSystem implements BattleSystem {
  const StatusSystem();

  @override
  void execute(BattleWorld w) {
    for (final e in w.entities.ordered) {
      if (e.effects.isEmpty) continue;

      for (final inst in List.of(e.effects)) {
        final handler = EffectRegistry.of(inst.type);
        handler?.onTick(w, e, inst);

        if (inst.ticksLeft > 0) inst.ticksLeft--;

        if (inst.ticksLeft <= 0 && inst.params.durationTicks > 0) {
          e.effects.remove(inst);
          handler?.onRemove(w, e, inst);
        }
      }
    }
  }
}
