import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/account/account_bootstrap.dart';

/// 10_WIRING_PLAN.md T-63.
void main() {
  test('maps currency/growth/clearedStages and the given owned characters', () {
    final data = {
      'currency': {'gold': 500, 'exchangePoint': 40},
      'growth': {'bondLevel': 2, 'focusLevel': 3, 'campDefenseLevel': 1},
      'progress': {
        'clearedStages': {'STG_1_1': {}, 'STG_1_2': {}},
      },
    };

    final account = accountStateFromBootstrap(data, {'CHR_ACORN', 'CHR_BEAR'});

    expect(account.gold, 500);
    expect(account.exchangePoint, 40);
    expect(account.bondLevel, 2);
    expect(account.focusLevel, 3);
    expect(account.campLevel, 1);
    expect(account.clearedStageIds, {'STG_1_1', 'STG_1_2'});
    expect(account.ownedCharacterIds, {'CHR_ACORN', 'CHR_BEAR'});
  });

  test('a brand-new account with no progress yet maps to empty sets', () {
    final data = {
      'currency': {'gold': 0},
      'growth': {'bondLevel': 1, 'focusLevel': 1, 'campDefenseLevel': 1},
      'progress': {'clearedStages': <String, dynamic>{}},
    };

    final account = accountStateFromBootstrap(data, {'CHR_ACORN'});

    expect(account.clearedStageIds, isEmpty);
    expect(account.ownedCharacterIds, {'CHR_ACORN'});
  });
}
