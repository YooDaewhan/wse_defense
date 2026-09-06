import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/app/router.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/domain/dungeon/dungeon_def.dart';
import 'package:wse_defense/domain/dungeon/dungeon_progress.dart';
import 'package:wse_defense/main.dart';

import '../support/test_app_scope.dart';

const _stage = StageDef(
  id: 'STG_DGN_SUN_1',
  index: 1,
  fieldLength: 2400,
  allyBaseX: 0,
  enemyBaseX: 2400,
  enemyBaseHp: 1000,
  timeLimitSec: 300,
);

const _dungeonConfig = DungeonConfig(
  dailyRunLimit: 6,
  dungeons: [
    DungeonDef(
      id: 'DGN_SUN',
      nameKey: 'dgn.sun',
      themeKey: 'sun',
      shardFamily: 'SUN',
      difficulties: [DungeonDifficultyDef(level: 1, stageId: 'STG_DGN_SUN_1')],
    ),
  ],
);

/// 10_WIRING_PLAN.md T-62: 난이도 탭이 실제 `startBattle(mode: DUNGEON)`을
/// 부르는지 확인한다. Firebase가 이 테스트 환경에 없어 호출은 항상
/// 실패하지만(T-59 ApiException 정리 덕에 크래시 없이 스낵바로 보임),
/// 그것으로 빈 콜백(`() {}`)이 아니라 실제 배선을 타는지는 확인할 수 있다.
void main() {
  testWidgets('tapping an unlocked difficulty attempts startBattle and surfaces a readable error instead of crashing', (
    tester,
  ) async {
    final scope = testAppScope()
      ..dungeonConfig = _dungeonConfig
      ..datapack = const Datapack(characters: {}, enemies: {}, stages: {'STG_DGN_SUN_1': _stage});
    final router = buildAppRouter();

    await tester.pumpWidget(WseDefenseApp(router: router, appScope: scope));
    await tester.pump();
    // 스플래시가 initState에서 진짜 에셋을 비동기로 로딩하면서 여기서 준
    // dungeonConfig/datapack을 실제 데이터로 덮어쓸 수 있다(경합) -- 어느
    // 쪽이 이기든 레벨 1이 잠기지 않도록 실제 dungeons.json의 해금 조건
    // (STG_1_3 클리어)도 같이 만족시켜 둔다.
    router.go(
      '/dungeon',
      extra: (
        progress: const DungeonProgressSnapshot(clearedStageIds: {'STG_1_3'}),
        gameDayWeekday: 1,
        remainingRuns: 6,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('dungeon_difficulty_DGN_SUN_1')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('dungeon_difficulty_DGN_SUN_1')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
