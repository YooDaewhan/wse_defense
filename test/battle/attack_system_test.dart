import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/battle_entity.dart';
import 'package:wse_defense/battle/entity/entity_state.dart';
import 'package:wse_defense/battle/system/attack_system.dart';
import 'package:wse_defense/battle/system/target_system.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';

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
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: [TargetSystem(), AttackSystem()],
)..phase = BattlePhase.running;

/// x는 논리 단위(고정소수점 아님) — 내부에서 posScale을 곱한다.
BattleEntity _spawn({
  required int id,
  required Side side,
  required int x,
  int collisionRadius = 20,
  int attackRange = 100,
  int attackPeriod = 60,
  int attackWindup = 12,
  int attackRecover = 48,
  String attackMode = 'SINGLE',
  int aoeMaxTargets = 1,
}) => BattleEntity(
  id: id,
  side: side,
  spawnTick: 0,
  x: x * posScale,
  def: UnitDef(
    id: 'T_$id',
    base: UnitBaseStats(
      maxHp: 1000,
      atk: 10,
      attackPeriod: attackPeriod,
      attackWindup: attackWindup,
      attackRecover: attackRecover,
      attackRange: attackRange,
      moveSpeed: 0,
      collisionRadius: collisionRadius,
      attackMode: attackMode,
      aoeMaxTargets: aoeMaxTargets,
    ),
  ),
);

void main() {
  test('acorn (P=60, A=12, R=48) resolves exactly once every 60 ticks', () {
    final world = _newWorld();
    final ally = _spawn(id: 1, side: Side.ally, x: 0);
    final enemy = _spawn(id: 2, side: Side.enemy, x: 100);
    world.entities
      ..add(ally)
      ..add(enemy);

    final resolveTicks = <int>[];
    var lastCompleted = 0;
    for (var t = 1; t <= 190; t++) {
      world.step();
      if (ally.completedAttacks != lastCompleted) {
        resolveTicks.add(t);
        lastCompleted = ally.completedAttacks;
      }
    }

    expect(resolveTicks.length, greaterThanOrEqualTo(3));
    final gaps = [
      for (var i = 1; i < resolveTicks.length; i++)
        resolveTicks[i] - resolveTicks[i - 1],
    ];
    expect(gaps, everyElement(60));
  });

  test('SINGLE target is locked at windup start; out of range at resolve = miss', () {
    final world = _newWorld();
    final ally = _spawn(
      id: 1,
      side: Side.ally,
      x: 0,
      collisionRadius: 10,
      attackRange: 50,
      attackWindup: 5,
      attackPeriod: 20,
      attackRecover: 15,
    );
    final enemy = _spawn(id: 2, side: Side.enemy, x: 50, collisionRadius: 10);
    world.entities
      ..add(ally)
      ..add(enemy);

    world.step(); // windup 시작 (attackWindup: 5 -> 5틱 뒤 판정), lockedTargetId == enemy.id
    expect(ally.action, EntityAction.attackWindup);
    expect(ally.lockedTargetId, enemy.id);

    enemy.x = 1000000 * posScale; // 판정 전에 멀리 이동 -> 사거리 밖

    for (var i = 0; i < 5; i++) {
      world.step();
    }

    expect(ally.action, EntityAction.attackRecover);
    expect(ally.completedAttacks, 1); // 판정은 완료됐다 (헛침이어도 완료는 완료)
    expect(ally.lastHitTargetIds, isEmpty); // 헛침
  });

  test('AOE re-selects up to aoeMaxTargets at the moment it resolves', () {
    final world = _newWorld();
    final ally = _spawn(
      id: 1,
      side: Side.ally,
      x: 0,
      collisionRadius: 10,
      attackRange: 1000,
      attackWindup: 5,
      attackPeriod: 20,
      attackRecover: 15,
      attackMode: 'AOE',
      aoeMaxTargets: 2,
    );
    final farEnemy = _spawn(id: 2, side: Side.enemy, x: 100, collisionRadius: 10);
    world.entities
      ..add(ally)
      ..add(farEnemy);

    world.step(); // windup 시작 (lockedTargetId는 AOE에선 안 쓰임)
    expect(ally.action, EntityAction.attackWindup);

    // windup 도중 더 가까운 적 둘이 나타난다 -> 판정 시점 재평가를 검증.
    final nearB = _spawn(id: 3, side: Side.enemy, x: 50, collisionRadius: 10);
    final nearC = _spawn(id: 4, side: Side.enemy, x: 60, collisionRadius: 10);
    world.entities
      ..add(nearB)
      ..add(nearC);

    for (var i = 0; i < 5; i++) {
      world.step();
    }

    expect(ally.action, EntityAction.attackRecover);
    expect(ally.lastHitTargetIds, [nearB.id, nearC.id]); // 가장 가까운 2명만
    expect(ally.lastHitTargetIds, isNot(contains(farEnemy.id)));
  });

  test('completedAttacks increments only at the tick judgement resolves', () {
    final world = _newWorld();
    final ally = _spawn(
      id: 1,
      side: Side.ally,
      x: 0,
      attackWindup: 3,
      attackPeriod: 8,
      attackRecover: 5,
    );
    final enemy = _spawn(id: 2, side: Side.enemy, x: 50);
    world.entities
      ..add(ally)
      ..add(enemy);

    world.step(); // tick1: windup 시작 (actionTimer = A = 3)
    expect(ally.completedAttacks, 0);

    world.step(); // tick2: actionTimer 3->2
    expect(ally.completedAttacks, 0);

    world.step(); // tick3: actionTimer 2->1
    expect(ally.completedAttacks, 0);

    world.step(); // tick4: actionTimer 1->0 -> 판정
    expect(ally.completedAttacks, 1);
    expect(ally.action, EntityAction.attackRecover);

    // recover(R=5)가 끝나 새 windup을 재시도하는 틱까지 포함해도 증가 없음.
    for (var i = 0; i < 5; i++) {
      world.step();
      expect(ally.completedAttacks, 1);
    }
  });
}
