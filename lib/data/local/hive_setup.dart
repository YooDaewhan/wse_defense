import 'package:hive_flutter/hive_flutter.dart';

import 'datapack_cache_repository.dart';
import 'formation_repository.dart';
import 'pending_submits_repository.dart';
import 'settings_repository.dart';
import 'tutorial_repository.dart';

/// 05_FRONTEND.md §8. 실제 앱에서 부트스트랩 시 1회 호출한다. 테스트는
/// `Hive.init(tempDir)`을 직접 불러 플랫폼 채널(path_provider) 없이
/// 격리된 디렉터리로 돈다 — 이 함수를 쓰지 않는다.
Future<void> initHiveForApp() async {
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox(SettingsRepository.boxName),
    Hive.openBox(FormationRepository.boxName),
    Hive.openBox(TutorialRepository.boxName),
    Hive.openBox(PendingSubmitsRepository.boxName),
    Hive.openBox(DatapackCacheRepository.boxName),
  ]);
}
