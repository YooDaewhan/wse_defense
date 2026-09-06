import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/data/dungeon/dungeon_data_loader.dart';

/// 09_MILESTONES.md T-41 완료조건: "3종 × 5난이도".
void main() {
  test('loads 3 dungeons of 5 difficulties each from the real bundled dungeons.json', () async {
    final config = await loadDungeonConfig((path) => File('assets/data/v1/$path').readAsString());

    expect(config.dailyRunLimit, 6);
    expect(config.dungeons.map((d) => d.id).toSet(), {'DGN_SUN', 'DGN_MOON', 'DGN_FIELD'});
    for (final dungeon in config.dungeons) {
      expect(dungeon.difficulties.map((d) => d.level), [1, 2, 3, 4, 5]);
    }
  });

  test('Sunday is not explicitly listed in any dungeon\'s bonusWeekdays (it is a universal bonus day, handled in code)', () async {
    final config = await loadDungeonConfig((path) => File('assets/data/v1/$path').readAsString());
    for (final dungeon in config.dungeons) {
      expect(dungeon.bonusWeekdays, isNot(contains(7)));
    }
  });
}
