/// 02_TAG_SYSTEM.md §3.3: 태그가 어디서 왔는지 태깅해두면, 출처가 사라질 때
/// (버프 만료 등) 그 contribution만 골라서 빼고 TagStack을 다시 계산할 수 있다.
enum TagSourceKind { intrinsic, equipment, skill, buff, stage }

class TagContribution {
  const TagContribution({
    required this.tagIndex,
    required this.amount,
    required this.kind,
    required this.sourceId,
    this.expireTick,
  });

  final int tagIndex;

  /// 보통 +1.
  final int amount;
  final TagSourceKind kind;

  /// "EQP_ANIMAL_MASK", "SKL_BEAR_ROAR" 등.
  final String sourceId;

  /// null이면 영구(수동 제거 전까지).
  final int? expireTick;
}
