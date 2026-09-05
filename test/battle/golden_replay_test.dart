import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/world/input_log.dart';

import 'support/replay_scenario.dart';

const _seeds = [1001, 2002, 3003];

/// 09_MILESTONES.md T-20: "골든 리플레이 3개 저장 및 CI에서 회귀 검사".
/// 골든 자체는 test/battle/golden_replay/generate_golden.dart가 만든다 —
/// 밸런스 수정 후 이 테스트가 깨지면 §14의 규칙대로 "의도한 변경인지
/// 확인하고" 그 스크립트를 다시 돌려 골든을 갱신한다.
void main() {
  for (final seed in _seeds) {
    test('golden replay scenario_$seed reproduces its saved checksum', () {
      final dir = 'test/battle/golden_replay';
      final bytes = File('$dir/scenario_$seed.inputlog').readAsBytesSync();
      final expected =
          jsonDecode(File('$dir/scenario_$seed.expected.json').readAsStringSync())
              as Map<String, Object?>;

      final log = InputLog.decode(bytes);
      expect(log.seed, seed);
      expect(log.stageId, 'STG_TEST_REPLAY');

      final world = buildScenarioWorld(log.seed);
      replay(world, log.inputs, expected['totalTicks'] as int);

      expect(world.tick, expected['finalTick']);
      expect(world.phase.index, expected['finalPhase']);
      expect(world.outcome?.index, expected['finalOutcome']);
      expect(world.checksum(), expected['finalChecksum']);
    });
  }
}
