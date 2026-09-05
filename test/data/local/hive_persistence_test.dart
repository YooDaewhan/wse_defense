import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:wse_defense/data/local/formation_repository.dart';
import 'package:wse_defense/data/local/settings_repository.dart';
import 'package:wse_defense/data/local/tutorial_repository.dart';

/// 09_MILESTONES.md T-29 완료조건: "설정·편성·튜토리얼 진행도가 앱 재시작
/// 후 유지". "재시작"을 실제로 흉내내기 위해 박스를 닫고 `Hive.init`을
/// 새로 호출한 뒤(인메모리 캐시를 전부 버리고) 같은 디스크 경로에서 다시
/// 연다 — 프로세스가 안 죽었을 뿐 진짜 파일 I/O 왕복을 거친다.
void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hive_test_');
  });

  tearDown(() async {
    await Hive.close();
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('settings survive a simulated app restart', () async {
    Hive.init(dir.path);
    var box = await Hive.openBox(SettingsRepository.boxName);
    SettingsRepository(box)
      ..bgmVolume = 0.4
      ..sfxVolume = 0.7
      ..battleSpeed = 2
      ..locale = 'en'
      ..skipStory = true;
    await box.close();

    Hive.init(dir.path); // "재시작" -- 인메모리 상태를 전부 버리고 새로 연다
    box = await Hive.openBox(SettingsRepository.boxName);
    final settings = SettingsRepository(box);

    expect(settings.bgmVolume, 0.4);
    expect(settings.sfxVolume, 0.7);
    expect(settings.battleSpeed, 2);
    expect(settings.locale, 'en');
    expect(settings.skipStory, isTrue);
  });

  test('the current formation and a saved preset survive a simulated app restart', () async {
    Hive.init(dir.path);
    var box = await Hive.openBox(FormationRepository.boxName);
    final repo = FormationRepository(box);
    repo.current = ['CHR_ACORN', 'CHR_DROPLET', null];
    repo.savePreset(1, ['CHR_BEAR']);
    await box.close();

    Hive.init(dir.path);
    box = await Hive.openBox(FormationRepository.boxName);
    final reopened = FormationRepository(box);

    expect(reopened.current.take(3), ['CHR_ACORN', 'CHR_DROPLET', null]);
    expect(reopened.current.length, FormationRepository.slotCount); // 나머지는 null로 패딩
    expect(reopened.preset(1).first, 'CHR_BEAR');
  });

  test('tutorial progress survives a simulated app restart', () async {
    Hive.init(dir.path);
    var box = await Hive.openBox(TutorialRepository.boxName);
    TutorialRepository(box)
      ..markCompleted('T1')
      ..markCompleted('T2');
    await box.close();

    Hive.init(dir.path);
    box = await Hive.openBox(TutorialRepository.boxName);
    final reopened = TutorialRepository(box);

    expect(reopened.completedSteps, {'T1', 'T2'});
    expect(reopened.isCompleted('T1'), isTrue);
    expect(reopened.isCompleted('T3'), isFalse);
  });
}
