import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/entity/entity_state.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/game/battle_game.dart';

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
  systems: const [], // 렌더 루프 자체만 검증 — 시스템 목록은 다른 티켓이 이미 검증함
)..phase = BattlePhase.running;

Future<void> _pumpFrames(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('30Hz simulation advances under a 60fps render loop, with interpolated unit components', (
    tester,
  ) async {
    final world = _newWorld();
    world.spawnEntity(_unit, Side.ally, 0);
    world.spawnEntity(_unit, Side.enemy, 1000 * posScale);
    final game = BattleGame(battleWorld: world);

    await tester.pumpWidget(MaterialApp(home: GameWidget(game: game)));
    await _pumpFrames(tester, 3); // onLoad 완료 대기

    expect(world.tick, 0);
    await _pumpFrames(tester, 60); // 60프레임 x 16ms ≈ 실시간 0.96초 -> 약 28~29틱 기대

    expect(world.tick, greaterThan(20));
    expect(world.tick, lessThan(35));
  });

  testWidgets('2x speed advances roughly twice as many ticks over the same frames', (tester) async {
    final world = _newWorld();
    world.spawnEntity(_unit, Side.ally, 0);
    final game = BattleGame(battleWorld: world, speedMultiplier: 2.0);

    await tester.pumpWidget(MaterialApp(home: GameWidget(game: game)));
    await _pumpFrames(tester, 3);
    await _pumpFrames(tester, 60);

    expect(world.tick, greaterThan(45));
  });

  testWidgets('a pan gesture switches the camera to manual mode', (tester) async {
    final world = _newWorld();
    world.spawnEntity(_unit, Side.ally, 0);
    world.spawnEntity(_unit, Side.enemy, 1000 * posScale);
    final game = BattleGame(battleWorld: world);

    await tester.pumpWidget(MaterialApp(home: GameWidget(game: game)));
    await _pumpFrames(tester, 3);

    expect(game.cameraFollow.isManual, isFalse);
    await tester.drag(find.byType(GameWidget<BattleGame>), const Offset(100, 0));
    await _pumpFrames(tester, 1);

    expect(game.cameraFollow.isManual, isTrue);
    // 유닛 컴포넌트들도 이제 TapCallbacks를 갖고 있어(T-27), 드래그와 겹치는
    // 탭/롱프레스 제스처 아레나 판정 타이머가 남지 않도록 충분히 흘려보낸다.
    await _pumpFrames(tester, 50);
  });

  testWidgets('a dead unit keeps its component through the (fallback) death clip duration, then it is removed', (
    tester,
  ) async {
    final world = _newWorld();
    final victim = world.spawnEntity(_unit, Side.ally, 0);
    final game = BattleGame(battleWorld: world);

    await tester.pumpWidget(MaterialApp(home: GameWidget(game: game)));
    await _pumpFrames(tester, 3);
    expect(game.unitComponents.containsKey(victim.id), isTrue);

    victim.hp = 0;
    victim.action = EntityAction.dead; // DeathSystem이 없는 축소 시나리오라 직접 표시

    await _pumpFrames(tester, 3); // death 클립 시작 -- 아직 안 끝남(폴백 0.5초)
    expect(game.unitComponents.containsKey(victim.id), isTrue);

    await _pumpFrames(tester, 40); // 40 x 16ms = 0.64초 > 폴백 death 길이(0.5초)
    expect(game.unitComponents.containsKey(victim.id), isFalse);
  });
}
