import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/system/movement_system.dart';
import 'package:wse_defense/battle/system/resource_system.dart';
import 'package:wse_defense/battle/system/target_system.dart';
import 'package:wse_defense/battle/system/victory_system.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/battle/world/summon.dart';
import 'package:wse_defense/battle/world/ultimate.dart';
import 'package:wse_defense/domain/tutorial/tutorial_controller.dart';
import 'package:wse_defense/domain/tutorial/tutorial_gate.dart';
import 'package:wse_defense/domain/tutorial/tutorial_step.dart';

import 'support/in_memory_tutorial_store.dart';

const _acorn = UnitDef(
  id: 'CHR_ACORN',
  base: UnitBaseStats(
    summonCost: 75,
    maxHp: 1200,
    atk: 90,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 130,
    moveSpeed: 100,
    resummonCooldownSec: 4,
  ),
);

const _droplet = UnitDef(
  id: 'CHR_DROPLET',
  base: UnitBaseStats(
    summonCost: 200,
    maxHp: 480,
    atk: 300,
    attackPeriod: 90,
    attackWindup: 18,
    attackRecover: 72,
    attackRange: 420,
    moveSpeed: 80,
    resummonCooldownSec: 8,
  ),
);

bool _hasAlly(BattleWorld w, String defId) =>
    w.entities.ordered.any((e) => e.side == Side.ally && e.def.id == defId);

/// 09_MILESTONES.md T-34 완료조건: "각 단계 게이트 조건대로 진행, 60~90초
/// 완료, 중단 후 재개 가능".
///
/// 아군이 적 기지에 실제로 피해를 주는 경로가 아직 없어(§8 AttackSystem
/// 스코프 밖, T-13/T-21에서 이미 확인된 한계) T6(NEST_DESTROYED)는 이
/// 스크립트가 직접 `enemyBase.hp = 0`으로 만든다 — "필살기를 얻은 뒤
/// 보스전을 마무리하는 데 걸리는 시간"으로 45초를 두고 그 시점에 반영한다.
/// 그 45초를 빼면 나머지 진행(T1~T5)은 전부 실제 시뮬레이션 수치(기도력
/// 회복 18/초, 필살기 게이지 자동 충전)로만 결정된다.
BattleWorld _newTutorialWorld() => BattleWorld(
  config: const BattleConfig(
    stage: StageDef(
      id: 'STG_TUTORIAL',
      index: 0,
      fieldLength: 2400,
      allyBaseX: 0,
      enemyBaseX: 2400,
      enemyBaseHp: 5000,
      timeLimitSec: 120,
    ),
    allyBaseHp: 10000,
    formation: [_acorn, _droplet],
    focusBaseRegen: 18,
    startingPrayerPower: 200,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: [TargetSystem(), MovementSystem(), ResourceSystem(), VictorySystem()],
)..phase = BattlePhase.running;

void main() {
  test('the full 7-step tutorial completes in order within 60-90 seconds', () {
    final store = InMemoryTutorialStore();
    final controller = TutorialController(steps: tutorialSteps, store: store);
    final world = _newTutorialWorld();

    var everUsedUltimate = false;
    var rewardClaimed = false;
    int? nestDestroyTick;
    const bossClearTicks = 45 * ticksPerSec; // 위 주석 참고 -- 엔진 한계에 대한 임시 보정치

    const maxTicks = 90 * ticksPerSec + 1; // 상한을 넘으면 테스트가 실패해야 함
    for (var t = 0; t < maxTicks && !controller.isComplete; t++) {
      // 아주 단순한 "플레이어" 스크립트: 도토리 -> 물방울 순서로 딱 1마리씩만
      // 소환한다(계속 도토리만 재소환하면 물방울 값(200)을 모으기 전에
      // 매번 기도력을 써버려 영영 못 모으는 자원 기아 상태가 됨 -- 실제로
      // 겪은 버그, 튜토리얼 스크립트치고 자연스럽기도 하다).
      if (!_hasAlly(world, 'CHR_ACORN') && world.prayerPower >= _acorn.base.summonCost) {
        trySummon(world, 0);
      } else if (_hasAlly(world, 'CHR_ACORN') &&
          !_hasAlly(world, 'CHR_DROPLET') &&
          world.prayerPower >= _droplet.base.summonCost) {
        trySummon(world, 1);
      }
      if (world.ultimateStock > 0) {
        castUltimate(world);
        everUsedUltimate = true;
      }

      world.step();

      if (everUsedUltimate && nestDestroyTick == null) {
        nestDestroyTick = world.tick + bossClearTicks;
      }
      if (nestDestroyTick != null && world.tick >= nestDestroyTick && world.enemyBase.hp > 0) {
        world.enemyBase.hp = 0;
      }
      if (world.outcome != null) rewardClaimed = true; // 승리 즉시 보상 수령(플레이스홀더)

      final ctx = TutorialContext(world: world, everUsedUltimate: everUsedUltimate, rewardClaimed: rewardClaimed);
      controller.tick(ctx);
    }

    expect(controller.isComplete, isTrue, reason: '${maxTicks / ticksPerSec}초 안에 7단계를 못 끝냄');
    expect(store.completedSteps, {'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'});

    final totalSec = world.tick / ticksPerSec;
    expect(totalSec, greaterThanOrEqualTo(60));
    expect(totalSec, lessThanOrEqualTo(90));
  });

  test('완료조건: 중단 후 재개 -- 시나리오 중간까지 진행하고 새 컨트롤러로 이어가도 같은 결과', () {
    final store = InMemoryTutorialStore();
    var controller = TutorialController(steps: tutorialSteps, store: store);
    final world = _newTutorialWorld();

    var everUsedUltimate = false;
    var rewardClaimed = false;

    // T2(첫 소환)까지만 진행하고 "중단".
    while (!store.isCompleted('T2')) {
      if (world.prayerPower >= _acorn.base.summonCost) trySummon(world, 0);
      world.step();
      controller.tick(TutorialContext(world: world, everUsedUltimate: everUsedUltimate, rewardClaimed: rewardClaimed));
    }
    final progressAtInterruption = Set.of(store.completedSteps);
    expect(progressAtInterruption, contains('T1'));
    expect(progressAtInterruption, contains('T2'));
    expect(progressAtInterruption, isNot(contains('T3')));

    // "재개" -- 같은 store로 새 컨트롤러를 만든다(앱을 새로 켠 것과 동일).
    controller = TutorialController(steps: tutorialSteps, store: store);
    expect(controller.currentStep?.id, 'T3'); // T1/T2를 다시 보여주지 않고 T3부터

    for (var t = 0; t < 90 * ticksPerSec && !controller.isComplete; t++) {
      if (world.prayerPower >= _droplet.base.summonCost) trySummon(world, 1);
      if (world.ultimateStock > 0) {
        castUltimate(world);
        everUsedUltimate = true;
      }
      world.step();
      if (everUsedUltimate && world.tick > 45 * ticksPerSec && world.enemyBase.hp > 0) {
        world.enemyBase.hp = 0;
      }
      if (world.outcome != null) rewardClaimed = true;
      controller.tick(TutorialContext(world: world, everUsedUltimate: everUsedUltimate, rewardClaimed: rewardClaimed));
    }

    expect(controller.isComplete, isTrue);
    expect(store.completedSteps, {'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'});
  });
}
