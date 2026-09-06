import 'package:freezed_annotation/freezed_annotation.dart';

part 'equipment_def.freezed.dart';
part 'equipment_def.g.dart';

/// `assets/data/v1/equipments.json`. 07_DUNGEON_EXCHANGE.md §6.
/// 고정 옵션(`baseModKey`/`baseModValue`)의 실제 전투 스탯 반영은 스코프
/// 밖(어떤 티켓도 요구하지 않음) — 표시/교환/강화 로직에만 쓴다.
@freezed
abstract class EquipmentDef with _$EquipmentDef {
  const factory EquipmentDef({
    required String id,
    required String nameKey,
    required String originDungeonId,
    String? grantTagId,
    @Default(0) int grantTagBaseLevel,
    @Default(false) bool tagBonusAtEnhance5,
    @Default('') String baseModKey,
    @Default(0) num baseModValue,
  }) = _EquipmentDef;

  factory EquipmentDef.fromJson(Map<String, Object?> json) => _$EquipmentDefFromJson(json);
}

@freezed
abstract class EquipmentCatalog with _$EquipmentCatalog {
  const factory EquipmentCatalog({@Default(<EquipmentDef>[]) List<EquipmentDef> equipments}) = _EquipmentCatalog;

  factory EquipmentCatalog.fromJson(Map<String, Object?> json) => _$EquipmentCatalogFromJson(json);
}
