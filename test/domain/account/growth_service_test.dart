import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/account/account_state.dart';
import 'package:wse_defense/domain/account/growth_service.dart';
import 'package:wse_defense/domain/growth/growth_config.dart';

const _growth = GrowthConfig(
  focusKeyframes: [
    FocusKeyframe(level: 1, regenPerSec: 18, cap: 1000, startAmount: 200),
    FocusKeyframe(level: 10, regenPerSec: 31, cap: 1600, startAmount: 250),
  ],
  focusGoldCost: GoldCostFormula(base: 500, growth: 1.18),
  campKeyframes: [
    CampKeyframe(level: 1, hp: 10000),
    CampKeyframe(level: 10, hp: 28000),
  ],
  campGoldCost: GoldCostFormula(base: 400, growth: 1.20),
  focusBoost: [],
  bondMaxLevel: 3,
  bondGoldCost: GoldCostFormula(base: 200, growth: 1.12),
);

void main() {
  group('levelUpFocus', () {
    test('succeeds and deducts exactly the formula cost when gold is enough', () {
      const account = AccountState(gold: 1000, ownedCharacterIds: {});
      final outcome = levelUpFocus(account, _growth);

      expect(outcome.isSuccess, isTrue);
      expect(outcome.state.focusLevel, 2);
      expect(outcome.state.gold, 1000 - _growth.focusGoldCost.costForLevelUp(1));
    });

    test('is rejected outright when gold is short, and the account is unchanged', () {
      const account = AccountState(gold: 100, ownedCharacterIds: {});
      final outcome = levelUpFocus(account, _growth);

      expect(outcome.result, LevelUpResult.notEnoughGold);
      expect(outcome.state.focusLevel, 1); // 변화 없음
      expect(outcome.state.gold, 100); // 부분 차감 없음
    });
  });

  group('levelUpCamp', () {
    test('succeeds when affordable', () {
      const account = AccountState(gold: 1000, ownedCharacterIds: {});
      final outcome = levelUpCamp(account, _growth);
      expect(outcome.isSuccess, isTrue);
      expect(outcome.state.campLevel, 2);
    });

    test('rejected when not affordable', () {
      const account = AccountState(gold: 10, ownedCharacterIds: {});
      final outcome = levelUpCamp(account, _growth);
      expect(outcome.result, LevelUpResult.notEnoughGold);
      expect(outcome.state.campLevel, 1);
    });
  });

  group('levelUpBond', () {
    test('rejected at the configured max level even with unlimited gold', () {
      const account = AccountState(gold: 999999999, ownedCharacterIds: {}, bondLevel: 3);
      final outcome = levelUpBond(account, _growth);
      expect(outcome.result, LevelUpResult.maxLevel);
      expect(outcome.state.bondLevel, 3);
    });

    test('succeeds below the max level when affordable', () {
      const account = AccountState(gold: 1000, ownedCharacterIds: {}, bondLevel: 1);
      final outcome = levelUpBond(account, _growth);
      expect(outcome.isSuccess, isTrue);
      expect(outcome.state.bondLevel, 2);
    });
  });
}
