import 'package:flutter/widgets.dart';

import '../battle/defs/datapack.dart';
import '../battle/defs/weather_config.dart';
import '../data/battle_config/weather_config_loader.dart';
import '../data/datapack/datapack_loader.dart';
import '../data/dungeon/dungeon_data_loader.dart';
import '../data/exchange/equipment_data_loader.dart';
import '../data/exchange/exchange_data_loader.dart';
import '../data/gacha/banner_data_loader.dart';
import '../data/growth/growth_config_loader.dart';
import '../data/local/formation_repository.dart';
import '../data/local/journal_repository.dart';
import '../data/local/pending_submits_repository.dart';
import '../data/local/settings_repository.dart';
import '../data/local/tutorial_repository.dart';
import '../data/story/story_loader.dart';
import '../data/tag/tag_data_loader.dart';
import '../domain/account/account_state.dart';
import '../domain/dungeon/dungeon_def.dart';
import '../domain/exchange/equipment_def.dart';
import '../domain/exchange/exchange_def.dart';
import '../domain/gacha/banner_def.dart';
import '../domain/growth/growth_config.dart';
import '../domain/story/story_beat.dart';

/// 10_WIRING_PLAN.md T-56: 부팅 시 한 번 채워지고 앱 전체가 읽는 상태
/// 컨테이너. 로더 9종(아래 [loadStaticData])의 결과, 계정 상태, 로컬
/// 리포지토리 5종을 담는다 — 그 이상도 이하도 아니다. 상태관리 패키지를
/// 새로 넣지 않고 `ChangeNotifier` 하나로 충분하다.
class AppScope extends ChangeNotifier {
  AppScope({
    required this.formation,
    required this.journal,
    required this.tutorial,
    required this.pendingSubmits,
    required this.settings,
  });

  final FormationStore formation;
  final JournalStore journal;
  final TutorialStore tutorial;
  final PendingSubmitsStore pendingSubmits;
  final SettingsStore settings;

  Datapack? datapack;
  TagBundle? tagBundle;
  DungeonConfig? dungeonConfig;
  ExchangeConfig? exchangeConfig;
  EquipmentCatalog? equipmentCatalog;
  BannerCatalog? bannerCatalog;
  GrowthConfig? growthConfig;
  WeatherConfig? weatherConfig;
  List<StoryBeat>? prologueBeats;

  /// equipmentCatalog을 화면이 바로 쓰기 좋은 형태로 바꾼 편의 getter.
  Map<String, EquipmentDef> get equipmentById => {
    for (final e in equipmentCatalog?.equipments ?? const <EquipmentDef>[]) e.id: e,
  };

  AccountState account = const AccountState(gold: 0, ownedCharacterIds: {});

  void setAccount(AccountState next) {
    account = next;
    notifyListeners();
  }

  /// 스플래시가 부팅 시 한 번 부른다. 로더 9종을 순서대로 돌며 [onProgress]
  /// 를 0~1로 알린다(완료 조건: "진행률이 로더 8종 전체를 반영").
  Future<void> loadStaticData(AssetReader readJson, {void Function(double progress)? onProgress}) async {
    final steps = <Future<void> Function()>[
      () async => datapack = await DatapackLoader(readJson).load(),
      () async => tagBundle = await loadTagBundle(readJson),
      () async => dungeonConfig = await loadDungeonConfig(readJson),
      () async => exchangeConfig = await loadExchangeConfig(readJson),
      () async => equipmentCatalog = await loadEquipmentCatalog(readJson),
      () async => bannerCatalog = await loadBannerCatalog(readJson),
      () async => growthConfig = await loadGrowthConfig(readJson),
      () async => weatherConfig = await loadWeatherConfig(readJson),
      () async => prologueBeats = await loadStoryBeats(readJson, 'story/prologue.json'),
    ];
    for (var i = 0; i < steps.length; i++) {
      await steps[i]();
      onProgress?.call((i + 1) / steps.length);
    }
    notifyListeners();
  }
}

/// `AppScopeProvider.of(context)`로 어디서든 읽는다. 일부러
/// `dependOnInheritedWidgetOfExactType`(빌드 의존성 등록)이 아니라
/// `getInheritedWidgetOfExactType`(단순 조회)을 쓴다 -- `initState()`에서
/// 바로 읽어야 하는 화면(스플래시)이 있고, `AppScope`는 `notifyListeners()`
/// 로 직접 구독하는 게 표준이라(`ListenableBuilder`) 굳이 위젯 트리
/// 의존성까지 이중으로 걸 필요가 없다.
class AppScopeProvider extends InheritedNotifier<AppScope> {
  const AppScopeProvider({super.key, required AppScope scope, required super.child}) : super(notifier: scope);

  static AppScope of(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<AppScopeProvider>();
    assert(provider != null, 'AppScopeProvider not found in context — WseDefenseApp이 감싸고 있는지 확인');
    return provider!.notifier!;
  }
}
