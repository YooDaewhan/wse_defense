import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/battle/world/input_log.dart';

import 'support/replay_scenario.dart';

const _seed = 12345;
const _totalTicks = 300 * 30; // 300초 (09_MILESTONES.md T-20 완료조건)

void main() {
  test('same seed+input replayed twice over a 300s battle -> identical checksum every tick', () {
    final inputs = scriptedInputs(_seed);
    final a = buildScenarioWorld(_seed);
    final b = buildScenarioWorld(_seed);

    var idxA = 0;
    var idxB = 0;
    for (var t = 0; t < _totalTicks; t++) {
      while (idxA < inputs.length && inputs[idxA].tick == a.tick) {
        a.enqueueInput(inputs[idxA]);
        idxA++;
      }
      while (idxB < inputs.length && inputs[idxB].tick == b.tick) {
        b.enqueueInput(inputs[idxB]);
        idxB++;
      }
      a.step();
      b.step();
      expect(b.checksum(), a.checksum(), reason: 'tick $t에서 체크섬이 갈렸다');
    }
  });

  test('serialize at an arbitrary tick -> deserialize -> continue matches an uninterrupted run', () {
    const midTick = 3000;
    final inputs = scriptedInputs(_seed);

    final uninterrupted = buildScenarioWorld(_seed);
    replay(uninterrupted, inputs, _totalTicks);

    final interrupted = buildScenarioWorld(_seed);
    replay(interrupted, inputs, midTick);
    final snapshot = interrupted.serialize();

    final resumed = BattleWorld.deserialize(
      snapshot,
      config: buildScenarioConfig(),
      datapack: buildScenarioDatapack(),
      rngSeed: _seed,
      systems: buildScenarioSystems(),
    );
    // 남은 입력만 이어서 재생 (이미 소비된 입력은 replay()가 w.tick 기준으로 건너뜀).
    replay(resumed, inputs, _totalTicks);

    expect(resumed.serialize(), equals(uninterrupted.serialize()));
    expect(resumed.checksum(), uninterrupted.checksum());
  });

  test('InputLog.encode/decode round-trips the scripted schedule losslessly', () {
    final inputs = scriptedInputs(_seed);
    final log = InputLog(
      seed: _seed,
      dataVersion: 'v1',
      stageId: 'STG_TEST_REPLAY',
      inputs: inputs,
      formationHash: 'FORMATION_HASH_TEST',
    );

    final decoded = InputLog.decode(log.encode());

    expect(decoded.seed, log.seed);
    expect(decoded.dataVersion, log.dataVersion);
    expect(decoded.stageId, log.stageId);
    expect(decoded.formationHash, log.formationHash);
    expect(decoded.inputs.length, inputs.length);
    for (var i = 0; i < inputs.length; i++) {
      expect(decoded.inputs[i].tick, inputs[i].tick);
      expect(decoded.inputs[i].runtimeType, inputs[i].runtimeType);
    }
  });
}
