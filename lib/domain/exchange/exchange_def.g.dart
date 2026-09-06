// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_def.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CostEntry _$CostEntryFromJson(Map<String, dynamic> json) => _CostEntry(
  item: json['item'] as String,
  amount: (json['amount'] as num).toInt(),
);

Map<String, dynamic> _$CostEntryToJson(_CostEntry instance) =>
    <String, dynamic>{'item': instance.item, 'amount': instance.amount};

_GainDef _$GainDefFromJson(Map<String, dynamic> json) => _GainDef(
  type: json['type'] as String,
  id: json['id'] as String,
  amount: (json['amount'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$GainDefToJson(_GainDef instance) => <String, dynamic>{
  'type': instance.type,
  'id': instance.id,
  'amount': instance.amount,
};

_ExchangeUnlockDef _$ExchangeUnlockDefFromJson(Map<String, dynamic> json) =>
    _ExchangeUnlockDef(
      dungeonId: json['dungeonId'] as String?,
      level: (json['level'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ExchangeUnlockDefToJson(_ExchangeUnlockDef instance) =>
    <String, dynamic>{'dungeonId': instance.dungeonId, 'level': instance.level};

_ExchangeEntryDef _$ExchangeEntryDefFromJson(Map<String, dynamic> json) =>
    _ExchangeEntryDef(
      id: json['id'] as String,
      cost: (json['cost'] as List<dynamic>)
          .map((e) => CostEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      gain: GainDef.fromJson(json['gain'] as Map<String, dynamic>),
      limit: (json['limit'] as num?)?.toInt() ?? 0,
      resetPeriod: json['resetPeriod'] as String? ?? 'NONE',
      unlock: json['unlock'] == null
          ? null
          : ExchangeUnlockDef.fromJson(json['unlock'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExchangeEntryDefToJson(_ExchangeEntryDef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cost': instance.cost,
      'gain': instance.gain,
      'limit': instance.limit,
      'resetPeriod': instance.resetPeriod,
      'unlock': instance.unlock,
    };

_ShopDef _$ShopDefFromJson(Map<String, dynamic> json) => _ShopDef(
  id: json['id'] as String,
  nameKey: json['nameKey'] as String,
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map((e) => ExchangeEntryDef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ExchangeEntryDef>[],
);

Map<String, dynamic> _$ShopDefToJson(_ShopDef instance) => <String, dynamic>{
  'id': instance.id,
  'nameKey': instance.nameKey,
  'entries': instance.entries,
};

_ExchangeConfig _$ExchangeConfigFromJson(Map<String, dynamic> json) =>
    _ExchangeConfig(
      upgrades:
          (json['upgrades'] as List<dynamic>?)
              ?.map((e) => ExchangeEntryDef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ExchangeEntryDef>[],
      shops:
          (json['shops'] as List<dynamic>?)
              ?.map((e) => ShopDef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ShopDef>[],
    );

Map<String, dynamic> _$ExchangeConfigToJson(_ExchangeConfig instance) =>
    <String, dynamic>{'upgrades': instance.upgrades, 'shops': instance.shops};
