import 'package:hive/hive.dart';

/// 05_FRONTEND.md §8 `tutorial` 박스: `completedSteps` 진행도.
class TutorialRepository {
  TutorialRepository(this._box);

  static const boxName = 'tutorial';
  final Box _box;

  Set<String> get completedSteps =>
      (_box.get('completedSteps') as List<Object?>?)?.cast<String>().toSet() ?? <String>{};

  void markCompleted(String stepId) {
    final steps = completedSteps..add(stepId);
    _box.put('completedSteps', steps.toList());
  }

  bool isCompleted(String stepId) => completedSteps.contains(stepId);
}
