import 'package:wse_defense/application/app_scope.dart';

import '../data/local/support/in_memory_settings_store.dart';
import '../data/remote/support/in_memory_pending_submits_store.dart';
import '../domain/tutorial/support/in_memory_tutorial_store.dart';
import '../presentation/screens/formation/support/in_memory_formation_store.dart';
import '../presentation/screens/story/support/in_memory_journal_store.dart';

/// 실제 Hive 없이(위젯 테스트) [AppScope]가 필요한 곳이 전부 이걸 쓴다 --
/// 로더 결과(datapack 등)는 비어 있는 채로 두고, 테스트가 필요하면 직접
/// 채워 넣는다.
AppScope testAppScope() => AppScope(
  formation: InMemoryFormationStore(),
  journal: InMemoryJournalStore(),
  tutorial: InMemoryTutorialStore(),
  pendingSubmits: InMemoryPendingSubmitsStore(),
  settings: InMemorySettingsStore(),
);
