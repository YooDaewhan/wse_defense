import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/battle_entity.dart';
import 'package:wse_defense/battle/entity/entity_state.dart';
import 'package:wse_defense/battle/system/damage_system.dart';
import 'package:wse_defense/battle/system/death_system.dart';
import 'package:wse_defense/battle/system/pending_damage.dart';
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
    startingPrayerPower: 0,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: [DamageSystem(), DeathSystem()],
)..phase = BattlePhase.running;

BattleEntity _spawn({
  required int id,
  required Side side,
  int maxHp = 100,
  int def = 0,
  int killPrayerReward = 0,
}) => BattleEntity(
  id: id,
  side: side,
  spawnTick: 0,
  x: 0,
  def: UnitDef(
    id: 'T_$id',
    killPrayerReward: killPrayerReward,
    base: UnitBaseStats(
      maxHp: maxHp,
      atk: 10,
      attackPeriod: 60,
      attackWindup: 12,
      attackRecover: 48,
      attackRange: 100,
      moveSpeed: 0,
      def: def,
    ),
  ),
);

void main() {
  test('multiple hits on the same target in one tick sum before applying', () {
    final world = _newWorld();
    final target = _spawn(id: 1, side: Side.enemy, maxHp: 1000);
    world.entities.add(target);

    world.pendingDamage.addAll([
      const PendingDamage(targetId: 1, sourceId: 10, amount: 30),
      const PendingDamage(targetId: 1, sourceId: 11, amount: 45),
    ]);

    world.step();

    expect(target.hp, 1000 - 75);
  });

  test('processing order never changes the outcome (no invincibility from ordering)', () {
    final worldA = _newWorld();
    final targetA = _spawn(id: 1, side: Side.enemy, maxHp: 50);
    worldA.entities.add(targetA);
    worldA.pendingDamage.addAll([
      const PendingDamage(targetId: 1, sourceId: 10, amount: 60), // lethal alone
      const PendingDamage(targetId: 1, sourceId: 11, amount: 30),
    ]);
    DamageSystem().execute(worldA);

    final worldB = _newWorld();
    final targetB = _spawn(id: 1, side: Side.enemy, maxHp: 50);
    worldB.entities.add(targetB);
    worldB.pendingDamage.addAll([
      const PendingDamage(targetId: 1, sourceId: 11, amount: 30), // reversed order
      const PendingDamage(targetId: 1, sourceId: 10, amount: 60),
    ]);
    DamageSystem().execute(worldB);

    // 두 히트가 합산된 뒤 한 번에 적용돼야 한다: 50 - (60+30) = -40.
    // 순서상 먼저 처리된 공격이 죽음을 확정해 나중 공격을 지워버리면 안 된다.
    expect(targetA.hp, -40);
    expect(targetB.hp, -40);
    expect(targetA.hp, targetB.hp);
  });

  test('kill reward is granted exactly once even if DeathSystem runs twice', () {
    final world = _newWorld();
    final enemy = _spawn(id: 1, side: Side.enemy, killPrayerReward: 25);
    world.entities.add(enemy);
    enemy.hp = 0;

    final deathSystem = DeathSystem();
    deathSystem.execute(world);
    deathSystem.execute(world); // 실수로 두 번 호출해도 안전해야 함

    expect(world.prayerPower, 25);
    expect(enemy.action, EntityAction.dead);
  });

  test('computeDamage: def reduces damage (min 1), formula matches §7', () {
    final world = _newWorld();
    final atk = _spawn(id: 1, side: Side.ally);
    final halfArmored = _spawn(id: 2, side: Side.enemy, def: 50000); // 50% 감소
    final heavilyArmored = _spawn(id: 3, side: Side.enemy, def: 999999); // clamp 90%

    expect(computeDamage(world, atk, halfArmored, 100), 50);
    expect(computeDamage(world, atk, heavilyArmored, 10), 1); // 최소 피해 보장
  });
}
