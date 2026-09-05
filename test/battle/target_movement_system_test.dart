import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/battle_entity.dart';
import 'package:wse_defense/battle/system/movement_system.dart';
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
  systems: [TargetSystem(), MovementSystem()],
)..phase = BattlePhase.running;

/// x는 논리 단위(고정소수점 아님) — 내부에서 posScale을 곱한다.
BattleEntity _spawn({
  required int id,
  required Side side,
  required int x,
  int collisionRadius = 20,
  int moveSpeed = 100,
  int attackRange = 0,
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
      attackPeriod: 60,
      attackWindup: 12,
      attackRecover: 48,
      attackRange: attackRange,
      moveSpeed: moveSpeed,
      collisionRadius: collisionRadius,
    ),
  ),
);

void main() {
  test('ally advances rightward and stops at the collision boundary of an enemy', () {
    final world = _newWorld();
    final ally = _spawn(id: 1, side: Side.ally, x: 0, moveSpeed: 3000);
    final enemy = _spawn(id: 2, side: Side.enemy, x: 200, moveSpeed: 0);
    world.entities
      ..add(ally)
      ..add(enemy);

    for (var i = 0; i < 10; i++) {
      world.step();
    }

    final expectedBoundary =
        enemy.x - (ally.def.base.collisionRadius + enemy.def.base.collisionRadius) * posScale;
    expect(ally.x, expectedBoundary);

    // 추가로 진행해도 더 이상 접근하지 않는다 ("경계에서 정지").
    final xAfterSettling = ally.x;
    world.step();
    world.step();
    expect(ally.x, xAfterSettling);
  });

  test('same side units overlap and pass through each other', () {
    final world = _newWorld();
    final mover = _spawn(id: 1, side: Side.ally, x: 0, moveSpeed: 3000);
    final stationaryAlly = _spawn(id: 2, side: Side.ally, x: 50, moveSpeed: 0);
    world.entities
      ..add(mover)
      ..add(stationaryAlly);

    world.step();

    // 상대 진영이 없으니 차단 대상이 없다 -> 겹쳐서 지나간다.
    expect(mover.x, greaterThan(stationaryAlly.x));
  });

  test('a knocked-back enemy does not block movement', () {
    final world = _newWorld();
    final ally = _spawn(id: 1, side: Side.ally, x: 0, moveSpeed: 3000);
    final knockedBackEnemy = _spawn(id: 2, side: Side.enemy, x: 50, moveSpeed: 0);
    knockedBackEnemy.knockbackTicksLeft = 999;
    world.entities
      ..add(ally)
      ..add(knockedBackEnemy);

    world.step();

    // isTargetable == false인 넉백 유닛은 차단 목록에서 제외된다.
    expect(ally.x, greaterThan(knockedBackEnemy.x));
  });

  test('range check is based on the gap between collision boundaries', () {
    final a = _spawn(id: 1, side: Side.ally, x: 0, collisionRadius: 20, attackRange: 60);
    final b = _spawn(id: 2, side: Side.enemy, x: 100, collisionRadius: 20);

    // 중심 거리 100 - 반지름 20 - 반지름 20 = 60.
    expect(gapBetween(a, b), 60);
    expect(inRange(a, b), isTrue); // gap(60) <= attackRange(60)

    final farther = _spawn(id: 3, side: Side.enemy, x: 101, collisionRadius: 20);
    expect(gapBetween(a, farther), 61);
    expect(inRange(a, farther), isFalse); // gap(61) > attackRange(60)
  });

  test('TargetSystem picks the nearest targetable enemy, ties by entityId', () {
    final world = _newWorld();
    final self = _spawn(id: 1, side: Side.ally, x: 0);
    final farEnemy = _spawn(id: 5, side: Side.enemy, x: 300);
    final tiedA = _spawn(id: 3, side: Side.enemy, x: 100);
    final tiedB = _spawn(id: 2, side: Side.enemy, x: -100);
    world.entities
      ..add(self)
      ..add(farEnemy)
      ..add(tiedA)
      ..add(tiedB);

    world.step();

    // tiedA/tiedB 모두 거리 100000으로 동점 -> entityId가 더 작은 tiedB(2) 선택.
    expect(self.currentTargetId, tiedB.id);
  });
}
