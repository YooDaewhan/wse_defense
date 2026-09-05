import 'package:wse_defense/data/local/journal_repository.dart';

class InMemoryJournalStore implements JournalStore {
  final Set<String> _ids = {};

  @override
  Set<String> get unlockedSceneIds => Set.of(_ids);

  @override
  void markUnlocked(String sceneId) => _ids.add(sceneId);
}
