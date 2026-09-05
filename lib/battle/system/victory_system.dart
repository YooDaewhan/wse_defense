import '../constants.dart';
import '../world/battle_world.dart';
import 'battle_system.dart';

/// 03_BATTLE_ENGINE.md 시스템 표 #15: 기지 파괴/시간 초과 판정.
///
/// `BattleWorld.step()`이 이미 `phase != running`이면 시스템을 하나도 돌리지
/// 않으므로, 여기서 결과를 한 번 정하고 `phase = finished`로 바꾸면 그
/// 다음 틱부터는 이 시스템 자체가 호출되지 않는다 — 결과가 다시 바뀔 일이
/// 없다.
class VictorySystem implements BattleSystem {
  @override
  void execute(BattleWorld w) {
    final allyDestroyed = w.allyBase.hp <= 0;
    final enemyDestroyed = w.enemyBase.hp <= 0;

    if (allyDestroyed && enemyDestroyed) {
      _end(w, BattleOutcome.draw);
      return;
    }
    if (allyDestroyed) {
      _end(w, BattleOutcome.enemyWin);
      return;
    }
    if (enemyDestroyed) {
      _end(w, BattleOutcome.allyWin);
      return;
    }

    if (w.tick >= w.config.stage.timeLimitSec * ticksPerSec) {
      _end(w, BattleOutcome.timeout);
    }
  }

  void _end(BattleWorld w, BattleOutcome outcome) {
    w.outcome = outcome;
    w.phase = BattlePhase.finished;
  }
}
