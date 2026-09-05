import 'package:wse_defense/data/local/tutorial_repository.dart';

class InMemoryTutorialStore implements TutorialStore {
  final Set<String> _ids = {};

  @override
  Set<String> get completedSteps => Set.of(_ids);

  @override
  void markCompleted(String stepId) => _ids.add(stepId);

  @override
  bool isCompleted(String stepId) => _ids.contains(stepId);
}
