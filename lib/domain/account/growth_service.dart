import '../growth/growth_config.dart';
import 'account_state.dart';

enum LevelUpResult { ok, notEnoughGold, maxLevel }

class LevelUpOutcome {
  const LevelUpOutcome({required this.result, required this.state});

  final LevelUpResult result;

  /// 실패하면 [state]는 입력받은 계정 그대로(변경 없음) — 04_DATA_SCHEMA.md
  /// §9: 골드가 부족하면 거부, 부분 차감 없음.
  final AccountState state;

  bool get isSuccess => result == LevelUpResult.ok;
}

/// 09_MILESTONES.md T-30: "레벨업이 growth.json 보간과 일치, 골드 부족 시
/// 거부". 실제 스탯 보간(FocusStats/campHp)은 [growth_math.dart]가 맡고,
/// 여기서는 순수하게 "레벨을 올릴 수 있는가/올린다"만 다룬다.
LevelUpOutcome levelUpFocus(AccountState account, GrowthConfig growth) {
  final cost = growth.focusGoldCost.costForLevelUp(account.focusLevel);
  if (account.gold < cost) {
    return LevelUpOutcome(result: LevelUpResult.notEnoughGold, state: account);
  }
  return LevelUpOutcome(
    result: LevelUpResult.ok,
    state: account.copyWith(gold: account.gold - cost, focusLevel: account.focusLevel + 1),
  );
}

LevelUpOutcome levelUpCamp(AccountState account, GrowthConfig growth) {
  final cost = growth.campGoldCost.costForLevelUp(account.campLevel);
  if (account.gold < cost) {
    return LevelUpOutcome(result: LevelUpResult.notEnoughGold, state: account);
  }
  return LevelUpOutcome(
    result: LevelUpResult.ok,
    state: account.copyWith(gold: account.gold - cost, campLevel: account.campLevel + 1),
  );
}

LevelUpOutcome levelUpBond(AccountState account, GrowthConfig growth) {
  if (account.bondLevel >= growth.bondMaxLevel) {
    return LevelUpOutcome(result: LevelUpResult.maxLevel, state: account);
  }
  final cost = growth.bondGoldCost.costForLevelUp(account.bondLevel);
  if (account.gold < cost) {
    return LevelUpOutcome(result: LevelUpResult.notEnoughGold, state: account);
  }
  return LevelUpOutcome(
    result: LevelUpResult.ok,
    state: account.copyWith(gold: account.gold - cost, bondLevel: account.bondLevel + 1),
  );
}
