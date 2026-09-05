import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/domain/tutorial/tutorial_gate.dart';
import 'package:wse_defense/domain/tutorial/tutorial_step.dart';
import 'package:wse_defense/domain/tutorial/tutorial_controller.dart';

import 'support/in_memory_tutorial_store.dart';

BattleWorld _newWorld({int startingPrayerPower = 0}) => BattleWorld(
  config: BattleConfig(
    stage: const StageDef(
      id: 'STG_TEST',
      index: 1,
      fieldLength: 2400,
      allyBaseX: 0,
      enemyBaseX: 2400,
      enemyBaseHp: 1000,
      timeLimitSec: 300,
    ),
    allyBaseHp: 1000,
    startingPrayerPower: startingPrayerPower,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: const [],
)..phase = BattlePhase.running;

const _steps = [
  TutorialStep(id: 'A', textKey: 't.a', gate: PrayerAtLeastGate(50)),
  TutorialStep(id: 'B', textKey: 't.b', gate: PrayerAtLeastGate(100)),
];

void main() {
  test('advances exactly one step per satisfied gate, in order', () {
    final store = InMemoryTutorialStore();
    final controller = TutorialController(steps: _steps, store: store);
    expect(controller.currentStep?.id, 'A');

    final ctx0 = TutorialContext(world: _newWorld(startingPrayerPower: 0));
    expect(controller.tick(ctx0), isFalse);
    expect(controller.currentStep?.id, 'A'); // 아직 그대로

    final ctx60 = TutorialContext(world: _newWorld(startingPrayerPower: 60));
    expect(controller.tick(ctx60), isTrue);
    expect(controller.currentStep?.id, 'B'); // 다음 단계로

    expect(controller.tick(ctx60), isFalse); // B의 조건(100)은 아직 미달
    final ctx100 = TutorialContext(world: _newWorld(startingPrayerPower: 100));
    expect(controller.tick(ctx100), isTrue);
    expect(controller.isComplete, isTrue);
  });

  test('each completed step is recorded in the store as it passes', () {
    final store = InMemoryTutorialStore();
    final controller = TutorialController(steps: _steps, store: store);
    controller.tick(TutorialContext(world: _newWorld(startingPrayerPower: 100)));

    expect(store.isCompleted('A'), isTrue);
    expect(store.isCompleted('B'), isFalse);
  });

  test('완료조건: 중단 후 재개 -- 이미 완료된 단계는 새 컨트롤러에서 건너뛴다', () {
    final store = InMemoryTutorialStore()..markCompleted('A');
    final resumed = TutorialController(steps: _steps, store: store);

    expect(resumed.currentStep?.id, 'B'); // A는 이미 끝났으니 B부터
  });

  test('모든 단계가 이미 완료돼 있으면 새 컨트롤러는 곧바로 isComplete', () {
    final store = InMemoryTutorialStore()
      ..markCompleted('A')
      ..markCompleted('B');
    final resumed = TutorialController(steps: _steps, store: store);

    expect(resumed.isComplete, isTrue);
    expect(resumed.currentStep, isNull);
  });
}
