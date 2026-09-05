import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/defs/wave_def.dart';
import 'package:wse_defense/battle/system/spawn_system.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/battle/world/spawn_runtime.dart';

const _squirrel = UnitDef(
  id: 'ENM_SQUIRREL',
  base: UnitBaseStats(
    maxHp: 400,
    atk: 60,
    attackPeriod: 45,
    attackWindup: 9,
    attackRecover: 36,
    attackRange: 120,
    moveSpeed: 120,
  ),
);

const _boss = UnitDef(
  id: 'ENM_FOREST_BEAR',
  isBoss: true,
  base: UnitBaseStats(
    maxHp: 24000,
    atk: 1600,
    attackPeriod: 130,
    attackWindup: 45,
    attackRecover: 85,
    attackRange: 320,
    moveSpeed: 30,
  ),
);

BattleWorld _newWorld({
  List<WaveDef> waves = const [],
  List<BossTriggerDef> bossTriggers = const [],
  int enemyBaseHp = 18000,
}) => BattleWorld(
  config: BattleConfig(
    stage: StageDef(
      id: 'STG_TEST',
      index: 1,
      fieldLength: 2400,
      allyBaseX: 0,
      enemyBaseX: 2400,
      enemyBaseHp: enemyBaseHp,
      timeLimitSec: 300,
      waves: waves,
      bossTriggers: bossTriggers,
    ),
    allyBaseHp: 10000,
  ),
  rngSeed: 1,
  datapack: Datapack(
    characters: const {},
    enemies: {'ENM_SQUIRREL': _squirrel, 'ENM_FOREST_BEAR': _boss},
    stages: const {},
  ),
  systems: [SpawnSystem()],
)..phase = BattlePhase.running;

void main() {
  test('spawns exactly on the ticks the wave definition specifies', () {
    final world = _newWorld(
      waves: const [
        WaveDef(
          enemyId: 'ENM_SQUIRREL',
          startSec: 2,
          intervalSec: 3,
          count: 3,
          stopSec: 100,
          spawnX: 2350,
        ),
      ],
    );

    final spawnTicks = <int>[];
    var lastCount = 0;
    for (var i = 0; i < 300; i++) {
      final tickDuringThisStep = world.tick; // SpawnSystem이 이번에 보는 값
      world.step();
      if (world.enemyAliveCount != lastCount) {
        spawnTicks.add(tickDuringThisStep);
        lastCount = world.enemyAliveCount;
      }
    }

    expect(spawnTicks, [60, 150, 240]); // 2s,5s,8s * 30 ticks/s
    expect(world.enemyAliveCount, 3); // count:3 넘으면 더 안 나옴
  });

  test('NEST_FIRST_HIT: pending -> warning exactly once, nest left at 1 HP and immune', () {
    final world = _newWorld(
      bossTriggers: const [
        BossTriggerDef(
          id: 'BOSS_MAIN',
          enemyId: 'ENM_FOREST_BEAR',
          conditionKind: 'NEST_FIRST_HIT',
          warningTicks: 45,
          spawnX: 2380,
        ),
      ],
    );

    // 첫 타격 (다단히트 시뮬레이션: 두 번 연속 hp를 깎는다)
    world.enemyBase.hp -= 5000;
    world.step();
    expect(world.bossTriggers.single.state, BossTriggerState.warning);
    expect(world.enemyBase.hp, 1);
    expect(world.enemyBase.damageImmune, isTrue);

    final warningTicksAfterFirst = world.bossTriggers.single.warningTicksLeft;

    // 같은 둥지에 또 피해가 들어와도(다단히트) 재진입하지 않는다.
    world.enemyBase.hp -= 100;
    world.step();
    expect(world.bossTriggers.single.state, BossTriggerState.warning);
    expect(world.bossTriggers.single.warningTicksLeft, warningTicksAfterFirst - 1);
  });

  test('one-shot lethal hit on the nest still only warns once, HP clamped to 1', () {
    final world = _newWorld(
      enemyBaseHp: 18000,
      bossTriggers: const [
        BossTriggerDef(
          id: 'BOSS_MAIN',
          enemyId: 'ENM_FOREST_BEAR',
          conditionKind: 'NEST_FIRST_HIT',
          warningTicks: 45,
          spawnX: 2380,
        ),
      ],
    );

    world.enemyBase.hp = -999999; // 일격에 파괴급 피해
    world.step();

    expect(world.bossTriggers.single.state, BossTriggerState.warning);
    expect(world.enemyBase.hp, 1);
  });

  test('45 ticks after warning, the boss spawns exactly once and immunity is lifted', () {
    final world = _newWorld(
      bossTriggers: const [
        BossTriggerDef(
          id: 'BOSS_MAIN',
          enemyId: 'ENM_FOREST_BEAR',
          conditionKind: 'NEST_FIRST_HIT',
          warningTicks: 45,
          spawnX: 2380,
        ),
      ],
    );

    world.enemyBase.hp -= 1;
    world.step(); // pending -> warning (warningTicksLeft = 45, 아직 감소 전)
    expect(world.bossTriggers.single.state, BossTriggerState.warning);

    for (var i = 0; i < 44; i++) {
      world.step(); // 45 -> 1까지 44회 감소
      expect(world.bossTriggers.single.state, BossTriggerState.warning);
      expect(world.enemyAliveCount, 0);
    }
    expect(world.bossTriggers.single.warningTicksLeft, 1);

    world.step(); // 마지막 1회 감소: 1 -> 0 -> spawned
    expect(world.bossTriggers.single.state, BossTriggerState.spawned);
    expect(world.enemyBase.damageImmune, isFalse);
    expect(world.enemyAliveCount, 1);
    expect(world.entities.ordered.single.def.isBoss, isTrue);

    // 계속 진행해도 다시 등장하지 않는다.
    for (var i = 0; i < 200; i++) {
      world.step();
    }
    expect(world.enemyAliveCount, 1);
  });

  test('boss trigger state round-trips (simulated serialize/deserialize) without double-spawn', () {
    final world = _newWorld(
      bossTriggers: const [
        BossTriggerDef(
          id: 'BOSS_MAIN',
          enemyId: 'ENM_FOREST_BEAR',
          conditionKind: 'NEST_FIRST_HIT',
          warningTicks: 45,
          spawnX: 2380,
        ),
      ],
    );

    world.enemyBase.hp -= 1;
    for (var i = 0; i < 20; i++) {
      world.step();
    }
    expect(world.bossTriggers.single.state, BossTriggerState.warning);

    // "직렬화 -> 역직렬화"를 흉내: 상태값만 복사해 새 world를 이어 만든다
    // (T-20이 실제 serialize()/deserialize()를 만들면 이 값들이 그 대상).
    final savedState = world.bossTriggers.single.state;
    final savedTicksLeft = world.bossTriggers.single.warningTicksLeft;

    final restored = _newWorld(
      bossTriggers: const [
        BossTriggerDef(
          id: 'BOSS_MAIN',
          enemyId: 'ENM_FOREST_BEAR',
          conditionKind: 'NEST_FIRST_HIT',
          warningTicks: 45,
          spawnX: 2380,
        ),
      ],
    );
    restored.bossTriggers.single.state = savedState;
    restored.bossTriggers.single.warningTicksLeft = savedTicksLeft;
    restored.enemyBase.hp = 1;
    restored.enemyBase.damageImmune = true;

    for (var i = 0; i < 100; i++) {
      restored.step();
    }

    expect(restored.bossTriggers.single.state, BossTriggerState.spawned);
    expect(restored.enemyAliveCount, 1); // 정확히 1회
  });

  test('simultaneous cap: regular spawns stop at unitCap-1, reserving one slot for the boss', () {
    final world = _newWorld(
      waves: const [
        WaveDef(
          enemyId: 'ENM_SQUIRREL',
          startSec: 0,
          intervalSec: 1,
          count: -1,
          stopSec: 1000,
          spawnX: 2350,
        ),
      ],
      bossTriggers: const [
        BossTriggerDef(
          id: 'BOSS_MAIN',
          enemyId: 'ENM_FOREST_BEAR',
          conditionKind: 'NEST_FIRST_HIT',
          warningTicks: 45,
          spawnX: 2380,
        ),
      ],
    );

    world.enemyBase.hp -= 1; // 보스 워닝 시작
    for (var i = 0; i < 2000; i++) {
      world.step();
    }

    // 일반 스폰은 unitCap-1에서 멈췄어야 한다.
    expect(world.enemyAliveCount, unitCap); // (unitCap-1)명 + 보스 1명
    expect(
      world.entities.ordered.where((e) => e.def.isBoss).length,
      1,
    );
  });
}
