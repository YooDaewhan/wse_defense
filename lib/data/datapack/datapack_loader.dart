import 'dart:convert';

import '../../battle/defs/stage_def.dart';
import '../../battle/defs/unit_def.dart';
import '../../battle/defs/wave_def.dart';
import 'datapack.dart';

/// 상대 경로(예: `characters.json`, `stages/chapter_1.json`)를 받아
/// `assets/data/v1/` 밑의 JSON 문자열을 돌려준다. 실제 앱에서는
/// `rootBundle.loadString('assets/data/v1/$path')`를, `tool/validate_data.dart`
/// 같은 순수 CLI에서는 `File('assets/data/v1/$path').readAsString()`을 넘긴다.
typedef AssetReader = Future<String> Function(String relativePath);

/// 04_DATA_SCHEMA.md §1: 번들 파일만 읽는다 (원격 다운로드/비교는 T-40).
/// 관용성 규칙: 알 수 없는 필드는 json_serializable이 읽지 않는 것으로 자연히
/// 무시되고, 존재하지 않는 ID 참조나 파싱 실패 항목은 경고 로그만 남기고
/// 건너뛴다 (크래시 금지).
class DatapackLoader {
  DatapackLoader(this._readJson, {void Function(String)? onWarning})
      : _warn = onWarning ?? print;

  final AssetReader _readJson;
  final void Function(String) _warn;

  Future<Datapack> load() async {
    final characters = await _loadUnits('characters.json', 'characters');
    final enemies = await _loadUnits('enemies.json', 'enemies');
    final stages = await _loadStages('stages/chapter_1.json', enemies);
    return Datapack(characters: characters, enemies: enemies, stages: stages);
  }

  Future<Map<String, UnitDef>> _loadUnits(String path, String listKey) async {
    final raw = jsonDecode(await _readJson(path)) as Map<String, Object?>;
    final list = raw[listKey] as List<Object?>? ?? const [];
    final result = <String, UnitDef>{};
    for (final entry in list) {
      try {
        final def = UnitDef.fromJson(entry as Map<String, Object?>);
        result[def.id] = def;
      } catch (e) {
        _warn('$path: 유닛 정의 파싱 실패, 건너뜀 ($e)');
      }
    }
    return result;
  }

  Future<Map<String, StageDef>> _loadStages(
    String path,
    Map<String, UnitDef> enemies,
  ) async {
    final raw = jsonDecode(await _readJson(path)) as Map<String, Object?>;
    final list = raw['stages'] as List<Object?>? ?? const [];
    final result = <String, StageDef>{};
    for (final entry in list) {
      StageDef stage;
      try {
        stage = StageDef.fromJson(entry as Map<String, Object?>);
      } catch (e) {
        _warn('$path: 스테이지 파싱 실패, 건너뜀 ($e)');
        continue;
      }

      final waves = <WaveDef>[];
      for (final w in stage.waves) {
        if (enemies.containsKey(w.enemyId)) {
          waves.add(w);
        } else {
          _warn('${stage.id}: 존재하지 않는 enemyId "${w.enemyId}" 웨이브 무시');
        }
      }

      final bossTriggers = <BossTriggerDef>[];
      for (final b in stage.bossTriggers) {
        if (enemies.containsKey(b.enemyId)) {
          bossTriggers.add(b);
        } else {
          _warn('${stage.id}: 존재하지 않는 enemyId "${b.enemyId}" 보스 트리거 무시');
        }
      }

      result[stage.id] = stage.copyWith(waves: waves, bossTriggers: bossTriggers);
    }
    return result;
  }
}
