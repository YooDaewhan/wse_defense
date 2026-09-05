import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/app/router.dart';
import 'package:wse_defense/main.dart';

/// 09_MILESTONES.md T-28 완료조건: "모든 라우트 진입 가능(빈 화면 허용)".
const _routes = [
  '/',
  '/prologue',
  '/tutorial',
  '/camp',
  '/adventure',
  '/adventure/STG_1_1/brief',
  '/formation',
  '/battle',
  '/battle/result',
  '/friends',
  '/friends/CHR_ACORN',
  '/dungeon',
  '/exchange',
  '/deepforest',
  '/summon',
  '/summon/trial/CHR_BEAR',
  '/journal',
  '/inventory',
  '/shop',
  '/mail',
  '/settings',
];

void main() {
  for (final route in _routes) {
    testWidgets('route $route is reachable without throwing', (tester) async {
      final router = buildAppRouter();
      await tester.pumpWidget(WseDefenseApp(router: router));
      await tester.pump();

      router.go(route);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.takeException(), isNull);
    });
  }
}
