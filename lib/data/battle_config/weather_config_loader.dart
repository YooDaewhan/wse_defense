import 'dart:convert';

import '../../battle/defs/weather_config.dart';
import '../datapack/datapack_loader.dart' show AssetReader;

/// `assets/data/v1/weather.json`을 로딩한다(growth_config_loader.dart와
/// 같은 패턴).
Future<WeatherConfig> loadWeatherConfig(AssetReader readJson) async {
  final raw = jsonDecode(await readJson('weather.json')) as Map<String, Object?>;
  return WeatherConfig.fromJson(raw);
}
