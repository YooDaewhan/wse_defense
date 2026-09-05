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
  });

  final int gold;
  final Set<String> ownedCharacterIds;
  final int bondLevel; // 동행 레벨
  final int focusLevel; // 소녀의 집중력
  final int campLevel; // 캠프 방어(모닥불 HP)

  AccountState copyWith({
    int? gold,
    Set<String>? ownedCharacterIds,
    int? bondLevel,
    int? focusLevel,
    int? campLevel,
  }) => AccountState(
    gold: gold ?? this.gold,
    ownedCharacterIds: ownedCharacterIds ?? this.ownedCharacterIds,
    bondLevel: bondLevel ?? this.bondLevel,
    focusLevel: focusLevel ?? this.focusLevel,
    campLevel: campLevel ?? this.campLevel,
  );
}
