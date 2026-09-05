import 'package:flutter_test/flutter_test.dart';

import 'package:wse_defense/app/router.dart';
import 'package:wse_defense/main.dart';

void main() {
  testWidgets('app boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(WseDefenseApp(router: buildAppRouter()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
