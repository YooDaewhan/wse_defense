import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/domain/account/account_state.dart';
import 'package:wse_defense/domain/battle/battle_world_builder.dart';
import 'package:wse_defense/domain/growth/growth_config.dart';

const _acorn = UnitDef(
  id: 'CHR_ACORN',
  base: UnitBaseStats(summonCost: 75, maxHp: 1200, atk: 90, attackPeriod: 60, attackWindup: 12, attackRecover: 48, attackRange: 130, moveSpeed: 100),
);

const _datapack = Datapack(characters: {'CHR_ACORN': _acorn}, enemies: {}, stages: {});

const _stage = StageDef(
  id: 'STG_1_1',
  index: 1,
  fieldLength: 2400,
  allyBaseX: 0,
  enemyBaseX: 2400,
  enemyBaseHp: 5000,
  timeLimitSec: 300,
);

const _growth = GrowthConfig(
  focusKeyframes: [FocusKeyframe(level: 1, regenPerSec: 18, cap: 1000, startAmount: 200)],
  focusGoldCost: GoldCostFormula(base: 500, growth: 1.18),
  campKeyframes: [CampKeyframe(level: 1, hp: 12345)],
  campGoldCost: GoldCostFormula(base: 400, growth: 1.20),
  focusBoost: [],
  bondMaxLevel: 3,
  bondGoldCost: GoldCostFormula(base: 200, growth: 1.12),
);

/// 10_WIRING_PLAN.md T-60.
void main() {
  test('resolves the server-confirmed formation slots to real UnitDefs, in slot order', () {
    final world = buildBattleWorldFromStart(
      stage: _stage,
      datapack: _datapack,
      seed: 42,
      formationSlots: [
        {'characterId': 'CHR_ACORN', 'equipmentInstanceId': null},
        {'characterId': null, 'equipmentInstanceId': null},
      ],
    );

    expect(world.formation, hasLength(1));
    expect(world.formation.single.def.id, 'CHR_ACORN');
  });

  test('uses growth-derived camp HP and focus stats when a GrowthConfig is given', () {
    final world = buildBattleWorldFromStart(
      stage: _stage,
      datapack: _datapack,
      seed: 1,
      formationSlots: const [],
      growthConfig: _growth,
      account: const AccountState(gold: 0, ownedCharacterIds: {}),
    );

    expect(world.allyBase.maxHp, 12345);
    expect(world.currentPrayerCap, 1000);
    expect(world.prayerPower, 200);
  });

  test('falls back to sensible defaults without a GrowthConfig', () {
    final world = buildBattleWorldFromStart(stage: _stage, datapack: _datapack, seed: 1, formationSlots: const []);

    expect(world.allyBase.maxHp, 10000);
    expect(world.prayerPower, 200);
  });
}
