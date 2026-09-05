import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/event/battle_event.dart';
import 'package:wse_defense/battle/system/attack_system.dart';
import 'package:wse_defense/battle/system/damage_system.dart';
import 'package:wse_defense/battle/system/death_system.dart';
import 'package:wse_defense/battle/system/target_system.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';

const _unit = UnitDef(
  id: 'T',
  base: UnitBaseStats(
    maxHp: 50,
    atk: 30,
    attackPeriod: 30,
    attackWindup: 6,
    attackRecover: 24,
    attackRange: 100,
    moveSpeed: 0,
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
    allyBaseHp: 1000,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: [TargetSystem(), AttackSystem(), DamageSystem(), DeathSystem()],
)..phase = BattlePhase.running;

void main() {
  test('an attack that connects emits AttackFiredEvent then DamageDealtEvent in the same tick', () {
    final w = _newWorld();
    w.spawnEntity(_unit, Side.ally, 0);
    w.spawnEntity(_unit, Side.enemy, 50 * posScale); // 사거리(100) 안

    AttackFiredEvent? fired;
    DamageDealtEvent? dealt;
    for (var i = 0; i < 10 && dealt == null; i++) {
      w.step();
      for (final ev in w.events) {
        if (ev is AttackFiredEvent) fired = ev;
        if (ev is DamageDealtEvent) dealt = ev;
      }
    }

    expect(fired, isNotNull);
    expect(dealt, isNotNull);
    expect(fired!.tick, dealt!.tick); // 같은 틱 -- 03_BATTLE_ENGINE.md §3 순서상 자연히 그렇게 됨
    expect(dealt.amount, 30);
  });

  test('a miss (target left range mid-windup) still emits AttackFiredEvent with an empty target list', () {
    final w = _newWorld();
    w.spawnEntity(_unit, Side.ally, 0);
    final victim = w.spawnEntity(_unit, Side.enemy, 50 * posScale); // 사거리(100) 안 -- windup은 시작됨

    w.step(); // windup 진입(단일 표적 고정)
    victim.x = 99999 * posScale; // 판정 전에 사거리 밖으로 이동 -> 헛침

    AttackFiredEvent? fired;
    for (var i = 0; i < 10 && fired == null; i++) {
      w.step();
      for (final ev in w.events) {
        if (ev is AttackFiredEvent) fired = ev;
      }
    }
    expect(fired, isNotNull);
    expect(fired!.targetIds, isEmpty);
  });

  test('a kill emits DeathEvent on the tick hp reaches 0', () {
    final w = _newWorld();
    w.spawnEntity(_unit, Side.ally, 0);
    final victim = w.spawnEntity(_unit, Side.enemy, 50 * posScale);
    victim.hp = 1; // 한 방에 즉사하도록

    DeathEvent? death;
    for (var i = 0; i < 10 && death == null; i++) {
      w.step();
      final matches = w.events.whereType<DeathEvent>().where((e) => e.entityId == victim.id);
      if (matches.isNotEmpty) death = matches.first;
    }
    expect(death, isNotNull);
  });

  test('events accumulate across ticks until something drains them (render frame < tick rate 가능)', () {
    final w = _newWorld();
    w.spawnEntity(_unit, Side.ally, 0);
    w.spawnEntity(_unit, Side.enemy, 50 * posScale);

    for (var i = 0; i < 10; i++) {
      w.step(); // 여러 틱(첫 판정까지 6틱 필요) 동안 아무도 drain하지 않음
    }
    expect(w.events, isNotEmpty); // 그 사이에 쌓인 걸 그대로 들고 있어야 한다
  });

  test('drainEvents empties the buffer and returns exactly what had accumulated', () {
    final w = _newWorld();
    w.spawnEntity(_unit, Side.ally, 0);
    w.spawnEntity(_unit, Side.enemy, 50 * posScale);

    final allDrained = <BattleEvent>[];
    for (var i = 0; i < 60; i++) {
      w.step();
      allDrained.addAll(w.drainEvents());
      expect(w.events, isEmpty); // drain 직후엔 항상 비어 있어야 한다
    }
    expect(allDrained, isNotEmpty);
  });

  test('완료조건: 이벤트를 한 번도 drain하지 않아도(구독 없음) 시뮬 결과(체크섬)가 매 틱 완전히 동일하다', () {
    final drained = _newWorld();
    final undrained = _newWorld();

    drained.spawnEntity(_unit, Side.ally, 0);
    drained.spawnEntity(_unit, Side.enemy, 50 * posScale);
    undrained.spawnEntity(_unit, Side.ally, 0);
    undrained.spawnEntity(_unit, Side.enemy, 50 * posScale);

    for (var i = 0; i < 200; i++) {
      drained.step();
      drained.drainEvents(); // 매 틱 "구독"해서 비움
      undrained.step(); // "구독 없음" -- events는 계속 쌓이기만 함
      expect(undrained.checksum(), drained.checksum());
    }
    // 쌓이기만 한 쪽은 실제로 이벤트가 누적돼 있어야 이 비교가 의미 있다.
    expect(undrained.events.length, greaterThan(0));
  });
}
