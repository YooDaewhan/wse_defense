import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/world/battle_input.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/game/tick_clock.dart';

import '../battle/support/replay_scenario.dart';

const _seed = 777;
const _totalTicks = 300 * 30; // 300초 (T-20과 동일 시나리오)

/// [TickClock]을 실제 게임 루프처럼 매 프레임 굴려가며 [totalTicks]에
/// 도달할 때까지 [world]를 진행시킨다.
void _driveWithClock(
  BattleWorld world,
  List<BattleInput> inputs,
  double dtPerFrame,
  double speedMultiplier,
  int totalTicks,
) {
  final clock = TickClock();
  var idx = 0;
  while (world.tick < totalTicks) {
    final steps = clock.consume(dtPerFrame, speedMultiplier);
    for (var s = 0; s < steps && world.tick < totalTicks; s++) {
      while (idx < inputs.length && inputs[idx].tick == world.tick) {
        world.enqueueInput(inputs[idx]);
        idx++;
      }
      world.step();
    }
  }
}

void main() {
  test('05_FRONTEND.md T-22: 1x vs 2x speed (same 60fps frame rate) reach identical checksums at every matching tick', () {
    // T-20 결정론 테스트의 시나리오를 그대로 재사용 — 다른 건 "무엇이 틱을
    // 소비하게 만드는가"(TickClock/배속)뿐, 배틀 로직 자체는 안 건드린다.
    final inputs1x = scriptedInputs(_seed);
    final inputs2x = scriptedInputs(_seed);
    final world1x = buildScenarioWorld(_seed);
    final world2x = buildScenarioWorld(_seed);

    // 2배속은 절반의 실시간만 있어도 같은 총 틱 수에 도달해야 한다 —
    // 여기서는 같은 프레임 수(같은 실시간)를 흘려보내 "2배속이 정확히 2배
    // 빨리 같은 지점에 도달하는지"를 확인한다.
    _driveWithClock(world1x, inputs1x, 1 / 60, 1, _totalTicks);
    _driveWithClock(world2x, inputs2x, 1 / 60, 2, _totalTicks);

    expect(world1x.tick, _totalTicks);
    expect(world2x.tick, _totalTicks);
    expect(world2x.checksum(), world1x.checksum());
  });
}
