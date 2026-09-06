import 'package:freezed_annotation/freezed_annotation.dart';

import '../exchange/exchange_def.dart';

part 'banner_def.freezed.dart';
part 'banner_def.g.dart';

@freezed
abstract class BannerCost with _$BannerCost {
  const factory BannerCost({required CostEntry single, required CostEntry ten}) = _BannerCost;

  factory BannerCost.fromJson(Map<String, Object?> json) => _$BannerCostFromJson(json);
}

/// 04_DATA_SCHEMA.md §12 `rates[]` 항목. `totalPct`는 밀리퍼센트(100000=100%).
@freezed
abstract class RateEntry with _$RateEntry {
  const factory RateEntry({
    required int rarity,
    @Default(false) bool pickup,
    required int totalPct,
    required List<String> pool,
  }) = _RateEntry;

  factory RateEntry.fromJson(Map<String, Object?> json) => _$RateEntryFromJson(json);
}

@freezed
abstract class DuplicateConversion with _$DuplicateConversion {
  const factory DuplicateConversion({
    required int rarity3,
    required int rarity2,
    required int rarity1,
    required String item,
  }) = _DuplicateConversion;

  factory DuplicateConversion.fromJson(Map<String, Object?> json) => _$DuplicateConversionFromJson(json);
}

@freezed
abstract class BannerDef with _$BannerDef {
  const factory BannerDef({
    required String id,
    required String kind, // STANDARD | THEME | COLLAB
    required String nameKey,
    DateTime? startAtUtc,
    DateTime? endAtUtc,
    required BannerCost cost,
    @Default(false) bool givesExchangePoint,
    required List<RateEntry> rates,
    required DuplicateConversion duplicateConversion,
    @Default(<String>[]) List<String> exchangeTargets,
  }) = _BannerDef;

  factory BannerDef.fromJson(Map<String, Object?> json) => _$BannerDefFromJson(json);
}

@freezed
abstract class GachaExchangeRule with _$GachaExchangeRule {
  const factory GachaExchangeRule({
    required int pointPerPull,
    required int requiredPoints,
    @Default(true) bool carryOver,
  }) = _GachaExchangeRule;

  factory GachaExchangeRule.fromJson(Map<String, Object?> json) => _$GachaExchangeRuleFromJson(json);
}

@freezed
abstract class BannerCatalog with _$BannerCatalog {
  const factory BannerCatalog({
    @Default(<BannerDef>[]) List<BannerDef> banners,
    required GachaExchangeRule exchange,
  }) = _BannerCatalog;

  factory BannerCatalog.fromJson(Map<String, Object?> json) => _$BannerCatalogFromJson(json);
}
