// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_def.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BannerCost _$BannerCostFromJson(Map<String, dynamic> json) => _BannerCost(
  single: CostEntry.fromJson(json['single'] as Map<String, dynamic>),
  ten: CostEntry.fromJson(json['ten'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BannerCostToJson(_BannerCost instance) =>
    <String, dynamic>{'single': instance.single, 'ten': instance.ten};

_RateEntry _$RateEntryFromJson(Map<String, dynamic> json) => _RateEntry(
  rarity: (json['rarity'] as num).toInt(),
  pickup: json['pickup'] as bool? ?? false,
  totalPct: (json['totalPct'] as num).toInt(),
  pool: (json['pool'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$RateEntryToJson(_RateEntry instance) =>
    <String, dynamic>{
      'rarity': instance.rarity,
      'pickup': instance.pickup,
      'totalPct': instance.totalPct,
      'pool': instance.pool,
    };

_DuplicateConversion _$DuplicateConversionFromJson(Map<String, dynamic> json) =>
    _DuplicateConversion(
      rarity3: (json['rarity3'] as num).toInt(),
      rarity2: (json['rarity2'] as num).toInt(),
      rarity1: (json['rarity1'] as num).toInt(),
      item: json['item'] as String,
    );

Map<String, dynamic> _$DuplicateConversionToJson(
  _DuplicateConversion instance,
) => <String, dynamic>{
  'rarity3': instance.rarity3,
  'rarity2': instance.rarity2,
  'rarity1': instance.rarity1,
  'item': instance.item,
};

_BannerDef _$BannerDefFromJson(Map<String, dynamic> json) => _BannerDef(
  id: json['id'] as String,
  kind: json['kind'] as String,
  nameKey: json['nameKey'] as String,
  startAtUtc: json['startAtUtc'] == null
      ? null
      : DateTime.parse(json['startAtUtc'] as String),
  endAtUtc: json['endAtUtc'] == null
      ? null
      : DateTime.parse(json['endAtUtc'] as String),
  cost: BannerCost.fromJson(json['cost'] as Map<String, dynamic>),
  givesExchangePoint: json['givesExchangePoint'] as bool? ?? false,
  rates: (json['rates'] as List<dynamic>)
      .map((e) => RateEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  duplicateConversion: DuplicateConversion.fromJson(
    json['duplicateConversion'] as Map<String, dynamic>,
  ),
  exchangeTargets:
      (json['exchangeTargets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$BannerDefToJson(_BannerDef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'nameKey': instance.nameKey,
      'startAtUtc': instance.startAtUtc?.toIso8601String(),
      'endAtUtc': instance.endAtUtc?.toIso8601String(),
      'cost': instance.cost,
      'givesExchangePoint': instance.givesExchangePoint,
      'rates': instance.rates,
      'duplicateConversion': instance.duplicateConversion,
      'exchangeTargets': instance.exchangeTargets,
    };

_GachaExchangeRule _$GachaExchangeRuleFromJson(Map<String, dynamic> json) =>
    _GachaExchangeRule(
      pointPerPull: (json['pointPerPull'] as num).toInt(),
      requiredPoints: (json['requiredPoints'] as num).toInt(),
      carryOver: json['carryOver'] as bool? ?? true,
    );

Map<String, dynamic> _$GachaExchangeRuleToJson(_GachaExchangeRule instance) =>
    <String, dynamic>{
      'pointPerPull': instance.pointPerPull,
      'requiredPoints': instance.requiredPoints,
      'carryOver': instance.carryOver,
    };

_BannerCatalog _$BannerCatalogFromJson(Map<String, dynamic> json) =>
    _BannerCatalog(
      banners:
          (json['banners'] as List<dynamic>?)
              ?.map((e) => BannerDef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <BannerDef>[],
      exchange: GachaExchangeRule.fromJson(
        json['exchange'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$BannerCatalogToJson(_BannerCatalog instance) =>
    <String, dynamic>{
      'banners': instance.banners,
      'exchange': instance.exchange,
    };
