import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/app/theme.dart';

void main() {
  test('the app theme uses the forest/campfire palette, not the Flutter default blue', () {
    final theme = buildAppTheme();
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, isNot(Colors.blue));
  });
}
