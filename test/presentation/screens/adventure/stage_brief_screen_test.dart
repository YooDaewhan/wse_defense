import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/defs/wave_def.dart';
import 'package:wse_defense/presentation/screens/adventure/stage_brief_screen.dart';

const _squirrel = UnitDef(
  id: 'ENM_SQUIRREL',
  nameKey: 'enm.squirrel',
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

const _bear = UnitDef(
  id: 'ENM_BEAR',
  nameKey: 'enm.bear',
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

const _datapack = Datapack(characters: {}, enemies: {'ENM_SQUIRREL': _squirrel, 'ENM_BEAR': _bear}, stages: {});

const _stage = StageDef(
  id: 'STG_1_10',
  index: 10,
  nameKey: 'stage.1.10',
  fieldLength: 2400,
  allyBaseX: 0,
  enemyBaseX: 2400,
  enemyBaseHp: 1,
  timeLimitSec: 300,
  targetClearSec: [180, 240],
  waves: [WaveDef(enemyId: 'ENM_SQUIRREL', startSec: 0, intervalSec: 6, stopSec: 180, spawnX: 2350)],
  bossTriggers: [
    BossTriggerDef(id: 'BOSS_1', enemyId: 'ENM_BEAR', conditionKind: 'NEST_FIRST_HIT', warningTicks: 45, spawnX: 2200),
  ],
);

void main() {
  testWidgets('shows the regular enemy roster with key stats', (tester) async {
    await tester.pumpWidget(MaterialApp(home: StageBriefScreen(stage: _stage, datapack: _datapack)));

    expect(find.byKey(const ValueKey('enemy_feature_ENM_SQUIRREL')), findsOneWidget);
    expect(find.textContaining('HP 400'), findsOneWidget);
  });

  testWidgets('shows the boss condition in a readable form', (tester) async {
    await tester.pumpWidget(MaterialApp(home: StageBriefScreen(stage: _stage, datapack: _datapack)));

    expect(find.byKey(const ValueKey('boss_condition_BOSS_1')), findsOneWidget);
    expect(find.textContaining('둥지 첫 타격'), findsOneWidget);
    expect(find.textContaining('enm.bear'), findsOneWidget);
  });

  testWidgets('shows the stage timing conditions upfront', (tester) async {
    await tester.pumpWidget(MaterialApp(home: StageBriefScreen(stage: _stage, datapack: _datapack)));

    expect(find.text('제한시간 300초'), findsOneWidget);
    expect(find.text('목표 클리어 시간 180~240초'), findsOneWidget);
  });

  testWidgets('a stage with no boss trigger says so instead of crashing', (tester) async {
    const noBossStage = StageDef(
      id: 'STG_1_1',
      index: 1,
      fieldLength: 2400,
      allyBaseX: 0,
      enemyBaseX: 2400,
      enemyBaseHp: 1,
      timeLimitSec: 300,
    );
    await tester.pumpWidget(MaterialApp(home: StageBriefScreen(stage: noBossStage, datapack: _datapack)));

    expect(find.byKey(const ValueKey('no_boss')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  /// 10_WIRING_PLAN.md T-60: "출격" 동작 진입점.
  testWidgets('shows no deploy button without a callback, and invokes it when given one', (tester) async {
    const stage = StageDef(
      id: 'STG_1_1',
      index: 1,
      fieldLength: 2400,
      allyBaseX: 0,
      enemyBaseX: 2400,
      enemyBaseHp: 1,
      timeLimitSec: 300,
    );
    await tester.pumpWidget(MaterialApp(home: StageBriefScreen(stage: stage, datapack: _datapack)));
    expect(find.byKey(const ValueKey('deploy_button')), findsNothing);

    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(home: StageBriefScreen(stage: stage, datapack: _datapack, onDeployTap: () => tapped = true)),
    );
    await tester.tap(find.byKey(const ValueKey('deploy_button')));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
