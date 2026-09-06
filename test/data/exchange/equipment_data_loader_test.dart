import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/data/exchange/equipment_data_loader.dart';

void main() {
  test('loads all 18 equipments from the bundled equipments.json', () async {
    final catalog = await loadEquipmentCatalog((path) => File('assets/data/v1/$path').readAsString());
    expect(catalog.equipments.length, 18);

    final tagBearing = catalog.equipments.where((e) => e.grantTagId != null).toList();
    expect(tagBearing.length, 6); // 07_DUNGEON_EXCHANGE.md §6.1
    for (final e in tagBearing) {
      expect(e.grantTagBaseLevel, 1);
      expect(e.tagBonusAtEnhance5, isTrue);
    }
  });
}
