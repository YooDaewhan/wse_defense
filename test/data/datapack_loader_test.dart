import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/data/datapack/datapack_loader.dart';

Future<String> _readBundledAsset(String path) =>
    File('assets/data/v1/$path').readAsString();

void main() {
  test('loads the bundled datapack (5 characters, 5 enemies, 10 stages)', () async {
    final warnings = <String>[];
    final pack = await DatapackLoader(
      _readBundledAsset,
      onWarning: warnings.add,
    ).load();

    expect(warnings, isEmpty);
    expect(pack.characters.length, 5);
    expect(pack.enemies.length, 5);
    expect(pack.stages.length, 10);
    expect(pack.characterById('CHR_ACORN')?.base.maxHp, 1200);
    expect(pack.enemyById('ENM_FOREST_BEAR')?.isBoss, isTrue);
    expect(pack.stageById('STG_1_10')?.bossTriggers.single.enemyId, 'ENM_FOREST_BEAR');
  });

  test('unknown enemyId reference warns and is skipped, no crash', () async {
    final warnings = <String>[];
    Future<String> reader(String path) async {
      if (path == 'characters.json') return jsonEncode({'characters': []});
      if (path == 'enemies.json') return jsonEncode({'enemies': []});
      return jsonEncode({
        'stages': [
          {
            'id': 'STG_TEST',
            'index': 1,
            'fieldLength': 2400,
            'allyBaseX': 0,
            'enemyBaseX': 2400,
            'enemyBaseHp': 1000,
            'timeLimitSec': 300,
            'waves': [
              {
                'enemyId': 'ENM_DOES_NOT_EXIST',
                'startSec': 0,
                'intervalSec': 6,
                'stopSec': 180,
                'spawnX': 2350,
              },
            ],
          },
        ],
      });
    }

    final pack = await DatapackLoader(reader, onWarning: warnings.add).load();

    expect(warnings, isNotEmpty);
    expect(pack.stageById('STG_TEST')?.waves, isEmpty);
  });

  test('unknown JSON fields are ignored, not fatal', () async {
    final warnings = <String>[];
    Future<String> reader(String path) async {
      if (path == 'characters.json') {
        return jsonEncode({
          'characters': [
            {
              'id': 'CHR_TEST',
              'thisFieldDoesNotExistInTheSchema': 'ignored',
              'base': {
                'maxHp': 100,
                'atk': 10,
                'attackPeriod': 60,
                'attackWindup': 12,
                'attackRecover': 48,
                'attackRange': 100,
                'moveSpeed': 100,
                'somethingElseUnknown': 42,
              },
            },
          ],
        });
      }
      if (path == 'enemies.json') return jsonEncode({'enemies': []});
      return jsonEncode({'stages': []});
    }

    final pack = await DatapackLoader(reader, onWarning: warnings.add).load();

    expect(warnings, isEmpty);
    expect(pack.characterById('CHR_TEST')?.base.maxHp, 100);
  });
}
