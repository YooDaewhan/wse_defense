import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/data/local/datapack_cache_repository.dart';
import 'package:wse_defense/data/local/formation_repository.dart';
import 'package:wse_defense/data/local/hive_setup.dart';
import 'package:wse_defense/data/local/journal_repository.dart';
import 'package:wse_defense/data/local/pending_submits_repository.dart';
import 'package:wse_defense/data/local/settings_repository.dart';
import 'package:wse_defense/data/local/tutorial_repository.dart';

/// 10_WIRING_PLAN.md 현황 조사: "initHiveForApp()도 어디서도 호출되지
/// 않는다" -- 그 진단 이전에는 journal 박스 자체가 이 목록에서 빠져 있어,
/// initHiveForApp()을 불렀어도 JournalRepository는 못 여는 박스로 죽었을
/// 것이다. initHiveForApp() 자체는 Hive.initFlutter()(path_provider
/// 플랫폼 채널) 때문에 순수 테스트에서 직접 못 부르므로, 박스 이름 목록만
/// 따로 검증한다.
void main() {
  test('opens a box for every local repository, including journal', () {
    expect(hiveBoxNames, containsAll(<String>[
      SettingsRepository.boxName,
      FormationRepository.boxName,
      TutorialRepository.boxName,
      JournalRepository.boxName,
      PendingSubmitsRepository.boxName,
      DatapackCacheRepository.boxName,
    ]));
  });
}
