import '../world/weather_state.dart';

/// 04_DATA_SCHEMA.md §10 `weather.json`의 `states.*` 항목.
class WeatherStateEffect {
  const WeatherStateEffect({
    this.allyAtkPct = 0,
    this.prayerRegenPct = 0,
    this.allyHealPct = 0,
    this.hotPctPerSec = 0,
  });

  final int allyAtkPct;
  final int prayerRegenPct;
  final int allyHealPct;
  final int hotPctPerSec;

  factory WeatherStateEffect.fromJson(Map<String, Object?> json) => WeatherStateEffect(
    allyAtkPct: json['allyAtkPct'] as int? ?? 0,
    prayerRegenPct: json['prayerRegenPct'] as int? ?? 0,
    allyHealPct: json['allyHealPct'] as int? ?? 0,
    hotPctPerSec: json['hotPctPerSec'] as int? ?? 0,
  );
}

/// 04_DATA_SCHEMA.md §10 `weather.json` 전체. 기본값은 문서 예시 수치
/// 그대로라, `weather.json`을 안 넘기는(대부분의 기존) 전투 테스트도
/// 문서에 정의된 실제 날씨 수치로 동작한다.
class WeatherConfig {
  const WeatherConfig({
    this.gaugeMin = -100,
    this.gaugeMax = 100,
    this.gaugeStart = 0,
    this.sampleTicks = 60,
    this.maxKindsPerTemper = 3,
    this.biasFactor = 6,
    this.biasClamp = 12,
    this.fieldDecayFactor = 4,
    this.toClear = 60,
    this.toNight = -60,
    this.clearExit = 40,
    this.nightExit = -40,
    this.clear = const WeatherStateEffect(allyAtkPct: 15000, prayerRegenPct: -10000, allyHealPct: -20000),
    this.dusk = const WeatherStateEffect(),
    this.night = const WeatherStateEffect(allyAtkPct: -10000, prayerRegenPct: 10000, hotPctPerSec: 250),
    this.healCapPctPerSec = 2000,
  });

  final int gaugeMin;
  final int gaugeMax;
  final int gaugeStart;

  final int sampleTicks;
  final int maxKindsPerTemper;
  final int biasFactor;
  final int biasClamp;
  final int fieldDecayFactor;

  final int toClear;
  final int toNight;
  final int clearExit;
  final int nightExit;

  final WeatherStateEffect clear;
  final WeatherStateEffect dusk;
  final WeatherStateEffect night;

  final int healCapPctPerSec;

  WeatherStateEffect effectOf(WeatherState state) => switch (state) {
    WeatherState.clear => clear,
    WeatherState.dusk => dusk,
    WeatherState.night => night,
  };

  factory WeatherConfig.fromJson(Map<String, Object?> json) {
    const d = WeatherConfig();
    final gauge = json['gauge'] as Map<String, Object?>? ?? const {};
    final sample = json['sample'] as Map<String, Object?>? ?? const {};
    final thresholds = json['thresholds'] as Map<String, Object?>? ?? const {};
    final states = json['states'] as Map<String, Object?>? ?? const {};

    WeatherStateEffect stateOf(String key, WeatherStateEffect fallback) {
      final raw = states[key] as Map<String, Object?>?;
      return raw == null ? fallback : WeatherStateEffect.fromJson(raw);
    }

    return WeatherConfig(
      gaugeMin: gauge['min'] as int? ?? d.gaugeMin,
      gaugeMax: gauge['max'] as int? ?? d.gaugeMax,
      gaugeStart: gauge['start'] as int? ?? d.gaugeStart,
      sampleTicks: sample['ticks'] as int? ?? d.sampleTicks,
      maxKindsPerTemper: sample['maxKindsPerTemper'] as int? ?? d.maxKindsPerTemper,
      biasFactor: sample['biasFactor'] as int? ?? d.biasFactor,
      biasClamp: sample['biasClamp'] as int? ?? d.biasClamp,
      fieldDecayFactor: sample['fieldDecayFactor'] as int? ?? d.fieldDecayFactor,
      toClear: thresholds['toClear'] as int? ?? d.toClear,
      toNight: thresholds['toNight'] as int? ?? d.toNight,
      clearExit: thresholds['clearExit'] as int? ?? d.clearExit,
      nightExit: thresholds['nightExit'] as int? ?? d.nightExit,
      clear: stateOf('CLEAR', d.clear),
      dusk: stateOf('DUSK', d.dusk),
      night: stateOf('NIGHT', d.night),
      healCapPctPerSec: json['healCapPctPerSec'] as int? ?? d.healCapPctPerSec,
    );
  }
}
