import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_def.freezed.dart';
part 'exchange_def.g.dart';

/// 07_DUNGEON_EXCHANGE.md §5.2 `exchange.json`.
@freezed
abstract class CostEntry with _$CostEntry {
  const factory CostEntry({required String item, required int amount}) = _CostEntry;

  factory CostEntry.fromJson(Map<String, Object?> json) => _$CostEntryFromJson(json);
}

@freezed
abstract class GainDef with _$GainDef {
  const factory GainDef({
    required String type, // ITEM | CURRENCY | EQUIPMENT
    required String id,
    @Default(1) int amount,
  }) = _GainDef;

  factory GainDef.fromJson(Map<String, Object?> json) => _$GainDefFromJson(json);
}

/// 던전 난이도 해금(`DungeonUnlockDef`)과 다르게, 여기서는 "어느 던전"인지도
/// 함께 적어야 한다(교환 항목은 특정 던전에 묶여 있지 않으므로) — 그래서
/// 데이터 파일에서도 `{"dungeonId": ..., "level": ...}` 플랫 구조를 쓴다.
@freezed
abstract class ExchangeUnlockDef with _$ExchangeUnlockDef {
  const factory ExchangeUnlockDef({String? dungeonId, int? level}) = _ExchangeUnlockDef;

  factory ExchangeUnlockDef.fromJson(Map<String, Object?> json) => _$ExchangeUnlockDefFromJson(json);
}

@freezed
abstract class ExchangeEntryDef with _$ExchangeEntryDef {
  const factory ExchangeEntryDef({
    required String id,
    required List<CostEntry> cost,
    required GainDef gain,
    @Default(0) int limit, // 0 = 무제한
    @Default('NONE') String resetPeriod, // NONE | DAILY | WEEKLY | EVENT
    ExchangeUnlockDef? unlock,
  }) = _ExchangeEntryDef;

  factory ExchangeEntryDef.fromJson(Map<String, Object?> json) => _$ExchangeEntryDefFromJson(json);
}

@freezed
abstract class ShopDef with _$ShopDef {
  const factory ShopDef({
    required String id,
    required String nameKey,
    @Default(<ExchangeEntryDef>[]) List<ExchangeEntryDef> entries,
  }) = _ShopDef;

  factory ShopDef.fromJson(Map<String, Object?> json) => _$ShopDefFromJson(json);
}

@freezed
abstract class ExchangeConfig with _$ExchangeConfig {
  const factory ExchangeConfig({
    @Default(<ExchangeEntryDef>[]) List<ExchangeEntryDef> upgrades,
    @Default(<ShopDef>[]) List<ShopDef> shops,
  }) = _ExchangeConfig;

  factory ExchangeConfig.fromJson(Map<String, Object?> json) => _$ExchangeConfigFromJson(json);
}
