import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/battle_entity.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_input.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/domain/battle/battle_submission.dart';

const _acorn = UnitDef(
  id: 'CHR_ACORN',
  base: UnitBaseStats(
    summonCost: 75,
    maxHp: 1200,
    atk: 90,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 130,
    moveSpeed: 100,
  ),
);

const _droplet = UnitDef(
  id: 'CHR_DROPLET',
  base: UnitBaseStats(
    summonCost: 200,
    maxHp: 480,
    atk: 300,
    attackPeriod: 90,
    attackWindup: 18,
    attackRecover: 72,
    attackRange: 420,
    moveSpeed: 80,
  ),
);

BattleWorld _newWorld() => BattleWorld(
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
    formation: [_acorn, _droplet],
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: const [],
)..phase = BattlePhase.running;

BattleEntity _spawn({required int id, required Side side, required int x, int maxHp = 100}) => BattleEntity(
  id: id,
  side: side,
  spawnTick: 0,
  x: x,
  def: UnitDef(id: 'T_$id', base: UnitBaseStats(maxHp: maxHp, atk: 10, attackPeriod: 60, attackWindup: 12, attackRecover: 48, attackRange: 100, moveSpeed: 0)),
);

/// 10_WIRING_PLAN.md T-60.
void main() {
  test('battleOutcomeCode matches the server BattleOutcome union', () {
    expect(battleOutcomeCode(BattleOutcome.allyWin), 'ALLY_WIN');
    expect(battleOutcomeCode(BattleOutcome.enemyWin), 'ENEMY_WIN');
    expect(battleOutcomeCode(BattleOutcome.draw), 'DRAW');
    expect(battleOutcomeCode(BattleOutcome.timeout), 'TIMEOUT');
  });

  group('countEnemiesKilled', () {
    test('counts only dead enemies, not dead allies or living enemies', () {
      final world = _newWorld();
      world.entities.add(_spawn(id: 1, side: Side.enemy, x: 100)..hp = 0); // 죽은 적
      world.entities.add(_spawn(id: 2, side: Side.enemy, x: 200)); // 살아있는 적
      world.entities.add(_spawn(id: 3, side: Side.ally, x: 50)..hp = 0); // 죽은 아군(집계 제외)

      expect(countEnemiesKilled(world), 1);
    });
  });

  group('frontAllyX', () {
    test('returns the ally base position when no allies are on the field', () {
      final world = _newWorld();
      expect(frontAllyX(world), world.allyBase.x);
    });

    test('returns the frontmost living ally\'s x, ignoring dead allies further ahead', () {
      final world = _newWorld();
      world.entities.add(_spawn(id: 1, side: Side.ally, x: 300));
      world.entities.add(_spawn(id: 2, side: Side.ally, x: 900)..hp = 0); // 더 앞이지만 죽음
      world.entities.add(_spawn(id: 3, side: Side.enemy, x: 2000)); // 적은 무시

      expect(frontAllyX(world), 300);
    });
  });

  group('buildBattleSummary', () {
    test('derives totals purely from the recorded inputs and final world state', () {
      final world = _newWorld();
      world.entities.add(_spawn(id: 1, side: Side.enemy, x: 500)..hp = 0);
      final recorded = <BattleInput>[
        const SummonInput(0, 0), // CHR_ACORN, cost 75
        const SummonInput(600, 1), // CHR_DROPLET, cost 200
        const UltimateInput(1200),
      ];

      final summary = buildBattleSummary(world: world, recordedInputs: recorded, maxFrontlineX: 777);

      expect(summary['totalSummons'], 2);
      expect(summary['totalPrayerSpent'], 75 + 200);
      expect(summary['ultimateUsed'], 1);
      expect(summary['enemiesKilled'], 1);
      expect(summary['enemyBaseHpLeft'], world.enemyBase.hp);
      expect(summary['allyBaseHpLeft'], world.allyBase.hp);
      expect(summary['maxFrontlineX'], 777);
      expect(summary['focusBoostStage'], world.focusBoostStage);
      expect(summary['endTick'], world.tick);
    });
  });

  test('computeBattleChecksum is deterministic and sensitive to every input', () {
    final base = computeBattleChecksum(inputLogBase64: 'AAA', seed: 1, formationHash: 'h1');
    expect(computeBattleChecksum(inputLogBase64: 'AAA', seed: 1, formationHash: 'h1'), base); // 결정적
    expect(computeBattleChecksum(inputLogBase64: 'BBB', seed: 1, formationHash: 'h1'), isNot(base));
    expect(computeBattleChecksum(inputLogBase64: 'AAA', seed: 2, formationHash: 'h1'), isNot(base));
    expect(computeBattleChecksum(inputLogBase64: 'AAA', seed: 1, formationHash: 'h2'), isNot(base));
  });
}
