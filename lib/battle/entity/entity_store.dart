import 'battle_entity.dart';

/// 03_BATTLE_ENGINE.md §1: 엔티티 저장소 — entityId 오름차순 정렬 유지.
///
/// `entityId`는 스폰 순서대로 단조 증가하므로 [add]에서 항상 끝에 붙이면
/// 정렬이 유지된다. `_byId`는 순회하지 않고 단건 조회에만 쓰므로
/// 01_ARCHITECTURE.md §3.2의 "Map/Set 순회 금지"에 저촉되지 않는다.
class EntityStore {
  final List<BattleEntity> _sorted = [];
  final Map<int, BattleEntity> _byId = {};

  void add(BattleEntity entity) {
    _byId[entity.id] = entity;
    _sorted.add(entity);
  }

  BattleEntity? byId(int id) => _byId[id];

  void removeById(int id) {
    final entity = _byId.remove(id);
    if (entity != null) _sorted.remove(entity);
  }

  /// 항상 entityId 오름차순 (03_BATTLE_ENGINE.md의 `w.entities.ordered`).
  Iterable<BattleEntity> get ordered => _sorted;

  int get length => _sorted.length;
}
