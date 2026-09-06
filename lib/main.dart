import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'app/bootstrap.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'application/app_scope.dart';
import 'data/local/formation_repository.dart';
import 'data/local/hive_setup.dart';
import 'data/local/journal_repository.dart';
import 'data/local/pending_submits_repository.dart';
import 'data/local/settings_repository.dart';
import 'data/local/tutorial_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  await signInAnonymouslyIfNeeded();
  await initHiveForApp();
  runApp(WseDefenseApp(router: buildAppRouter(), appScope: _buildAppScope()));
}

/// initHiveForApp()이 이미 5개 박스를 다 열어 둔 뒤라, 여기서는 그 박스로
/// 진짜 Hive 리포지토리를 만들기만 한다(10_WIRING_PLAN.md T-56).
AppScope _buildAppScope() => AppScope(
  formation: FormationRepository(Hive.box(FormationRepository.boxName)),
  journal: JournalRepository(Hive.box(JournalRepository.boxName)),
  tutorial: TutorialRepository(Hive.box(TutorialRepository.boxName)),
  pendingSubmits: PendingSubmitsRepository(Hive.box(PendingSubmitsRepository.boxName)),
  settings: SettingsRepository(Hive.box(SettingsRepository.boxName)),
);

class WseDefenseApp extends StatelessWidget {
  const WseDefenseApp({super.key, required this.router, required this.appScope});

  final RouterConfig<Object> router;
  final AppScope appScope;

  @override
  Widget build(BuildContext context) {
    return AppScopeProvider(
      scope: appScope,
      child: MaterialApp.router(
        title: 'WSE Defense',
        theme: buildAppTheme(),
        routerConfig: router,
      ),
    );
  }
}
