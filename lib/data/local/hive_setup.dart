import 'package:hive_flutter/hive_flutter.dart';

import 'datapack_cache_repository.dart';
import 'formation_repository.dart';
import 'journal_repository.dart';
import 'pending_submits_repository.dart';
import 'settings_repository.dart';
import 'tutorial_repository.dart';

/// 로컬 리포지토리 5종(+datapackCache) 각각의 Hive 박스 이름. 별도
/// 상수로 뽑아 둔 이유는 `initHiveForApp()` 자체가 `Hive.initFlutter()`
/// (path_provider 플랫폼 채널)를 필요로 해 순수 테스트에서 직접 부를 수
/// 없기 때문 — 이 목록만 따로 테스트해서 "박스 하나를 깜빡 빠뜨림" 같은
/// 버그(실제로 journal이 그랬다)를 잡는다.
const hiveBoxNames = [
  SettingsRepository.boxName,
  FormationRepository.boxName,
  TutorialRepository.boxName,
  JournalRepository.boxName,
  PendingSubmitsRepository.boxName,
  DatapackCacheRepository.boxName,
];

/// 05_FRONTEND.md §8. 실제 앱에서 부트스트랩 시 1회 호출한다. 테스트는
/// `Hive.init(tempDir)`을 직접 불러 플랫폼 채널(path_provider) 없이
/// 격리된 디렉터리로 돈다 — 이 함수를 쓰지 않는다.
Future<void> initHiveForApp() async {
  await Hive.initFlutter();
  await Future.wait(hiveBoxNames.map(Hive.openBox));
}
