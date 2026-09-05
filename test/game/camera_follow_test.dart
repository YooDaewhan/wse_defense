import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/game/camera_follow.dart';

const _unit = UnitDef(
  id: 'T',
  base: UnitBaseStats(
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
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
  systems: const [],
)..phase = BattlePhase.running;

void main() {
  test('targetX is the midpoint between the frontmost ally and frontmost enemy', () {
    final w = _newWorld();
    w.spawnEntity(_unit, Side.ally, 100 * posScale);
    w.spawnEntity(_unit, Side.ally, 300 * posScale); // 더 앞선(전선) 아군
    w.spawnEntity(_unit, Side.enemy, 2000 * posScale); // 더 앞선(전선) 적
    w.spawnEntity(_unit, Side.enemy, 2200 * posScale);

    expect(CameraFollow.targetX(w), (300 * posScale + 2000 * posScale) ~/ 2);
  });

  test('falls back to the base position for a side with no one alive', () {
    final w = _newWorld();
    expect(CameraFollow.targetX(w), (w.allyBase.x + w.enemyBase.x) ~/ 2);
  });

  test('auto mode springs camX toward the target over repeated frames', () {
    final w = _newWorld();
    w.spawnEntity(_unit, Side.ally, 0);
    w.spawnEntity(_unit, Side.enemy, 1000 * posScale);
    final target = CameraFollow.targetX(w).toDouble();

    final cam = CameraFollow()..camX = 0;
    for (var i = 0; i < 500; i++) {
      cam.update(w, 1 / 60);
    }
    expect(cam.camX, closeTo(target, 1));
  });

  test('a drag switches to manual mode and camera stops auto-tracking until 3s pass', () {
    final w = _newWorld();
    w.spawnEntity(_unit, Side.ally, 0);
    w.spawnEntity(_unit, Side.enemy, 1000 * posScale);

    final cam = CameraFollow()..camX = 0;
    cam.onDragDelta(500);
    expect(cam.isManual, isTrue);
    expect(cam.camX, 500);

    for (var i = 0; i < 60; i++) {
      cam.update(w, 1 / 60); // 1초 경과 -- 아직 수동
    }
    expect(cam.isManual, isTrue);
    expect(cam.camX, 500); // 자동 추적이 건드리지 않았다

    for (var i = 0; i < 125; i++) {
      cam.update(w, 1 / 60); // 추가 2초+여유 -- 총 3초를 확실히 넘겨 자동 복귀
    }
    expect(cam.isManual, isFalse);
  });
}
