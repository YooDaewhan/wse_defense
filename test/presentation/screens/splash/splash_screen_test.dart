import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wse_defense/presentation/screens/splash/splash_screen.dart';
import 'package:wse_defense/presentation/widgets/placeholder_screen.dart';

void main() {
  testWidgets('loads the datapack then navigates to the configured next route', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen(nextRoute: '/next')),
        GoRoute(path: '/next', builder: (context, state) => const PlaceholderScreen(title: '다음 화면')),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    // 실제 에셋 로딩은 테스트 하네스에서 매우 빨라(동기에 가까움) 중간
    // 진행률 프레임을 안정적으로 붙잡기 어렵다 -- 대신 진행률 위젯이
    // "로딩 중이라면 반드시 그려지는" 위치에 있다는 것 자체는 위젯
    // 트리 구성(SplashScreen._error == null 분기)으로 보장되고, 여기서는
    // 로딩이 끝난 뒤 실제로 다음 라우트로 넘어가는지만 확인한다.
    await tester.pumpAndSettle();

    expect(find.text('다음 화면'), findsOneWidget); // 로딩 완료 후 다음 라우트로 이동
  });
}
