import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/app/router.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/main.dart';

import '../support/test_app_scope.dart';

const _stage = StageDef(
  id: 'STG_1_1',
  index: 1,
  fieldLength: 2400,
  allyBaseX: 0,
  enemyBaseX: 2400,
  enemyBaseHp: 1000,
  timeLimitSec: 300,
);

/// 10_WIRING_PLAN.md T-60: "출격 브리핑에서 startBattle 호출". Firebase가
/// 이 테스트 환경에서 초기화돼 있지 않아 실제 호출은 항상 실패하지만,
/// 그 실패가 화면을 깨지 않고 사용자에게 보이는 오류로 정리되는지(T-59의
/// ApiException 정리)는 확인할 수 있다.
void main() {
  testWidgets('tapping deploy attempts startBattle and surfaces a readable error instead of crashing', (tester) async {
    final scope = testAppScope()..datapack = const Datapack(characters: {}, enemies: {}, stages: {'STG_1_1': _stage});
    final router = buildAppRouter();

    await tester.pumpWidget(WseDefenseApp(router: router, appScope: scope));
    await tester.pump();
    // 실제 사용자 동선 그대로: /adventure에서 스테이지 노드를 눌러야
    // AdventureMapScreen이 스스로 알맞은 모양의 extra로 push한다 --
    // router.go로 브리핑 경로에 직접 뛰어들면 (go_router가 조상 라우트도
    // 같이 다시 지어) /adventure 빌더가 이 extra를 잘못된 모양으로 받아
    // 캐스팅 에러가 난다.
    router.go('/adventure');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('stage_node_STG_1_1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('deploy_button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('deploy_button')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
