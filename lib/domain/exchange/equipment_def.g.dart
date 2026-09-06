// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_def.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EquipmentDef _$EquipmentDefFromJson(Map<String, dynamic> json) =>
    _EquipmentDef(
      id: json['id'] as String,
      nameKey: json['nameKey'] as String,
      originDungeonId: json['originDungeonId'] as String,
      grantTagId: json['grantTagId'] as String?,
      grantTagBaseLevel: (json['grantTagBaseLevel'] as num?)?.toInt() ?? 0,
      tagBonusAtEnhance5: json['tagBonusAtEnhance5'] as bool? ?? false,
      baseModKey: json['baseModKey'] as String? ?? '',
      baseModValue: json['baseModValue'] as num? ?? 0,
    );

Map<String, dynamic> _$EquipmentDefToJson(_EquipmentDef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameKey': instance.nameKey,
      'originDungeonId': instance.originDungeonId,
      'grantTagId': instance.grantTagId,
      'grantTagBaseLevel': instance.grantTagBaseLevel,
      'tagBonusAtEnhance5': instance.tagBonusAtEnhance5,
      'baseModKey': instance.baseModKey,
      'baseModValue': instance.baseModValue,
    };

_EquipmentCatalog _$EquipmentCatalogFromJson(Map<String, dynamic> json) =>
    _EquipmentCatalog(
      equipments:
          (json['equipments'] as List<dynamic>?)
              ?.map((e) => EquipmentDef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EquipmentDef>[],
    );

Map<String, dynamic> _$EquipmentCatalogToJson(_EquipmentCatalog instance) =>
    <String, dynamic>{'equipments': instance.equipments};
