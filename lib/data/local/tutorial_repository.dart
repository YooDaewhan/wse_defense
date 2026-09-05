import 'package:hive/hive.dart';

/// `TutorialController`가 실제로 필요로 하는 표면 — Hive 구현과 위젯
/// 테스트용 인메모리 구현이 공유한다(`FormationStore`/`JournalStore`와
/// 같은 이유).
abstract class TutorialStore {
  Set<String> get completedSteps;
  void markCompleted(String stepId);
  bool isCompleted(String stepId);
}

/// 05_FRONTEND.md §8 `tutorial` 박스: `completedSteps` 진행도.
class TutorialRepository implements TutorialStore {
  TutorialRepository(this._box);

  static const boxName = 'tutorial';
  final Box _box;

  @override
  Set<String> get completedSteps =>
      (_box.get('completedSteps') as List<Object?>?)?.cast<String>().toSet() ?? <String>{};

  @override
  void markCompleted(String stepId) {
    final steps = completedSteps..add(stepId);
    _box.put('completedSteps', steps.toList());
  }

  @override
  bool isCompleted(String stepId) => completedSteps.contains(stepId);
}
