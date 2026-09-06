import 'package:go_router/go_router.dart';

import '../battle/defs/datapack.dart';
import '../battle/defs/stage_def.dart';
import '../battle/defs/unit_def.dart';
import '../battle/tag/tag_registry.dart';
import '../battle/world/battle_config.dart';
import '../battle/world/battle_world.dart';
import '../battle/world/canonical_systems.dart';
import '../data/local/journal_repository.dart';
import '../domain/dungeon/dungeon_def.dart';
import '../domain/dungeon/dungeon_progress.dart';
import '../domain/exchange/equipment_def.dart';
import '../domain/exchange/exchange_def.dart';
import '../domain/gacha/banner_def.dart';
import '../domain/story/story_beat.dart';
import '../game/battle_result.dart';
import '../presentation/screens/adventure/adventure_map_screen.dart';
import '../presentation/screens/adventure/stage_brief_screen.dart';
import '../presentation/screens/battle/battle_screen.dart';
import '../presentation/screens/battle_result/battle_result_screen.dart';
import '../presentation/screens/dungeon/dungeon_screen.dart';
import '../presentation/screens/exchange/exchange_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/summon/summon_screen.dart';
import '../presentation/screens/summon/trial_screen.dart';
import '../presentation/screens/story/story_player_screen.dart';
import '../presentation/widgets/placeholder_screen.dart';

/// 05_FRONTEND.md §2 라우트 표. 실제 화면이 아직 없는 곳은 전부
/// `PlaceholderScreen`(T-28 완료조건: "모든 라우트 진입 가능, 빈 화면 허용").
GoRouter buildAppRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/prologue',
      builder: (context, state) {
        final extra = state.extra as ({List<StoryBeat> beats, JournalStore journalStore})?;
        return StoryPlayerScreen(
          sceneId: 'story.prologue',
          beats: extra?.beats ?? const [LineBeat(textKey: 'story.prologue.l1')],
          journalStore: extra?.journalStore ?? _NoopJournalStore(),
          onFinished: () => context.go('/camp'),
        );
      },
    ),
    GoRoute(
      path: '/tutorial',
      builder: (context, state) => const PlaceholderScreen(title: '튜토리얼'),
    ),
    GoRoute(
      path: '/camp',
      builder: (context, state) => const PlaceholderScreen(title: '캠프'),
    ),
    GoRoute(
      path: '/adventure',
      builder: (context, state) {
        final extra = state.extra as ({List<StageDef> stages, Set<String> cleared, Datapack datapack})?;
        final stages = extra?.stages ?? _demoChapterStages();
        final datapack = extra?.datapack ?? const Datapack(characters: {}, enemies: {}, stages: {});
        return AdventureMapScreen(
          chapterStages: stages,
          clearedStageIds: extra?.cleared ?? const {},
          onStageTap: (stage) => context.push('/adventure/${stage.id}/brief', extra: (stage: stage, datapack: datapack)),
        );
      },
      routes: [
        GoRoute(
          path: ':stageId/brief',
          builder: (context, state) {
            final extra = state.extra as ({StageDef stage, Datapack datapack})?;
            return StageBriefScreen(
              stage: extra?.stage ?? _demoChapterStages().first,
              datapack: extra?.datapack ?? const Datapack(characters: {}, enemies: {}, stages: {}),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/formation',
      builder: (context, state) => const PlaceholderScreen(title: '편성'),
    ),
    GoRoute(
      path: '/battle',
      builder: (context, state) =>
          BattleScreen(world: (state.extra as BattleWorld?) ?? _demoBattleWorld()),
      routes: [
        GoRoute(
          path: 'result',
          builder: (context, state) =>
              BattleResultScreen(result: (state.extra as BattleResultSummary?) ?? _demoBattleResult()),
        ),
      ],
    ),
    GoRoute(
      path: '/friends',
      builder: (context, state) => const PlaceholderScreen(title: '친구 목록'),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => PlaceholderScreen(
            title: '친구 상세',
            subtitle: state.pathParameters['id'],
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/dungeon',
      builder: (context, state) {
        final extra =
            state.extra
                as ({
                  DungeonConfig config,
                  DungeonProgressSnapshot progress,
                  int gameDayWeekday,
                  int remainingRuns,
                })?;
        return DungeonScreen(
          config: extra?.config ?? _demoDungeonConfig(),
          progress: extra?.progress ?? const DungeonProgressSnapshot(),
          gameDayWeekday: extra?.gameDayWeekday ?? 1,
          remainingRuns: extra?.remainingRuns ?? 6,
          onDifficultyTap: (dungeon, difficulty) {},
        );
      },
    ),
    GoRoute(
      path: '/exchange',
      builder: (context, state) {
        final extra =
            state.extra
                as ({
                  ExchangeConfig config,
                  Map<String, EquipmentDef> equipmentById,
                  Map<String, int> heldItems,
                  Map<String, int> formationTagLevels,
                  TagRegistry registry,
                })?;
        return ExchangeScreen(
          config: extra?.config ?? _demoExchangeConfig(),
          equipmentById: extra?.equipmentById ?? const {},
          heldItems: extra?.heldItems ?? const {},
          formationTagLevels: extra?.formationTagLevels ?? const {},
          registry: extra?.registry ?? TagRegistry(const []),
          onExchange: (entry) {},
          onUpgrade: (upgrade) {},
        );
      },
    ),
    GoRoute(
      path: '/deepforest',
      builder: (context, state) => const PlaceholderScreen(title: '깊은 숲'),
    ),
    GoRoute(
      path: '/summon',
      builder: (context, state) {
        final extra = state.extra as ({BannerCatalog catalog, Map<String, int> heldItems, int exchangePoint})?;
        return SummonScreen(
          catalog: extra?.catalog ?? _demoBannerCatalog(),
          heldItems: extra?.heldItems ?? const {},
          exchangePoint: extra?.exchangePoint ?? 0,
          onPull: (banner, count) {},
          onTrialTap: (characterId) => context.push('/summon/trial/$characterId'),
        );
      },
      routes: [
        GoRoute(
          path: 'trial/:id',
          builder: (context, state) => TrialScreen(
            characterId: state.pathParameters['id'] ?? '',
            onStartTrial: () {},
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/journal',
      builder: (context, state) => const PlaceholderScreen(title: '여행 수첩'),
    ),
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const PlaceholderScreen(title: '보관함'),
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const PlaceholderScreen(title: '상점'),
    ),
    GoRoute(
      path: '/mail',
      builder: (context, state) => const PlaceholderScreen(title: '우편'),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const PlaceholderScreen(title: '설정'),
    ),
  ],
);

/// `/battle`에 편성 없이(딥링크·직접 진입) 들어왔을 때의 자리 표시자.
/// 실제 진입 경로(편성 화면 -> 출격)는 T-31/T-32가 `extra`로 진짜
/// `BattleWorld`를 넘긴다.
BattleWorld _demoBattleWorld() {
  const dummyUnit = UnitDef(
    id: 'CHR_DEMO',
    base: UnitBaseStats(
      maxHp: 500,
      atk: 50,
      attackPeriod: 60,
      attackWindup: 12,
      attackRecover: 48,
      attackRange: 100,
      moveSpeed: 60,
    ),
  );
  return BattleWorld(
    config: const BattleConfig(
      stage: StageDef(
        id: 'STG_DEMO',
        index: 1,
        fieldLength: 2400,
        allyBaseX: 0,
        enemyBaseX: 2400,
        enemyBaseHp: 5000,
        timeLimitSec: 300,
      ),
      allyBaseHp: 10000,
      formation: [dummyUnit],
    ),
    rngSeed: 1,
    datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
    systems: canonicalBattleSystems(),
  )..phase = BattlePhase.running;
}

/// `/adventure`에 편성 없이(딥링크·직접 진입) 들어왔을 때의 자리 표시자.
/// 실제 진입 경로(캠프 -> 모험 지도)는 로딩된 실제 챕터 데이터를 `extra`로
/// 넘긴다.
List<StageDef> _demoChapterStages() => const [
  StageDef(
    id: 'STG_DEMO_1',
    index: 1,
    fieldLength: 2400,
    allyBaseX: 0,
    enemyBaseX: 2400,
    enemyBaseHp: 4500,
    timeLimitSec: 300,
  ),
];

/// `/dungeon`에 실제 데이터 없이(딥링크·직접 진입) 들어왔을 때의 자리
/// 표시자. 실제 진입 경로는 `assets/data/v1/dungeons.json`을 로딩해 넘긴다.
DungeonConfig _demoDungeonConfig() => const DungeonConfig(
  dailyRunLimit: 6,
  dungeons: [
    DungeonDef(
      id: 'DGN_DEMO',
      nameKey: 'dgn.demo',
      themeKey: 'demo',
      shardFamily: 'DEMO',
      difficulties: [DungeonDifficultyDef(level: 1, stageId: 'STG_DGN_DEMO_1')],
    ),
  ],
);

/// `/exchange`에 실제 데이터 없이(딥링크·직접 진입) 들어왔을 때의 자리
/// 표시자. 실제 진입 경로는 `assets/data/v1/exchange.json`/`equipments.json`을
/// 로딩해 넘긴다.
ExchangeConfig _demoExchangeConfig() => const ExchangeConfig(
  shops: [
    ShopDef(
      id: 'SHOP_DUNGEON_DEMO',
      nameKey: 'shop.dungeon.demo',
      entries: [
        ExchangeEntryDef(
          id: 'EX_DEMO',
          cost: [CostEntry(item: 'ITM_SHARD_DEMO_T3', amount: 10)],
          gain: GainDef(type: 'EQUIPMENT', id: 'EQP_DEMO'),
        ),
      ],
    ),
  ],
);

/// `/summon`에 실제 데이터 없이(딥링크·직접 진입) 들어왔을 때의 자리
/// 표시자. 실제 진입 경로는 `assets/data/v1/banners.json`을 로딩해 넘긴다.
BannerCatalog _demoBannerCatalog() => const BannerCatalog(
  banners: [
    BannerDef(
      id: 'BNR_DEMO',
      kind: 'STANDARD',
      nameKey: 'bnr.demo',
      cost: BannerCost(
        single: CostEntry(item: 'ITM_RECRUIT_TICKET', amount: 1),
        ten: CostEntry(item: 'ITM_RECRUIT_TICKET', amount: 10),
      ),
      rates: [RateEntry(rarity: 1, totalPct: 100000, pool: ['CHR_DEMO'])],
      duplicateConversion: DuplicateConversion(rarity3: 10, rarity2: 5, rarity1: 1, item: 'ITM_COLLECT_FRAGMENT'),
    ),
  ],
  exchange: GachaExchangeRule(pointPerPull: 1, requiredPoints: 200),
);

/// `/prologue`에 실제 저장소 없이(딥링크·직접 진입) 들어왔을 때의 자리
/// 표시자 — 아무 것도 기록하지 않는다. 정상 진입 경로(부트스트랩 -> 캠프
/// 최초 진입)는 실제 `JournalRepository`를 `extra`로 넘긴다.
class _NoopJournalStore implements JournalStore {
  @override
  Set<String> get unlockedSceneIds => const {};
  @override
  void markUnlocked(String sceneId) {}
}

BattleResultSummary _demoBattleResult() => const BattleResultSummary(
  outcome: null,
  frontlineCollapseTick: null,
  mainEnemy: null,
  formationUsed: [],
  hints: [],
  clearSec: 0,
  summons: 0,
  kills: 0,
);
