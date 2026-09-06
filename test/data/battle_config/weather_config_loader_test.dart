import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/data/battle_config/weather_config_loader.dart';

/// 09_MILESTONES.md T-45: `weather.json`이 04_DATA_SCHEMA.md §10 그대로
/// 로딩되는지.
void main() {
  test('loads weather.json matching the documented example values', () async {
    final cfg = await loadWeatherConfig((path) => File('assets/data/v1/$path').readAsString());

    expect(cfg.gaugeMin, -100);
    expect(cfg.gaugeMax, 100);
    expect(cfg.toClear, 60);
    expect(cfg.toNight, -60);
    expect(cfg.clear.allyAtkPct, 15000);
    expect(cfg.night.hotPctPerSec, 250);
    expect(cfg.healCapPctPerSec, 2000);
  });
}
