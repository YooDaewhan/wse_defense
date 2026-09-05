import 'stage_def.dart';
import 'unit_def.dart';

/// 로딩된 데이터팩 전체의 인메모리 인덱스. id로 바로 조회한다.
///
/// 순수 데이터 인덱스라 battle/**에 둔다 (I/O는 하지 않음). 실제 JSON을
/// 읽어 이 객체를 만드는 `DatapackLoader`는 data/ 레이어에 있다 —
/// `BattleWorld`가 `Datapack`을 직접 참조해야 하는데(§1), data/ 레이어를
/// battle/**에서 import할 수는 없어서(01_ARCHITECTURE.md §1) 이렇게 나눴다.
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
