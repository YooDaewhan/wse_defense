import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../application/app_scope.dart';
import '../battle/constants.dart';
import '../battle/defs/datapack.dart';
import '../battle/defs/stage_def.dart';
import '../battle/tag/tag_registry.dart';
import '../battle/world/battle_input.dart';
import '../battle/world/battle_world.dart';
import '../battle/world/input_log.dart';
import '../data/remote/api.dart';
import '../data/remote/battle_submit_adapter.dart';
import '../data/remote/battle_submit_queue.dart';
import '../data/remote/equipment_source.dart';
import '../data/remote/mail_source.dart';
import '../domain/account/account_state.dart';
import '../domain/battle/battle_submission.dart';
import '../domain/battle/battle_world_builder.dart';
import '../domain/dungeon/dungeon_bonus.dart';
import '../domain/dungeon/dungeon_def.dart';
import '../domain/dungeon/dungeon_progress.dart';
import '../domain/exchange/equipment_instance.dart';
import '../domain/exchange/exchange_def.dart';
import '../domain/gacha/banner_def.dart';
import '../domain/mail/mail_item.dart';
import '../domain/story/story_beat.dart';
import '../domain/tutorial/tutorial_controller.dart';
import '../domain/tutorial/tutorial_stage.dart';
import '../domain/tutorial/tutorial_step.dart';
import '../game/battle_result.dart';
import '../presentation/screens/adventure/adventure_map_screen.dart';
import '../presentation/screens/adventure/stage_brief_screen.dart';
import '../presentation/screens/battle/battle_screen.dart';
import '../presentation/screens/camp/camp_screen.dart';
import '../presentation/screens/character_detail/character_detail_screen.dart';
import '../presentation/screens/character_detail/character_list_screen.dart';
import '../presentation/screens/battle_result/battle_result_screen.dart';
import '../presentation/screens/dungeon/dungeon_screen.dart';
import '../presentation/screens/exchange/exchange_screen.dart';
import '../presentation/screens/formation/formation_screen.dart';
import '../presentation/screens/inventory/inventory_screen.dart';
import '../presentation/screens/journal/journal_screen.dart';
import '../presentation/screens/mail/mail_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/summon/summon_screen.dart';
import '../presentation/screens/summon/trial_screen.dart';
import '../presentation/screens/story/story_player_screen.dart';

/// 딥링크·직접 진입 시 필요한 데이터가 없거나(스테이지를 못 찾음 등),
/// 아직 실제 기능이 없는 화면(상점의 IAP 연동, 깊은 숲의 데이터 로더 --
/// 둘 다 이 화면 하나만의 배선이 아니라 새 인프라가 필요해 T-63 범위
/// 밖) 자리에 쓰는 최소 안내 화면. T-28 당시의 범용
/// `PlaceholderScreen`(모든 라우트에 똑같이 붙던 "준비 중")은 이제 각
/// 라우트가 실제 화면을 갖게 되어 삭제했다 -- 여기 남은 건 그 라우트
/// 고유의 실패/미구현 사유를 짧게 설명하는 자리다.
Widget _messageScreen(String title, [String? message]) => Scaffold(
  appBar: AppBar(title: Text(title)),
  body: Center(child: Text(message ?? '준비 중입니다')),
);

/// 05_FRONTEND.md §2 라우트 표.
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
        if (datapack == null || datapack.characters.isEmpty) return _messageScreen('튜토리얼');
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
            if (stage == null) return _messageScreen('스테이지를 찾을 수 없음');
            final resolvedDatapack = extra?.datapack ?? datapack;
            return StageBriefScreen(
              stage: stage,
              datapack: resolvedDatapack,
              onDeployTap: () => _deployToStage(context, scope, stage, resolvedDatapack),
            );
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
        if (datapack == null || tagBundle == null) return _messageScreen('편성');
        return FormationScreen(
          datapack: datapack,
          tagBundle: tagBundle,
          repository: scope.formation,
          onSyncFormation: (presetIndex, slots) => _syncFormationToServer(presetIndex, slots),
        );
      },
    ),
    GoRoute(
      path: '/battle',
      builder: (context, state) {
        final scope = AppScopeProvider.of(context);
        final extra = state.extra as ({BattleWorld world, String battleId, int seed, String formationHash})?;
        // 전투는 항상 출격 브리핑(startBattle)에서 만들어진 실제 BattleWorld를
        // extra로 받는다 — 그게 없는 직접 진입은 보여줄 실제 전투가 없으므로
        // 가짜로 하나 지어내지 않는다(T-56에서 _demoBattleWorld 삭제).
        if (extra == null) return _messageScreen('전투');
        return BattleScreen(
          world: extra.world,
          onBattleEnd: (recordedInputs, maxFrontlineX) => _submitBattleAndShowResult(
            context,
            scope,
            world: extra.world,
            recordedInputs: recordedInputs,
            maxFrontlineX: maxFrontlineX,
            battleId: extra.battleId,
            seed: extra.seed,
            formationHash: extra.formationHash,
          ),
        );
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
      // 05_FRONTEND.md §2: "/friends"의 "친구"는 실제 소셜 기능이 아니라
      // 보유 캐릭터(동료) 그리드다(백엔드에 친구 기능 자체가 없음).
      builder: (context, state) {
        final scope = AppScopeProvider.of(context);
        return CharacterListScreen(
          ownedCharacterIds: scope.account.ownedCharacterIds,
          datapack: scope.datapack ?? const Datapack(characters: {}, enemies: {}, stages: {}),
          onCharacterTap: (characterId) => context.push('/friends/$characterId'),
        );
      },
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final scope = AppScopeProvider.of(context);
            final characterId = state.pathParameters['id'] ?? '';
            final character = (scope.datapack ?? const Datapack(characters: {}, enemies: {}, stages: {})).characterById(characterId);
            final uid = _currentUid();
            if (character == null || uid == null) return _messageScreen('캐릭터를 찾을 수 없음');
            return StreamBuilder<List<EquipmentInstance>>(
              stream: watchEquipments(uid),
              builder: (context, snapshot) {
                final instances = snapshot.data ?? const [];
                EquipmentInstance? equipped;
                for (final i in instances) {
                  if (i.equippedTo == characterId) equipped = i;
                }
                return CharacterDetailScreen(
                  character: character,
                  equipmentById: scope.equipmentById,
                  equippedInstance: equipped,
                  unequippedInstances: [for (final i in instances) if (i.equippedTo == null) i],
                  onEquipTap: (instanceId) => _equipItem(context, scope, characterId, instanceId),
                );
              },
            );
          },
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
        // 10_WIRING_PLAN.md T-62: 요일 보너스는 로컬 시계가 아니라 서버
        // 시각 기준이어야 한다(dungeon_bonus.dart 주석) -- extra로 이미
        // 받은 값이 있으면(딥링크 등) 그걸 우선한다.
        //
        // 남은 입장 횟수(remainingRuns)/해금 진행도(progress)는 서버의
        // dailyCounters·progress 문서를 읽어올 Callable이 아직 없어(계정
        // 상태를 서버에서 불러오는 통로 자체가 없음 -- bootstrapAccount도
        // 어디서도 호출되지 않는다) 여전히 폴백에 머문다. 별도 후속 작업
        // 필요.
        return FutureBuilder<DateTime>(
          future: extra?.gameDayWeekday == null ? getServerTime() : null,
          builder: (context, snapshot) {
            final gameDayWeekday =
                extra?.gameDayWeekday ?? (snapshot.data == null ? 1 : gameDayWeekdayOf(snapshot.data!, dailyResetHourUtc));
            return DungeonScreen(
              config: scope.dungeonConfig ?? const DungeonConfig(dailyRunLimit: 6),
              progress: extra?.progress ?? const DungeonProgressSnapshot(),
              gameDayWeekday: gameDayWeekday,
              remainingRuns: extra?.remainingRuns ?? 6,
              onDifficultyTap: (dungeon, difficulty) => _startDungeonBattle(context, scope, difficulty),
            );
          },
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
          onExchange: (entry) => _exchangeItem(context, scope, entry.id),
          onUpgrade: (upgrade) => _exchangeItem(context, scope, upgrade.id),
        );
      },
    ),
    GoRoute(
      path: '/deepforest',
      // 깊은 숲: 층 진행 데이터 로더 자체가 아직 없다(assets/data/v1에
      // 관련 파일 없음) -- 화면 하나만의 배선이 아니라 새 데이터
      // 로더(다른 8종처럼 그 자체가 하나의 티켓 분량)가 선행돼야 한다.
      builder: (context, state) => _messageScreen('깊은 숲', '데이터 로더 미구현 -- 준비 중입니다'),
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
          onPull: (banner, count) => _pullGacha(context, scope, banner, count),
          onTrialTap: (characterId) => context.push('/summon/trial/$characterId'),
          onExchangePickup: (banner, characterId) => _exchangePickup(context, scope, banner.id, characterId),
        );
      },
      routes: [
        GoRoute(
          path: 'trial/:id',
          builder: (context, state) {
            final scope = AppScopeProvider.of(context);
            final characterId = state.pathParameters['id'] ?? '';
            return TrialScreen(
              characterId: characterId,
              onStartTrial: () => _startTrial(context, scope, characterId),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/journal',
      builder: (context, state) {
        final scope = AppScopeProvider.of(context);
        return JournalScreen(
          unlockedSceneIds: scope.journal.unlockedSceneIds,
          // 지금은 실제 장면이 프롤로그 하나뿐이라(파일 주석 참고) 그대로 연결한다.
          onReplayTap: (sceneId) => context.push('/prologue', extra: (beats: scope.prologueBeats ?? const [])),
        );
      },
    ),
    GoRoute(
      path: '/inventory',
      builder: (context, state) {
        final scope = AppScopeProvider.of(context);
        final uid = _currentUid();
        if (uid == null) return _messageScreen('보관함');
        return StreamBuilder<List<EquipmentInstance>>(
          stream: watchEquipments(uid),
          builder: (context, snapshot) => InventoryScreen(
            instances: snapshot.data ?? const [],
            equipmentById: scope.equipmentById,
            onEnhanceTap: (instanceId) => _enhanceEquipment(context, scope, instanceId),
          ),
        );
      },
    ),
    GoRoute(
      path: '/shop',
      // 상점: 실제 상품 카탈로그(functions/src/purchase/productData.ts)와
      // 인앱결제 플러그인 연동이 필요하다 -- 화면 배선만으로 끝나지
      // 않아(실제 스토어 없이는 검증도 못 함) 이번 범위 밖.
      builder: (context, state) => _messageScreen('상점', '인앱결제 연동 미구현 -- 준비 중입니다'),
    ),
    GoRoute(
      path: '/mail',
      builder: (context, state) {
        final scope = AppScopeProvider.of(context);
        final uid = _currentUid();
        if (uid == null) return _messageScreen('우편');
        return StreamBuilder<List<MailItem>>(
          stream: watchMail(uid),
          builder: (context, snapshot) => MailScreen(
            mail: snapshot.data ?? const [],
            now: DateTime.now(),
            onClaimTap: (mailId) => _claimMail(context, scope, mailId),
          ),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsScreen(store: AppScopeProvider.of(context).settings),
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

/// `FirebaseAuth.instance` 자체가 Firebase 미초기화 상태(flutter test
/// VM)에서 동기적으로 던진다 -- 화면 라우트가 그 예외로 죽지 않도록
/// 감싼다.
String? _currentUid() {
  try {
    return FirebaseAuth.instance.currentUser?.uid;
  } catch (_) {
    return null;
  }
}

/// 매 호출마다 새 멱등키를 붙인 [RequestMeta] -- 여러 콜백이 반복
/// 타이핑하지 않도록 한 곳에 모은다. `appVersion`은 T-59와 같은 이유로
/// 아직 고정값이다(api.dart의 kDataVersion 주석 참고).
RequestMeta _newMeta() =>
    RequestMeta(idempotencyKey: newIdempotencyKey(), appVersion: '1.0.0', dataVersion: kDataVersion);

/// `ApiException`을 사용자가 읽을 수 있는 스낵바로 정리한다 -- [action]은
/// "출격"/"소환"처럼 실패한 동작 이름.
void _showApiError(BuildContext context, String action, ApiException e) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$action 실패 (${e.code.name})')));
}

/// "편성 서버 동기화": `startBattle`이 실제로 읽는 건 로컬 Hive가 아니라
/// 이 서버 문서다(functions/src/battle/saveFormation.ts). 실패해도(오프라인
/// 등) 로컬 편집은 이미 끝난 뒤라 사용자를 막지 않는다 -- 그 시점에
/// 출격을 시도하면 `_startBattleFlow`의 오류 처리가 대신 알려준다.
Future<void> _syncFormationToServer(int presetIndex, List<String?> slots) async {
  try {
    await saveFormation(
      _newMeta(),
      presetIndex: presetIndex,
      slots: [for (final characterId in slots) {'characterId': characterId, 'equipmentInstanceId': null}],
    );
  } catch (_) {
    // 조용히 넘어간다 -- 다음 편집이나 출격 시도가 다시 동기화를 시킨다.
  }
}

/// 10_WIRING_PLAN.md T-60 "출격" / T-61 "체험전": `startBattle`을 부르고,
/// 서버가 확정한 시드·편성으로 실제 `BattleWorld`를 만들어 `/battle`로
/// 넘어간다. STORY(본편 출격)와 TRIAL(체험전)이 [mode]만 다르고 나머지
/// 배선은 동일해 하나로 합쳤다 -- TRIAL의 단일 슬롯 편성도
/// [buildBattleWorldFromStart]가 그대로 처리한다.
Future<void> _startBattleFlow(
  BuildContext context,
  AppScope scope, {
  required String mode,
  required StageDef stage,
  required Datapack datapack,
  int presetIndex = 0,
  String? trialCharacterId,
}) async {
  try {
    final res = await startBattle(
      _newMeta(),
      mode: mode,
      stageId: stage.id,
      presetIndex: presetIndex,
      trialCharacterId: trialCharacterId,
    );
    final snapshot = Map<String, dynamic>.from(res['formationSnapshot'] as Map);
    final formationSlots = [
      for (final s in snapshot['slots'] as List) Map<String, dynamic>.from(s as Map),
    ];
    final world = buildBattleWorldFromStart(
      stage: stage,
      datapack: datapack,
      seed: res['seed'] as int,
      formationSlots: formationSlots,
      tagBundle: scope.tagBundle,
      growthConfig: scope.growthConfig,
      weatherConfig: scope.weatherConfig,
      account: scope.account,
    );
    if (!context.mounted) return;
    context.push(
      '/battle',
      extra: (
        world: world,
        battleId: res['battleId'] as String,
        seed: res['seed'] as int,
        formationHash: snapshot['formationHash'] as String,
      ),
    );
  } on ApiException catch (e) {
    if (!context.mounted) return;
    _showApiError(context, mode == 'TRIAL' ? '체험전' : '출격', e);
  }
}

Future<void> _deployToStage(BuildContext context, AppScope scope, StageDef stage, Datapack datapack) =>
    _startBattleFlow(context, scope, mode: 'STORY', stage: stage, datapack: datapack);

/// 09_MILESTONES.md T-51 체험전: `datapack`의 스테이지 중 인덱스가 가장
/// 낮은 하나를 그대로 빌려 쓴다(TRIAL은 stageId를 시간 제한/만료 계산에만
/// 쓰고 소유 검증은 건너뛰므로 어떤 스테이지든 무방하다 -- startBattle.ts
/// trialFormationSnapshot 참고).
Future<void> _startTrial(BuildContext context, AppScope scope, String characterId) async {
  final datapack = scope.datapack;
  final stages = datapack?.stages.values.toList() ?? const [];
  if (datapack == null || stages.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('체험전 실패 (스테이지 데이터 없음)')));
    return;
  }
  stages.sort((a, b) => a.index.compareTo(b.index));
  await _startBattleFlow(
    context,
    scope,
    mode: 'TRIAL',
    stage: stages.first,
    datapack: datapack,
    trialCharacterId: characterId,
  );
}

/// 10_WIRING_PLAN.md T-62 요일던전: 난이도를 탭하면 그 `stageId`로
/// `startBattle(mode: 'DUNGEON')`을 부른다. 던전 스테이지(STG_DGN_*)는
/// 아직 클라이언트 datapack에 StageDef가 없어(에셋 콘텐츠 자체가 없음)
/// 전투를 실제로 지을 수 없는 경우가 있다 -- 그때는 크래시 대신 안내만
/// 한다(_startTrial의 스테이지 없음 처리와 동일한 이유).
Future<void> _startDungeonBattle(BuildContext context, AppScope scope, DungeonDifficultyDef difficulty) async {
  final datapack = scope.datapack;
  final stage = datapack?.stages[difficulty.stageId];
  if (datapack == null || stage == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('던전 실패 (스테이지 데이터 없음)')));
    return;
  }
  await _startBattleFlow(context, scope, mode: 'DUNGEON', stage: stage, datapack: datapack);
}

/// 10_WIRING_PLAN.md T-61 소환: 10연 등 `gachaPull` 후 신규 캐릭터를
/// 보유 목록에 더하고 교환 포인트를 갱신한다.
Future<void> _pullGacha(BuildContext context, AppScope scope, BannerDef banner, int count) async {
  try {
    final res = await gachaPull(_newMeta(), bannerId: banner.id, count: count);
    final results = (res['results'] as List).map((e) => Map<String, dynamic>.from(e as Map));
    final newIds = [for (final r in results) if (r['isNew'] == true) r['characterId'] as String];
    scope.setAccount(
      scope.account
          .applyPatch({
            'currency': {'exchangePoint': res['exchangePointAfter']},
          })
          .withOwnedCharacters(newIds),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('소환 완료 (신규 ${newIds.length}개)')));
  } on ApiException catch (e) {
    if (!context.mounted) return;
    _showApiError(context, '소환', e);
  }
}

/// 10_WIRING_PLAN.md T-61 교환 포인트 선택 교환: `exchangePickup`으로
/// 지정 캐릭터를 획득하고 포인트를 갱신한다.
Future<void> _exchangePickup(BuildContext context, AppScope scope, String bannerId, String characterId) async {
  try {
    final res = await exchangePickup(_newMeta(), bannerId: bannerId, characterId: characterId);
    scope.setAccount(
      scope.account
          .applyPatch({
            'currency': {'exchangePoint': res['exchangePointAfter']},
          })
          .withOwnedCharacters([characterId]),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$characterId 획득')));
  } on ApiException catch (e) {
    if (!context.mounted) return;
    _showApiError(context, '교환', e);
  }
}

/// 10_WIRING_PLAN.md T-63 캐릭터 상세(사실상 T-61에서 남겨둔 equipItem
/// 배선): [equipmentInstanceId]가 null이면 해제.
Future<void> _equipItem(BuildContext context, AppScope scope, String characterId, String? equipmentInstanceId) async {
  try {
    final res = await equipItem(_newMeta(), characterId: characterId, equipmentInstanceId: equipmentInstanceId);
    scope.setAccount(scope.account.applyPatch(res['patch'] as Map<String, dynamic>?));
  } on ApiException catch (e) {
    if (!context.mounted) return;
    _showApiError(context, '장착', e);
  }
}

/// 10_WIRING_PLAN.md T-63 보관함(사실상 T-61에서 남겨둔 enhanceEquipment
/// 배선): 목록은 Firestore 실시간 구독(watchEquipments)이라 강화 성공
/// 후 서버가 enhanceLevel을 올리면 자동으로 반영된다.
Future<void> _enhanceEquipment(BuildContext context, AppScope scope, String instanceId) async {
  try {
    final res = await enhanceEquipment(_newMeta(), equipmentInstanceId: instanceId);
    scope.setAccount(scope.account.applyPatch(res['patch'] as Map<String, dynamic>?));
  } on ApiException catch (e) {
    if (!context.mounted) return;
    _showApiError(context, '강화', e);
  }
}

/// 10_WIRING_PLAN.md T-63 우편: `claimMail`을 부르고 성공하면 보상을
/// 반영한다. 목록 자체는 서버 응답이 아니라 Firestore 실시간 구독
/// (watchMail)이라 claimedAt이 바뀌면 자동으로 버튼이 비활성화된다 --
/// 여기서 화면을 새로고침할 필요가 없다.
Future<void> _claimMail(BuildContext context, AppScope scope, String mailId) async {
  try {
    final res = await claimMail(_newMeta(), mailId: mailId);
    scope.setAccount(scope.account.applyPatch(res['patch'] as Map<String, dynamic>?));
  } on ApiException catch (e) {
    if (!context.mounted) return;
    _showApiError(context, '우편 수령', e);
  }
}

/// 10_WIRING_PLAN.md T-61 교환소: `/exchange`의 교환(onExchange)과 승급
/// 재료 교환(onUpgrade) 둘 다 서버 `exchangeItems`를 같은 방식으로 부른다
/// -- 둘 다 entryId 하나와 그 결과 patch만 다룬다.
Future<void> _exchangeItem(BuildContext context, AppScope scope, String entryId) async {
  try {
    final res = await exchangeItems(_newMeta(), entryId: entryId);
    scope.setAccount(scope.account.applyPatch(res['patch'] as Map<String, dynamic>?));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('교환 완료')));
  } on ApiException catch (e) {
    if (!context.mounted) return;
    _showApiError(context, '교환', e);
  }
}

/// 10_WIRING_PLAN.md T-60: 전투가 끝나면(BattleScreen.onBattleEnd) 입력
/// 로그를 조립해 `submitBattle`로 보낸다. 네트워크 실패는
/// `BattleSubmitQueue`가 `PendingSubmitsRepository`에 적재해 두고,
/// 나중에(앱 복귀 시 `retryPending`) 같은 멱등키로 다시 시도한다 — 그래서
/// 같은 전투를 두 번 제출해도 서버 멱등성 덕에 보상이 중복 지급되지
/// 않는다.
Future<void> _submitBattleAndShowResult(
  BuildContext context,
  AppScope scope, {
  required BattleWorld world,
  required List<BattleInput> recordedInputs,
  required int maxFrontlineX,
  required String battleId,
  required int seed,
  required String formationHash,
}) async {
  final outcome = world.outcome!;
  final summary = buildBattleSummary(world: world, recordedInputs: recordedInputs, maxFrontlineX: maxFrontlineX);
  final inputLog = InputLog(
    seed: seed,
    dataVersion: kDataVersion,
    stageId: world.config.stage.id,
    inputs: recordedInputs,
    formationHash: formationHash,
  );
  final inputLogBase64 = base64Encode(inputLog.encode());
  final checksum = computeBattleChecksum(inputLogBase64: inputLogBase64, seed: seed, formationHash: formationHash);

  final payload = <String, dynamic>{
    ..._newMeta().toJson(),
    'battleId': battleId,
    'outcome': battleOutcomeCode(outcome),
    'summary': {...summary, 'checksum': checksum},
    'inputLog': inputLogBase64,
    'formationHash': formationHash,
  };

  final queue = BattleSubmitQueue(store: scope.pendingSubmits, submit: submitBattlePayloadFn(scope));
  await queue.submitOrQueue(payload);

  if (!context.mounted) return;
  context.go(
    '/battle/result',
    extra: BattleResultSummary(
      outcome: outcome,
      frontlineCollapseTick: null,
      mainEnemy: null,
      formationUsed: const [],
      hints: const [],
      clearSec: (summary['endTick'] as int) / ticksPerSec,
      summons: summary['totalSummons'] as int,
      kills: summary['enemiesKilled'] as int,
    ),
  );
}
