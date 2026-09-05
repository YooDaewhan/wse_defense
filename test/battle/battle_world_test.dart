import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';

BattleWorld _newWorld(int seed) => BattleWorld(
  config: const BattleConfig(
    stage: StageDef(
      id: 'STG_TEST',
      index: 1,
      fieldLength: 2400,
      allyBaseX: 0,
      enemyBaseX: 2400,
      enemyBaseHp: 1000,
      timeLimitSec: 300,
    ),
    allyBaseHp: 10000,
  ),
  rngSeed: seed,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
);

void main() {
  test('0 systems: 1000 ticks run without crashing and checksum() returns', () {
    final world = _newWorld(1)..phase = BattlePhase.running;

    for (var i = 0; i < 1000; i++) {
      world.step();
    }

    expect(world.tick, 1000);
    expect(world.checksum(), isA<int>());
  });

  test('step() no-ops while phase is not running', () {
    final world = _newWorld(1); // phase defaults to ready
    world.step();
    expect(world.tick, 0);
  });

  test('checksum is deterministic for the same seed/config after the same ticks', () {
    final a = _newWorld(7)..phase = BattlePhase.running;
    final b = _newWorld(7)..phase = BattlePhase.running;

    for (var i = 0; i < 1000; i++) {
      a.step();
      b.step();
    }

    expect(a.checksum(), b.checksum());
  });
}
