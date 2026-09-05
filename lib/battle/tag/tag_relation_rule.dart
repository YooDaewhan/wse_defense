import 'tag_effect_def.dart' show StatModDef;
import 'tag_query.dart';
import 'tag_registry.dart';

/// 02_TAG_SYSTEM.md §4.4.
enum RelationKind {
  otherIsAhead,
  otherIsBehind,
  otherIsAdjacent,
  otherIsFrontmost,
  subjectIsFrontmost,
  subjectIsRearmost,
  noOtherAhead,
  enemyWithin,
}

RelationKind _relationFromJson(String raw) => switch (raw) {
  'OTHER_IS_AHEAD' => RelationKind.otherIsAhead,
  'OTHER_IS_BEHIND' => RelationKind.otherIsBehind,
  'OTHER_IS_ADJACENT' => RelationKind.otherIsAdjacent,
  'OTHER_IS_FRONTMOST' => RelationKind.otherIsFrontmost,
  'SUBJECT_IS_FRONTMOST' => RelationKind.subjectIsFrontmost,
  'SUBJECT_IS_REARMOST' => RelationKind.subjectIsRearmost,
  'NO_OTHER_AHEAD' => RelationKind.noOtherAhead,
  'ENEMY_WITHIN' => RelationKind.enemyWithin,
  _ => throw FormatException('알 수 없는 RelationKind: $raw'),
};

/// §4.3.
class TagRelationRule {
  const TagRelationRule({
    required this.id,
    this.nameKey = '',
    required this.subject,
    required this.other,
    required this.relation,
    this.rangeMin = 0,
    this.rangeMax = 0, // 0 = 무제한
    this.requireCount = 1,
    this.scaleByOtherCount = false,
    this.scaleBySubjectTagLevel = false,
    this.maxScale = 1 << 30,
    this.mods = const [],
    this.minActiveTicks = 0,
    this.offDelayTicks = 0,
  });

  final String id;

  /// 표시용 이름 키(편성 화면의 관계 규칙 예고 등, T-31). 전투 로직에는
  /// 전혀 관여하지 않는 순수 메타데이터라 없어도(빈 문자열) 동작에 지장 없다.
  final String nameKey;
  final TagQuery subject;
  final TagQuery other;
  final RelationKind relation;
  final int rangeMin;
  final int rangeMax;
  final int requireCount;
  final bool scaleByOtherCount;

  /// subject.hasTags[0]의 레벨로 배율을 정한다 (예: 겁쟁이Lv2 -> 2배).
  /// 규칙에 subject를 정의하는 "주" 태그가 정확히 하나라고 가정한다 — 지금
  /// 데이터가 전부 그렇고, 스키마에 이걸 명시하는 별도 필드가 없다.
  final bool scaleBySubjectTagLevel;
  final int maxScale;
  final List<StatModDef> mods;

  /// 한 번 켜지면 최소 이만큼(틱) 유지 (진동 방지).
  final int minActiveTicks;

  /// 조건 해제 후 이만큼(틱) 지나야 실제로 꺼진다.
  final int offDelayTicks;

  factory TagRelationRule.fromJson(
    Map<String, Object?> json,
    TagRegistry registry,
  ) => TagRelationRule(
    id: json['id'] as String,
    nameKey: json['nameKey'] as String? ?? '',
    subject: TagQuery.fromJson(json['subject'] as Map<String, Object?>, registry),
    other: TagQuery.fromJson(json['other'] as Map<String, Object?>, registry),
    relation: _relationFromJson(json['relation'] as String),
    rangeMin: json['rangeMin'] as int? ?? 0,
    rangeMax: json['rangeMax'] as int? ?? 0,
    requireCount: json['requireCount'] as int? ?? 1,
    scaleByOtherCount: json['scaleByOtherCount'] as bool? ?? false,
    scaleBySubjectTagLevel: json['scaleBySubjectTagLevel'] as bool? ?? false,
    maxScale: json['maxScale'] as int? ?? (1 << 30),
    mods: [
      for (final m in (json['mods'] as List<Object?>? ?? const []))
        StatModDef.fromJson(m as Map<String, Object?>),
    ],
    minActiveTicks: json['minActiveTicks'] as int? ?? 0,
    offDelayTicks: json['offDelayTicks'] as int? ?? 0,
  );
}
