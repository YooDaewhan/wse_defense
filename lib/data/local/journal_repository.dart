import 'package:hive/hive.dart';

/// `StoryPlayerScreen`이 실제로 필요로 하는 표면 — Hive 구현과 위젯
/// 테스트용 인메모리 구현이 공유한다(`FormationStore`와 같은 이유,
/// T-31에서 겪은 Hive+testWidgets 조합 문제를 피하기 위함).
abstract class JournalStore {
  Set<String> get unlockedSceneIds;
  void markUnlocked(String sceneId);
}

/// 05_FRONTEND.md §9.1: "스킵해도 journal에 등록되어 다시 볼 수 있다."
/// 문서의 §8 박스 표에는 없지만(당시엔 스토리 재생기가 없었음), `tutorial`
/// 박스와 완전히 같은 모양이라 그대로 따른다 — 진짜 서버 동기화 여행
/// 수첩(다른 화면)은 T-36 이후 `accountMirror`와 합쳐질 수 있다.
class JournalRepository implements JournalStore {
  JournalRepository(this._box);

  static const boxName = 'journal';
  final Box _box;

  @override
  Set<String> get unlockedSceneIds =>
      (_box.get('unlockedSceneIds') as List<Object?>?)?.cast<String>().toSet() ?? <String>{};

  @override
  void markUnlocked(String sceneId) {
    final ids = unlockedSceneIds..add(sceneId);
    _box.put('unlockedSceneIds', ids.toList());
  }
}
