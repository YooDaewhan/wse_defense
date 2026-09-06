import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/account/account_state.dart';

import '../support/test_app_scope.dart';

Future<String> _readAsset(String path) => File('assets/data/v1/$path').readAsString();

/// 10_WIRING_PLAN.md T-56.
void main() {
  test('loadStaticData reports progress reaching exactly 1.0 and fills every field', () async {
    final scope = testAppScope();
    final progressValues = <double>[];

    await scope.loadStaticData(_readAsset, onProgress: progressValues.add);

    expect(progressValues.last, 1.0);
    expect(progressValues, orderedEquals(progressValues.toList()..sort())); // 단조 증가
    expect(scope.datapack!.characters, isNotEmpty);
    expect(scope.tagBundle!.registry, isNotNull);
    expect(scope.dungeonConfig!.dungeons, isNotEmpty);
    expect(scope.exchangeConfig!.shops, isNotEmpty);
    expect(scope.equipmentCatalog!.equipments, isNotEmpty);
    expect(scope.bannerCatalog!.banners, isNotEmpty);
    expect(scope.growthConfig, isNotNull);
    expect(scope.weatherConfig, isNotNull);
    expect(scope.prologueBeats, isNotEmpty);
  });

  test('equipmentById indexes the loaded equipment catalog by id', () async {
    final scope = testAppScope();
    await scope.loadStaticData(_readAsset);

    final anEquipmentId = scope.equipmentCatalog!.equipments.first.id;
    expect(scope.equipmentById[anEquipmentId]?.id, anEquipmentId);
  });

  test('setAccount replaces the account and notifies listeners', () {
    final scope = testAppScope();
    var notified = false;
    scope.addListener(() => notified = true);

    scope.setAccount(const AccountState(gold: 500, ownedCharacterIds: {'CHR_ACORN'}));

    expect(scope.account.gold, 500);
    expect(notified, isTrue);
  });
}
