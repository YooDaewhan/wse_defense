import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/battle_entity.dart';
import 'package:wse_defense/battle/entity/entity_state.dart';
import 'package:wse_defense/battle/system/damage_system.dart';
import 'package:wse_defense/battle/system/death_system.dart';
import 'package:wse_defense/battle/system/knockback_system.dart';
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
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: [KnockbackSystem(), DamageSystem(), DeathSystem()],
)..phase = BattlePhase.running;

BattleEntity _spawn({
  required int id,
  required Side side,
  int x = 0,
  int maxHp = 100,
  int hpSegments = 1,
}) => BattleEntity(
  id: id,
  side: side,
  spawnTick: 0,
  x: x * posScale,
  def: UnitDef(
    id: 'T_$id',
    base: UnitBaseStats(
      maxHp: maxHp,
      atk: 10,
      attackPeriod: 60,
      attackWindup: 12,
      attackRecover: 48,
      attackRange: 100,
      moveSpeed: 0,
      hpSegments: hpSegments,
    ),
  ),
);

void main() {
  test('K=3 unit gets exactly 2 natural knockbacks as HP crosses both thresholds', () {
    final world = _newWorld();
    final target = _spawn(id: 1, side: Side.enemy, maxHp: 300, hpSegments: 3);
    world.entities.add(target);

    var knockbackStarts = 0;
    var wasKnockedBack = false;
    void stepAndCount() {
      world.step();
      final isKb = target.knockbackTicksLeft > 0;
      if (isKb && !wasKnockedBack) knockbackStarts++;
      wasKnockedBack = isKb;
    }

    // 300 -> 150: 임계 200을 넘는다.
    world.pendingDamage.add(
      const PendingDamage(targetId: 1, sourceId: 99, amount: 150),
    );
    stepAndCount();
    expect(target.hp, 150);
    expect(target.knockbackTicksLeft, naturalKbTicks);

    for (var i = 0; i < naturalKbTicks; i++) {
      stepAndCount();
    }
    expect(target.knockbackTicksLeft, 0);

    // 150 -> 50: 임계 100을 넘는다.
    world.pendingDamage.add(
      const PendingDamage(targetId: 1, sourceId: 99, amount: 100),
    );
    stepAndCount();
    expect(target.hp, 50);

    for (var i = 0; i < naturalKbTicks; i++) {
      stepAndCount();
    }

    expect(knockbackStarts, 2);
    expect(target.consumedHpThresholds, 2);
  });

  test('a single hit crossing 2 thresholds at once consumes both but knocks back once', () {
    final world = _newWorld();
    final target = _spawn(id: 1, side: Side.enemy, maxHp: 300, hpSegments: 3);
    world.entities.add(target);

    world.pendingDamage.add(
      const PendingDamage(targetId: 1, sourceId: 99, amount: 290),
    );
    world.step();

    expect(target.hp, 10);
    expect(target.consumedHpThresholds, 2);
    expect(target.knockbackTicksLeft, naturalKbTicks); // 딱 1회분
  });

  test('healing then re-dropping past an already-consumed threshold adds no extra knockback', () {
    final world = _newWorld();
    final target = _spawn(id: 1, side: Side.enemy, maxHp: 300, hpSegments: 3);
    world.entities.add(target);

    world.pendingDamage.add(
      const PendingDamage(targetId: 1, sourceId: 99, amount: 150),
    );
    world.step(); // 300 -> 150, 임계 200 소비
    expect(target.consumedHpThresholds, 1);

    for (var i = 0; i < naturalKbTicks; i++) {
      world.step();
    }
    expect(target.knockbackTicksLeft, 0);

    target.hp = 250; // 회복 (임계 200보다 위)
    world.pendingDamage.add(
      const PendingDamage(targetId: 1, sourceId: 99, amount: 100),
    );
    world.step(); // 250 -> 150, 다시 200 아래로 내려가지만 이미 소비된 임계

    expect(target.hp, 150);
    expect(target.consumedHpThresholds, 1); // 늘지 않음
    expect(target.knockbackTicksLeft, 0); // 추가 넉백 없음
  });

  test('lethal damage takes priority over knockback', () {
    final world = _newWorld();
    final target = _spawn(id: 1, side: Side.enemy, maxHp: 300, hpSegments: 3);
    world.entities.add(target);

    world.pendingDamage.add(
      const PendingDamage(targetId: 1, sourceId: 99, amount: 400),
    );
    world.step();

    expect(target.hp, 0);
    expect(target.action, EntityAction.dead);
    expect(target.knockbackTicksLeft, 0);
  });

  test('forced knockback blocks re-application for 30 ticks after it ends', () {
    final world = _newWorld();
    final target = _spawn(id: 1, side: Side.enemy, maxHp: 1000, hpSegments: 1);
    world.entities.add(target);

    world.pendingDamage.add(
      const PendingDamage(
        targetId: 1,
        sourceId: 99,
        amount: 10,
        causesForcedKb: true,
        forcedKbDistance: 60,
      ),
    );
    world.step();
    expect(target.knockbackTicksLeft, naturalKbTicks);
    expect(target.knockbackIsForced, isTrue);

    for (var i = 0; i < naturalKbTicks; i++) {
      world.step();
    }
    expect(target.knockbackTicksLeft, 0);
    final immuneUntil = target.forcedKbImmuneUntilTick;

    // 재적용 시도 (30틱 이내) -> 차단
    world.pendingDamage.add(
      const PendingDamage(
        targetId: 1,
        sourceId: 99,
        amount: 10,
        causesForcedKb: true,
        forcedKbDistance: 60,
      ),
    );
    world.step();
    expect(target.knockbackTicksLeft, 0);

    // 30틱 경과 후 재시도 -> 허용
    while (world.tick < immuneUntil) {
      world.step();
    }
    world.pendingDamage.add(
      const PendingDamage(
        targetId: 1,
        sourceId: 99,
        amount: 10,
        causesForcedKb: true,
        forcedKbDistance: 60,
      ),
    );
    world.step();
    expect(target.knockbackTicksLeft, naturalKbTicks);
  });

  test('knockback duration is preserved even when pinned at the field boundary', () {
    final world = _newWorld();
    // ally facingSign=+1 -> 넉백은 -x 방향. 경계(0) 바로 앞에 둔다.
    final target = _spawn(id: 1, side: Side.ally, x: 5, maxHp: 1000, hpSegments: 1);
    world.entities.add(target);

    world.pendingDamage.add(
      const PendingDamage(
        targetId: 1,
        sourceId: 99,
        amount: 10,
        causesForcedKb: true,
        forcedKbDistance: 200, // 경계를 넘어설 만큼 큰 거리
      ),
    );
    world.step();
    expect(target.knockbackTicksLeft, naturalKbTicks);

    for (var i = 0; i < naturalKbTicks - 1; i++) {
      world.step();
      expect(target.x, 0); // 경계에 눌려있음
      expect(target.knockbackTicksLeft, greaterThan(0));
    }
    world.step();
    expect(target.knockbackTicksLeft, 0);
    expect(target.action, EntityAction.idle);
  });
}
