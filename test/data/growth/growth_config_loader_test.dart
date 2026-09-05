import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/data/growth/growth_config_loader.dart';

void main() {
  test('loads the real assets/data/v1/growth.json and matches its committed values', () async {
    final growth = await loadGrowthConfig(
      (path) => File('assets/data/v1/$path').readAsString(),
    );

    expect(growth.focusKeyframes.map((k) => k.level), [1, 10, 20]);
    expect(growth.focusKeyframes.first.regenPerSec, 18);
    expect(growth.focusGoldCost.base, 500);
    expect(growth.focusGoldCost.growth, 1.18);

    expect(growth.campKeyframes.map((k) => k.hp), [10000, 28000, 50000]);
    expect(growth.campGoldCost.base, 400);

    expect(growth.focusBoost.map((s) => s.stage), [0, 1, 2]);
    expect(growth.focusBoost[1].regenBonus, 7);

    expect(growth.bondMaxLevel, 120);
    expect(growth.bondGoldCost.base, 200);
  });
}
