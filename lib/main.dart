import 'dart:async';

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
import 'data/remote/battle_submit_adapter.dart';
import 'data/remote/battle_submit_queue.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  await signInAnonymouslyIfNeeded();
  await initHiveForApp();
  final appScope = _buildAppScope();
  // 10_WIRING_PLAN.md T-60: "앱이 복귀했을 때" 미제출 전투를 재시도한다.
  // runApp을 막지 않도록 기다리지 않는다(실패해도 다음 앱 시작 때 또 시도).
  unawaited(BattleSubmitQueue(store: appScope.pendingSubmits, submit: submitBattlePayloadFn(appScope)).retryPending());
  runApp(WseDefenseApp(router: buildAppRouter(), appScope: appScope));
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
