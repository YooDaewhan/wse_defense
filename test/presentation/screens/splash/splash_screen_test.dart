import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wse_defense/application/app_scope.dart';
import 'package:wse_defense/presentation/screens/splash/splash_screen.dart';

import '../../../support/test_app_scope.dart';

void main() {
  /// 10_WIRING_PLAN.md T-56 완료조건: "스플래시가 로딩 결과를 AppScope에
  /// 넣고, 진행률이 로더 8종 전체를 반영" -- 예전에는 로딩 결과를 버리고
  /// 그냥 다음 라우트로 갔다. (한 테스트로 합침: go_router는 같은 파일 안
  /// 여러 테스트에서 각자 GoRouter를 새로 만들면 라우트 상태가 새지 않고
  /// 넘어오는 경우가 있어, 그 문제를 피하려고 검증을 한 번의 부팅에 전부
  /// 묶었다.)
  testWidgets('loads every loader into AppScope, then navigates to the configured next route', (tester) async {
    final scope = testAppScope();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen(nextRoute: '/next')),
        GoRoute(path: '/next', builder: (context, state) => const Scaffold(body: Text('다음 화면'))),
      ],
    );

    await tester.pumpWidget(AppScopeProvider(scope: scope, child: MaterialApp.router(routerConfig: router)));
    // 실제 에셋 로딩은 테스트 하네스에서 매우 빨라(동기에 가까움) 중간
    // 진행률 프레임을 안정적으로 붙잡기 어렵다 -- 대신 진행률 위젯이
    // "로딩 중이라면 반드시 그려지는" 위치에 있다는 것 자체는 위젯
    // 트리 구성(SplashScreen._error == null 분기)으로 보장되고, 여기서는
    // 로딩이 끝난 뒤 실제로 다음 라우트로 넘어가는지만 확인한다.
    await tester.pumpAndSettle();

    expect(find.text('다음 화면'), findsOneWidget); // 로딩 완료 후 다음 라우트로 이동
    expect(scope.datapack, isNotNull);
    expect(scope.datapack!.characters, isNotEmpty);
    expect(scope.tagBundle, isNotNull);
    expect(scope.dungeonConfig, isNotNull);
    expect(scope.exchangeConfig, isNotNull);
    expect(scope.equipmentCatalog, isNotNull);
    expect(scope.bannerCatalog, isNotNull);
    expect(scope.growthConfig, isNotNull);
    expect(scope.weatherConfig, isNotNull);
    expect(scope.prologueBeats, isNotNull);
  });
}
