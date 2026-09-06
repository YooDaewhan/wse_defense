import 'dart:convert';

import '../../domain/dungeon/dungeon_def.dart';
import '../datapack/datapack_loader.dart' show AssetReader;

/// `assets/data/v1/dungeons.json`을 로딩한다. `AssetReader`는 실제 앱에서
/// `rootBundle.loadString`을, 테스트/CLI에서 `File.readAsString`을 넘기는
/// 기존 관례 그대로(datapack_loader.dart와 같은 패턴).
Future<DungeonConfig> loadDungeonConfig(AssetReader readJson) async {
  final raw = jsonDecode(await readJson('dungeons.json')) as Map<String, Object?>;
  return DungeonConfig.fromJson(raw);
}
