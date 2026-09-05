/// 02_TAG_SYSTEM.md §8.1: 모디파이어가 어디서 왔는지 태깅해두면
/// 해당 출처(kind, id) 통째로, 또는 인스턴스 단위로 제거할 수 있다.
enum ModifierKind {
  tagUnit,
  tagFormation,
  tagField,
  relation,
  skill,
  equipment,
  weather,
  stage,
}

class ModifierSource {
  const ModifierSource(this.kind, this.id, {this.instanceId});

  final ModifierKind kind;
  final String id;

  /// 같은 스킬의 여러 인스턴스(예: 여러 소환체의 버프)를 구분한다.
  final int? instanceId;
}
