/// 04_DATA_SCHEMA.md §9 관련 로컬 계정 상태. 서버 미러(T-36 이후)가
/// 붙기 전까지는 이게 유일한 진실 소스다 — 그래서 굳이 freezed를 쓰지
/// 않고(정적 JSON 데이터가 아니라 매 레벨업마다 바뀌는 런타임 상태) 얕은
/// `copyWith`만 있는 평범한 불변 클래스로 둔다.
class AccountState {
  const AccountState({
    required this.gold,
    required this.ownedCharacterIds,
    this.bondLevel = 1,
    this.focusLevel = 1,
    this.campLevel = 1,
    this.clearedStageIds = const {},
    this.exchangePoint = 0,
  });

  final int gold;
  final Set<String> ownedCharacterIds;
  final int bondLevel; // 동행 레벨
  final int focusLevel; // 소녀의 집중력
  final int campLevel; // 캠프 방어(모닥불 HP)
  final Set<String> clearedStageIds;
  final int exchangePoint; // 소환 교환 포인트(배너 간 공유·이월)

  AccountState copyWith({
    int? gold,
    Set<String>? ownedCharacterIds,
    int? bondLevel,
    int? focusLevel,
    int? campLevel,
    Set<String>? clearedStageIds,
    int? exchangePoint,
  }) => AccountState(
    gold: gold ?? this.gold,
    ownedCharacterIds: ownedCharacterIds ?? this.ownedCharacterIds,
    bondLevel: bondLevel ?? this.bondLevel,
    focusLevel: focusLevel ?? this.focusLevel,
    campLevel: campLevel ?? this.campLevel,
    clearedStageIds: clearedStageIds ?? this.clearedStageIds,
    exchangePoint: exchangePoint ?? this.exchangePoint,
  );
}

/// 10_WIRING_PLAN.md T-60~T-62: 거의 모든 Callable 응답이 `AccountPatch`
/// (06_BACKEND.md §4.1 `{currency: {...}, growth: {...}}`)를 들고 온다 --
/// 화면마다 그 JSON을 직접 파싱하지 않도록 여기 한 곳에 모은다. 없는
/// 필드는 그대로 두고(null이면 무시), 이 클래스가 모르는 통화(예:
/// recruitTicket/collectFragment)는 아직 AccountState에 자리가 없어 조용히
/// 버린다 -- 필요해지면 그때 필드를 늘린다.
extension AccountPatchApplication on AccountState {
  AccountState applyPatch(Map<String, dynamic>? patch) {
    if (patch == null) return this;
    final currency = patch['currency'] as Map?;
    final growth = patch['growth'] as Map?;
    return copyWith(
      gold: (currency?['gold'] as num?)?.toInt() ?? gold,
      exchangePoint: (currency?['exchangePoint'] as num?)?.toInt() ?? exchangePoint,
      bondLevel: (growth?['bondLevel'] as num?)?.toInt() ?? bondLevel,
      focusLevel: (growth?['focusLevel'] as num?)?.toInt() ?? focusLevel,
      campLevel: (growth?['campDefenseLevel'] as num?)?.toInt() ?? campLevel,
    );
  }

  /// 소환(gachaPull)/교환 픽업(exchangePickup)으로 새로 얻은 캐릭터를
  /// 보유 목록에 더한다 — 이미 있는 id는 Set이라 자연히 중복 없이 유지된다.
  AccountState withOwnedCharacters(Iterable<String> newIds) =>
      copyWith(ownedCharacterIds: {...ownedCharacterIds, ...newIds});
}
