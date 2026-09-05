import 'dart:convert';

import '../../domain/growth/growth_config.dart';
import '../datapack/datapack_loader.dart' show AssetReader;

/// 04_DATA_SCHEMA.md §9 `growth.json` 로더. `DatapackLoader`와 같은
/// [AssetReader] 추상화를 재사용해 앱/CLI 양쪽에서 쓸 수 있다.
Future<GrowthConfig> loadGrowthConfig(AssetReader readJson) async {
  final raw = jsonDecode(await readJson('growth.json')) as Map<String, Object?>;
  return GrowthConfig.fromJson(raw);
}
