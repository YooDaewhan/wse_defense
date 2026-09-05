// 골든 리플레이 3개를 (재)생성하는 1회성 개발자 스크립트.
// `flutter test`는 `*_test.dart`만 실행하므로 이 파일은 자동으로 돌지 않는다
// — 시나리오나 밸런스를 의도적으로 바꿔 골든을 갱신해야 할 때만 수동 실행:
//   dart run test/battle/golden_replay/generate_golden.dart
//
// 09_MILESTONES.md T-20 완료조건: "골든 리플레이 3개 저장 및 CI에서 회귀 검사".
// 회귀 검사 쪽은 golden_replay_test.dart가 맡는다.
import 'dart:convert';
import 'dart:io';

import 'package:wse_defense/battle/world/input_log.dart';

import '../support/replay_scenario.dart';

const _seeds = [1001, 2002, 3003];
const _totalTicks = 300 * 30;

void main() {
  final dir = Directory('test/battle/golden_replay');
  for (final seed in _seeds) {
    final inputs = scriptedInputs(seed);
    final world = buildScenarioWorld(seed);
    replay(world, inputs, _totalTicks);

    final log = InputLog(
      seed: seed,
      dataVersion: 'v1',
      stageId: 'STG_TEST_REPLAY',
      inputs: inputs,
      formationHash: 'FORMATION_HASH_TEST',
    );

    File('${dir.path}/scenario_$seed.inputlog').writeAsBytesSync(log.encode());
    File('${dir.path}/scenario_$seed.expected.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({
        'seed': seed,
        'totalTicks': _totalTicks,
        'finalTick': world.tick,
        'finalPhase': world.phase.index,
        'finalOutcome': world.outcome?.index,
        'finalChecksum': world.checksum(),
      }),
    );
    stdout.writeln('scenario_$seed 저장 완료 (checksum=${world.checksum()})');
  }
}
