import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/constants.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/domain/tutorial/tutorial_gate.dart';

const _unit = UnitDef(
  id: 'CHR_ACORN',
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

BattleWorld _newWorld({int startingPrayerPower = 200}) => BattleWorld(
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

void main() {
  test('PrayerAtLeastGate', () {
    final ctx75 = TutorialContext(world: _newWorld(startingPrayerPower: 75));
    final ctx74 = TutorialContext(world: _newWorld(startingPrayerPower: 74));
    expect(const PrayerAtLeastGate(75).isSatisfied(ctx75), isTrue);
    expect(const PrayerAtLeastGate(75).isSatisfied(ctx74), isFalse);
  });

  test('SummonedGate looks for an ally with the given def id, anywhere in the entity store', () {
    final w = _newWorld();
    final ctxBefore = TutorialContext(world: w);
    expect(const SummonedGate('CHR_ACORN').isSatisfied(ctxBefore), isFalse);

    w.spawnEntity(_unit, Side.ally, 0);
    final ctxAfter = TutorialContext(world: w);
    expect(const SummonedGate('CHR_ACORN').isSatisfied(ctxAfter), isTrue);
  });

  test('FrontlineBelowGate: satisfied once the frontmost ally has advanced close enough to the enemy base', () {
    final w = _newWorld();
    final ally = w.spawnEntity(_unit, Side.ally, 400 * posScale); // 기지(2400)까지 2000 남음
    final ctxFar = TutorialContext(world: w);
    expect(const FrontlineBelowGate(1800).isSatisfied(ctxFar), isFalse);

    ally.x = 700 * posScale; // 남은 거리 1700
    final ctxPushed = TutorialContext(world: w);
    expect(const FrontlineBelowGate(1800).isSatisfied(ctxPushed), isTrue);
  });

  test('FrontlineBelowGate falls back to the ally base position when no ally has been summoned yet', () {
    final w = _newWorld(); // allyBaseX=0, enemyBaseX=2400 -> 남은 거리 2400
    final ctx = TutorialContext(world: w);
    expect(const FrontlineBelowGate(1800).isSatisfied(ctx), isFalse); // 2400 > 1800
    expect(const FrontlineBelowGate(2500).isSatisfied(ctx), isTrue);
  });

  test('UltimateUsedGate reads the external flag, not battle state', () {
    final w = _newWorld();
    expect(const UltimateUsedGate().isSatisfied(TutorialContext(world: w)), isFalse);
    expect(const UltimateUsedGate().isSatisfied(TutorialContext(world: w, everUsedUltimate: true)), isTrue);
  });

  test('NestDestroyedGate reads the battle outcome', () {
    final w = _newWorld();
    expect(const NestDestroyedGate().isSatisfied(TutorialContext(world: w)), isFalse);
    w.outcome = BattleOutcome.allyWin;
    expect(const NestDestroyedGate().isSatisfied(TutorialContext(world: w)), isTrue);
  });

  test('RewardClaimedGate reads the external flag', () {
    final w = _newWorld();
    expect(const RewardClaimedGate().isSatisfied(TutorialContext(world: w)), isFalse);
    expect(const RewardClaimedGate().isSatisfied(TutorialContext(world: w, rewardClaimed: true)), isTrue);
  });
}
