import 'package:go_router/go_router.dart';

import '../application/app_scope.dart';
import '../battle/defs/datapack.dart';
import '../battle/defs/stage_def.dart';
import '../battle/tag/tag_registry.dart';
import '../battle/world/battle_world.dart';
import '../domain/dungeon/dungeon_def.dart';
import '../domain/dungeon/dungeon_progress.dart';
import '../domain/exchange/exchange_def.dart';
import '../domain/gacha/banner_def.dart';
import '../domain/story/story_beat.dart';
import '../domain/tutorial/tutorial_controller.dart';
import '../domain/tutorial/tutorial_stage.dart';
import '../domain/tutorial/tutorial_step.dart';
import '../game/battle_result.dart';
import '../presentation/screens/adventure/adventure_map_screen.dart';
import '../presentation/screens/adventure/stage_brief_screen.dart';
import '../presentation/screens/battle/battle_screen.dart';
import '../presentation/screens/camp/camp_screen.dart';
import '../presentation/screens/battle_result/battle_result_screen.dart';
import '../presentation/screens/dungeon/dungeon_screen.dart';
import '../presentation/screens/exchange/exchange_screen.dart';
import '../presentation/screens/formation/formation_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/summon/summon_screen.dart';
import '../presentation/screens/summon/trial_screen.dart';
import '../presentation/screens/story/story_player_screen.dart';
import '../presentation/widgets/placeholder_screen.dart';

/// 05_FRONTEND.md §2 라우트 표. 실제 화면이 아직 없는 곳은 전부
/// `PlaceholderScreen`(T-28 완료조건: "모든 라우트 진입 가능, 빈 화면 허용").
///
/// 10_WIRING_PLAN.md T-56: 딥링크·직접 진입(= `state.extra`가 없음) 시의
/// 폴백은 하드코딩된 더미 객체가 아니라 [AppScopeProvider]가 부팅 때 채운
/// 실제 로더 결과에서 온다. 완전히 아무것도 못 만드는 경우(전투 중간
/// 진입 등)만 최소 리터럴로 남긴다.
GoRouter buildAppRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/prologue',
      builder: (context, state) {
        final scope = AppScopeProvider.of(context);
        final extra = state.extra as ({List<StoryBeat> beats})?;
        return StoryPlayerScreen(
          sceneId: 'story.prologue',
          beats: extra?.beats ?? scope.prologueBeats ?? const [LineBeat(textKey: 'story.prologue.l1')],
          journalStore: scope.journal,
          onFinished: () => context.go('/camp'),
        );
      },
    ),
    GoRoute(
      path: '/tutorial',
      builder: (context, state) {
        final scope = AppScopeProvider.of(context);
        final datapack = scope.datapack;
        // 데이터팩 없이(딥링크·직접 진입) 들어오면 튜토리얼 캐릭터를 만들
        // 수 없다 -- 정상 경로는 항상 부팅 후 진입한다.
        if (datapack == null || datapack.characters.isEmpty) return const PlaceholderScreen(title: '튜토리얼');
        return BattleScreen(
          world: buildTutorialWorld(datapack),
          tutorialController: TutorialController(steps: tutorialSteps, store: scope.tutorial),
        );
      },
    ),
    GoRoute(
      path: '/camp',
      builder: (context, state) {
        final scope = AppScopeProvider.of(context);
        return CampScreen(
          account: scope.account,
          onAdventureTap: () => context.push('/adventure'),
          onFormationTap: () => context.push('/formation'),
          onSummonTap: () => context.push('/summon'),
          onDungeonTap: () => context.push('/dungeon'),
          onExchangeTap: () => context.push('/exchange'),
          onInventoryTap: () => context.push('/inventory'),
          onMailTap: () => context.push('/mail'),
          onJournalTap: () => context.push('/journal'),
          onSettingsTap: () => context.push('/settings'),
        );
      },
    ),
    GoRoute(
      path: '/adventure',
      builder: (context, state) {
        final scope = AppScopeProvider.of(context);
        final datapack = scope.datapack ?? const Datapack(characters: {}, enemies: {}, stages: {});
        final extra = state.extra as ({List<StageDef> stages, Set<String> cleared})?;
        final stages = extra?.stages ?? (datapack.stages.values.toList()..sort((a, b) => a.index.compareTo(b.index)));
        return AdventureMapScreen(
          chapterStages: stages,
          clearedStageIds: extra?.cleared ?? scope.account.clearedStageIds,
          onStageTap: (stage) => context.push('/adventure/${stage.id}/brief', extra: (stage: stage, datapack: datapack)),
        );
      },
      routes: [
        GoRoute(
          path: ':stageId/brief',
          builder: (context, state) {
            final scope = AppScopeProvider.of(context);
            final datapack = scope.datapack ?? const Datapack(characters: {}, enemies: {}, stages: {});
            final extra = state.extra as ({StageDef stage, Datapack datapack})?;
            final stageId = state.pathParameters['stageId'];
            final stage = extra?.stage ?? datapack.stages[stageId];
            if (stage == null) return const PlaceholderScreen(title: '스테이지를 찾을 수 없음');
            return StageBriefScreen(stage: stage, datapack: extra?.datapack ?? datapack);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/formation',
      builder: (context, state) {
        final scope = AppScopeProvider.of(context);
        final datapack = scope.datapack;
        final tagBundle = scope.tagBundle;
        if (datapack == null || tagBundle == null) return const PlaceholderScreen(title: '편성');
        return FormationScreen(datapack: datapack, tagBundle: tagBundle, repository: scope.formation);
      },
    ),
    GoRoute(
      path: '/battle',
      builder: (context, state) {
        final world = state.extra as BattleWorld?;
        // 전투는 항상 출격 브리핑(startBattle)에서 만들어진 실제 BattleWorld를
        // extra로 받는다 — 그게 없는 직접 진입은 보여줄 실제 전투가 없으므로
        // 가짜로 하나 지어내지 않는다(T-56에서 _demoBattleWorld 삭제).
        if (world == null) return const PlaceholderScreen(title: '전투');
        return BattleScreen(world: world);
      },
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
        final scope = AppScopeProvider.of(context);
        final extra =
            state.extra
                as ({
                  DungeonProgressSnapshot progress,
                  int gameDayWeekday,
                  int remainingRuns,
                })?;
        return DungeonScreen(
          config: scope.dungeonConfig ?? const DungeonConfig(dailyRunLimit: 6),
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
        final scope = AppScopeProvider.of(context);
        final extra = state.extra as ({Map<String, int> heldItems, Map<String, int> formationTagLevels})?;
        return ExchangeScreen(
          config: scope.exchangeConfig ?? const ExchangeConfig(),
          equipmentById: scope.equipmentById,
          heldItems: extra?.heldItems ?? const {},
          formationTagLevels: extra?.formationTagLevels ?? const {},
          registry: scope.tagBundle?.registry ?? TagRegistry(const []),
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
        final scope = AppScopeProvider.of(context);
        final extra = state.extra as ({Map<String, int> heldItems})?;
        return SummonScreen(
          catalog:
              scope.bannerCatalog ??
              const BannerCatalog(banners: [], exchange: GachaExchangeRule(pointPerPull: 1, requiredPoints: 200)),
          heldItems: extra?.heldItems ?? const {},
          exchangePoint: scope.account.exchangePoint,
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

/// `/battle/result`에 결과 없이(딥링크·직접 진입) 들어왔을 때의 자리
/// 표시자 — 빈 결과 요약(모든 값 0/null)을 그대로 보여준다.
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
