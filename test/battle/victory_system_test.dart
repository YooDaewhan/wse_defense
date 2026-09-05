import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/system/victory_system.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';

BattleWorld _newWorld({int timeLimitSec = 300}) => BattleWorld(
  config: BattleConfig(
    stage: StageDef(
      id: 'STG_TEST',
      index: 1,
      fieldLength: 2400,
      allyBaseX: 0,
      enemyBaseX: 2400,
      enemyBaseHp: 1000,
      timeLimitSec: timeLimitSec,
    ),
    allyBaseHp: 1000,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: [VictorySystem()],
)..phase = BattlePhase.running;

void main() {
  test('enemy base destroyed alone -> allyWin', () {
    final world = _newWorld();
    world.enemyBase.hp = 0;
    world.step();

    expect(world.outcome, BattleOutcome.allyWin);
    expect(world.phase, BattlePhase.finished);
  });

  test('ally base destroyed alone -> enemyWin', () {
    final world = _newWorld();
    world.allyBase.hp = -5; // 파괴급 피해로 음수가 돼도 파괴로 취급
    world.step();

    expect(world.outcome, BattleOutcome.enemyWin);
    expect(world.phase, BattlePhase.finished);
  });

  test('time runs out with both bases standing -> timeout', () {
    final world = _newWorld(timeLimitSec: 10); // 300틱
    var iterations = 0;
    while (world.phase == BattlePhase.running) {
      world.step();
      iterations++;
      if (iterations > 100000) fail('무한 루프: 승부가 갈리지 않음');
    }

    expect(world.outcome, BattleOutcome.timeout);
    expect(world.tick, greaterThanOrEqualTo(300));
  });

  test('both bases destroyed on the same tick -> draw', () {
    final world = _newWorld();
    world.allyBase.hp = 0;
    world.enemyBase.hp = 0;
    world.step();

    expect(world.outcome, BattleOutcome.draw);
    expect(world.phase, BattlePhase.finished);
  });

  test('outcome is final: further ticks change nothing once decided', () {
    final world = _newWorld();
    world.enemyBase.hp = 0;
    world.step();
    expect(world.outcome, BattleOutcome.allyWin);

    world.allyBase.hp = 0; // 승부가 갈린 뒤 상태가 바뀌어도
    for (var i = 0; i < 10; i++) {
      world.step(); // phase != running -> 시스템 자체가 안 돈다
    }
    expect(world.outcome, BattleOutcome.allyWin); // 그대로
    expect(world.tick, 1); // step()도 더 진행되지 않는다
  });
}
