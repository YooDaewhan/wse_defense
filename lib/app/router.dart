import 'package:go_router/go_router.dart';

import '../battle/defs/datapack.dart';
import '../battle/defs/stage_def.dart';
import '../battle/defs/unit_def.dart';
import '../battle/world/battle_config.dart';
import '../battle/world/battle_world.dart';
import '../battle/world/canonical_systems.dart';
import '../game/battle_result.dart';
import '../presentation/screens/battle/battle_screen.dart';
import '../presentation/screens/battle_result/battle_result_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/widgets/placeholder_screen.dart';

/// 05_FRONTEND.md §2 라우트 표. 실제 화면이 아직 없는 곳은 전부
/// `PlaceholderScreen`(T-28 완료조건: "모든 라우트 진입 가능, 빈 화면 허용").
GoRouter buildAppRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/prologue',
      builder: (context, state) => const PlaceholderScreen(title: '프롤로그'),
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
      builder: (context, state) => const PlaceholderScreen(title: '모험 지도'),
      routes: [
        GoRoute(
          path: ':stageId/brief',
          builder: (context, state) => PlaceholderScreen(
            title: '출격 브리핑',
            subtitle: '스테이지: ${state.pathParameters['stageId']}',
          ),
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
      builder: (context, state) => const PlaceholderScreen(title: '요일던전'),
    ),
    GoRoute(
      path: '/exchange',
      builder: (context, state) => const PlaceholderScreen(title: '교환소'),
    ),
    GoRoute(
      path: '/deepforest',
      builder: (context, state) => const PlaceholderScreen(title: '깊은 숲'),
    ),
    GoRoute(
      path: '/summon',
      builder: (context, state) => const PlaceholderScreen(title: '소환'),
      routes: [
        GoRoute(
          path: 'trial/:id',
          builder: (context, state) => PlaceholderScreen(
            title: '체험전',
            subtitle: state.pathParameters['id'],
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
