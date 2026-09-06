import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/account/account_state.dart';

const _account = AccountState(gold: 100, ownedCharacterIds: {}, bondLevel: 2, focusLevel: 3, campLevel: 4, exchangePoint: 5);

/// 10_WIRING_PLAN.md T-60~T-62: 거의 모든 Callable 응답의 AccountPatch를
/// AccountState에 반영하는 공용 지점.
void main() {
  test('a null patch changes nothing', () {
    final result = _account.applyPatch(null);
    expect(result.gold, 100);
    expect(result.exchangePoint, 5);
    expect(result.bondLevel, 2);
  });

  test('applies currency and growth fields present in the patch', () {
    final result = _account.applyPatch({
      'currency': {'gold': 250, 'exchangePoint': 10},
      'growth': {'bondLevel': 3, 'focusLevel': 4, 'campDefenseLevel': 5},
    });

    expect(result.gold, 250);
    expect(result.exchangePoint, 10);
    expect(result.bondLevel, 3);
    expect(result.focusLevel, 4);
    expect(result.campLevel, 5);
  });

  test('leaves fields untouched when the patch omits them', () {
    final result = _account.applyPatch({'currency': {'gold': 999}});

    expect(result.gold, 999);
    expect(result.exchangePoint, 5); // 안 건드림
    expect(result.bondLevel, 2); // growth 자체가 없음 -> 그대로
  });
}
