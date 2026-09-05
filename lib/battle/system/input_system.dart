import '../world/battle_input.dart';
import '../world/battle_world.dart';
import '../world/summon.dart';
import '../world/ultimate.dart';
import 'battle_system.dart';

/// 03_BATTLE_ENGINE.md §3 #1: 이번 틱의 입력 처리. 유효성 검사 후 실행.
///
/// `PageSwitchInput`은 UI 상태일 뿐 시뮬레이션에 영향 없다.
class InputSystem implements BattleSystem {
  @override
  void execute(BattleWorld w) {
    for (final input in w.inputs.take(w.tick)) {
      switch (input) {
        case SummonInput(:final slotIndex):
          trySummon(w, slotIndex);
        case FocusBoostInput(:final stage):
          _tryFocusBoost(w, stage);
        case UltimateInput():
          castUltimate(w);
        case PageSwitchInput():
          break;
      }
    }
  }

  void _tryFocusBoost(BattleWorld w, int stage) {
    if (stage <= w.focusBoostStage) return; // 낮추거나 그대로는 무의미
    if (stage >= w.config.focusBoostCost.length) return;
    final cost = w.config.focusBoostCost[stage];
    if (w.prayerPower < cost) return;
    w.prayerPower -= cost;
    w.focusBoostStage = stage;
  }
}
