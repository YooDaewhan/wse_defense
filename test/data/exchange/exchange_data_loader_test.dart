import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/data/exchange/exchange_data_loader.dart';

void main() {
  test('loads upgrades and shops from the bundled exchange.json', () async {
    final config = await loadExchangeConfig((path) => File('assets/data/v1/$path').readAsString());

    expect(config.upgrades.map((u) => u.id).toSet(), {
      'UPG_SUN_T1_T2', 'UPG_SUN_T2_T3',
      'UPG_MOON_T1_T2', 'UPG_MOON_T2_T3',
      'UPG_FIELD_T1_T2', 'UPG_FIELD_T2_T3',
    });

    expect(config.shops.map((s) => s.id).toSet(), {'SHOP_DUNGEON_SUN', 'SHOP_DUNGEON_MOON', 'SHOP_DUNGEON_FIELD'});

    final sunShop = config.shops.firstWhere((s) => s.id == 'SHOP_DUNGEON_SUN');
    final maskEntry = sunShop.entries.firstWhere((e) => e.gain.id == 'EQP_ANIMAL_MASK');
    expect(maskEntry.cost.single.item, 'ITM_SHARD_SUN_T3');
    expect(maskEntry.cost.single.amount, 10); // §6.1: T3 ×10
    expect(maskEntry.unlock?.dungeonId, 'DGN_SUN');
    expect(maskEntry.unlock?.level, 4);

    final upgrade = config.upgrades.firstWhere((u) => u.id == 'UPG_SUN_T1_T2');
    expect(upgrade.cost.single.amount, 5); // §4.1: T1×5→T2
    expect(upgrade.gain.amount, 1);
  });
}
