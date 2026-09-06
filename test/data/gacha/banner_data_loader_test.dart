import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/data/gacha/banner_data_loader.dart';

/// 04_DATA_SCHEMA.md §14: "banner rates 합계 == 100000".
void main() {
  test('loads banners.json and every banner\'s rates sum to 100000', () async {
    final catalog = await loadBannerCatalog((path) => File('assets/data/v1/$path').readAsString());

    expect(catalog.banners, isNotEmpty);
    for (final banner in catalog.banners) {
      final sum = banner.rates.fold<int>(0, (acc, r) => acc + r.totalPct);
      expect(sum, 100000, reason: '${banner.id}의 rates 합계');
    }

    expect(catalog.exchange.requiredPoints, 200);
    expect(catalog.exchange.carryOver, isTrue);

    final themeBanner = catalog.banners.firstWhere((b) => b.givesExchangePoint);
    expect(themeBanner.exchangeTargets, isNotEmpty);
  });
}
