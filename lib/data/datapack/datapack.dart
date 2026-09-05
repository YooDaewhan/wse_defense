import '../../battle/defs/stage_def.dart';
import '../../battle/defs/unit_def.dart';

/// 로딩된 데이터팩 전체의 인메모리 인덱스. id로 바로 조회한다.
class Datapack {
  const Datapack({
    required this.characters,
    required this.enemies,
    required this.stages,
  });

  final Map<String, UnitDef> characters;
  final Map<String, UnitDef> enemies;
  final Map<String, StageDef> stages;

  UnitDef? characterById(String id) => characters[id];
  UnitDef? enemyById(String id) => enemies[id];
  StageDef? stageById(String id) => stages[id];
}
