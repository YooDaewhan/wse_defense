import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/domain/tutorial/tutorial_controller.dart';
import 'package:wse_defense/domain/tutorial/tutorial_step.dart';
import 'package:wse_defense/presentation/screens/battle/battle_screen.dart';

import '../../../domain/tutorial/support/in_memory_tutorial_store.dart';

const _cheap = UnitDef(
  id: 'CHR_CHEAP',
  base: UnitBaseStats(
    summonCost: 75,
    maxHp: 100,
    atk: 10,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
    resummonCooldownSec: 5,
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
    formation: [_cheap],
    startingPrayerPower: 0, // T1(PrayerAtLeastGate(75))이 처음부터 충족돼 버리지 않게
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: const [],
)..phase = BattlePhase.running;

/// 10_WIRING_PLAN.md T-57: `/tutorial`이 실제 `TutorialController`+
/// `TutorialOverlay`로 진행되는지 화면 단위로 확인한다(순수 로직 진행은
/// domain/tutorial/tutorial_flow_test.dart가 이미 검증했다).
void main() {
  testWidgets('shows the current tutorial step\'s text as an overlay on top of the battle', (tester) async {
    final world = _newWorld();
    final controller = TutorialController(steps: tutorialSteps, store: InMemoryTutorialStore());

    await tester.pumpWidget(
      MaterialApp(home: BattleScreen(world: world, tutorialController: controller)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byKey(const ValueKey('tutorial_overlay')), findsOneWidget);
    expect(find.text(tutorialSteps.first.textKey), findsOneWidget);
  });

  testWidgets('advances to the next step once its gate is satisfied', (tester) async {
    final world = _newWorld();
    final store = InMemoryTutorialStore();
    final controller = TutorialController(steps: tutorialSteps, store: store);

    await tester.pumpWidget(
      MaterialApp(home: BattleScreen(world: world, tutorialController: controller)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(controller.currentStep?.id, 'T1'); // PrayerAtLeastGate(75), 아직 미달

    world.prayerPower = 75; // T1 게이트 충족
    await tester.pump(const Duration(milliseconds: 16));

    expect(store.isCompleted('T1'), isTrue);
    expect(controller.currentStep?.id, 'T2');
    expect(find.text(tutorialSteps[1].textKey), findsOneWidget);
  });

  testWidgets('shows nothing once the tutorial is already complete', (tester) async {
    final world = _newWorld();
    final store = InMemoryTutorialStore();
    for (final step in tutorialSteps) {
      store.markCompleted(step.id);
    }
    final controller = TutorialController(steps: tutorialSteps, store: store);

    await tester.pumpWidget(
      MaterialApp(home: BattleScreen(world: world, tutorialController: controller)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(controller.isComplete, isTrue);
    expect(find.byKey(const ValueKey('tutorial_overlay')), findsNothing);
  });
}
