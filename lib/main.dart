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
import 'data/remote/account_loader.dart';
import 'data/remote/battle_submit_adapter.dart';
import 'data/remote/battle_submit_queue.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase();
  final user = await signInAnonymouslyIfNeeded();
  await initHiveForApp();
  final appScope = _buildAppScope();
  // 10_WIRING_PLAN.md T-63 준비: bootstrapAccount를 아무도 안 불러
  // scope.account가 항상 기본값(gold 0, 캐릭터 0개)에서 시작하던 문제(T-62
  // 조사 중 발견). 화면들이 AppScope 변경을 자동 구독하지 않아(app_scope.dart
  // 주석) runApp 전에 채워둬야 첫 화면부터 실제 값이 보인다. 실패해도(오프라인
  // 등) 기본값으로 시작 -- 다음 실행 때 다시 시도한다.
  try {
    appScope.setAccount(await loadAccountAfterBootstrap(user.uid));
  } catch (_) {
    // 조용히 넘어간다.
  }
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
