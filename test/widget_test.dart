import 'package:flutter_test/flutter_test.dart';

import 'package:wse_defense/main.dart';

void main() {
  testWidgets('app boots to a blank screen', (WidgetTester tester) async {
    await tester.pumpWidget(const WseDefenseApp());
    expect(tester.takeException(), isNull);
  });
}
