import 'package:hive/hive.dart';

/// `BattleSubmitQueue`가 실제로 필요로 하는 표면 — Hive 구현과 위젯/유닛
/// 테스트용 인메모리 구현이 공유한다(`FormationStore`/`JournalStore`와 같은
/// 이유로 인터페이스를 뽑았다).
abstract class PendingSubmitsStore {
  List<Map<String, dynamic>> get pending;
  void enqueue(Map<String, dynamic> payload);
  void remove(String idempotencyKey);
}

/// 06_BACKEND.md §6.2: "네트워크가 끊겨도 진행 중 전투는 끝까지 플레이하게
/// 하고, 결과 제출만 재시도 큐에 넣는다. (pendingSubmits Hive 박스 → 복귀
/// 시 자동 제출. 멱등키로 중복 방지)". 큐 항목은 `idempotencyKey`를 Hive
/// 키로 써서, 같은 제출을 두 번 큐에 넣어도 하나로 합쳐진다.
class PendingSubmitsRepository implements PendingSubmitsStore {
  PendingSubmitsRepository(this._box);

  static const boxName = 'pendingSubmits';
  final Box _box;

  @override
  List<Map<String, dynamic>> get pending =>
      _box.values.map((v) => Map<String, dynamic>.from(v as Map)).toList();

  @override
  void enqueue(Map<String, dynamic> payload) {
    final key = payload['idempotencyKey'] as String;
    _box.put(key, payload);
  }

  @override
  void remove(String idempotencyKey) => _box.delete(idempotencyKey);
}
