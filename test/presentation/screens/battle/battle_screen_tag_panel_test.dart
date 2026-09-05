import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/game/battle_game.dart';
import 'package:wse_defense/presentation/screens/battle/battle_screen.dart';

const _unit = UnitDef(
  id: 'CHR_TEST',
  base: UnitBaseStats(
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
    collisionRadius: 100, // 넉넉하게 -- 화면 중앙 탭이 반드시 맞도록
  ),
);

// 아군/적 기지를 둘 다 x=0에 둬서 전선 중간(카메라 목표)이 항상 0에 고정되게
// 한다 -- 그러면 x=0에 있는 유닛이 항상 화면 정중앙에 렌더된다.
BattleWorld _newWorld() => BattleWorld(
  config: const BattleConfig(
    stage: StageDef(
      id: 'STG_TEST',
      index: 1,
      fieldLength: 2400,
      allyBaseX: 0,
      enemyBaseX: 0,
      enemyBaseHp: 1000,
      timeLimitSec: 300,
    ),
    allyBaseHp: 1000,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: const [],
)..phase = BattlePhase.running;

Future<void> _pumpFrames(WidgetTester tester, int count) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('tapping a unit while running does nothing; pausing then tapping opens the detail panel', (
    tester,
  ) async {
    final world = _newWorld();
    world.spawnEntity(_unit, Side.ally, 0);

    await tester.pumpWidget(MaterialApp(home: BattleScreen(world: world)));
    await _pumpFrames(tester, 5);

    final center = tester.getCenter(find.byType(GameWidget<BattleGame>));

    // 실행 중 탭 -- 아무 일도 안 일어남.
    await tester.tapAt(center);
    await _pumpFrames(tester, 3);
    expect(find.byKey(const ValueKey('unit_detail_panel')), findsNothing);

    // 일시정지 후 탭 -- 패널이 뜬다.
    await tester.tap(find.byKey(const ValueKey('pause_toggle')));
    await _pumpFrames(tester, 3);
    await tester.tapAt(center);
    await _pumpFrames(tester, 3);
    expect(find.byKey(const ValueKey('unit_detail_panel')), findsOneWidget);

    // 재개하면 패널이 닫힌다.
    await tester.tap(find.byKey(const ValueKey('pause_toggle')));
    await _pumpFrames(tester, 3);
    expect(find.byKey(const ValueKey('unit_detail_panel')), findsNothing);

    await _pumpFrames(tester, 30); // 남은 제스처 타이머 정리
  });
}
