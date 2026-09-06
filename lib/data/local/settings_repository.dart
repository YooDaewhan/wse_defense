import 'package:hive/hive.dart';

/// `SettingsScreen`이 실제로 필요로 하는 표면 — Hive 구현과 위젯 테스트용
/// 인메모리 구현이 공유한다(`FormationStore`와 같은 이유).
abstract class SettingsStore {
  double get bgmVolume;
  set bgmVolume(double v);

  double get sfxVolume;
  set sfxVolume(double v);

  int get battleSpeed;
  set battleSpeed(int v);

  String get locale;
  set locale(String v);

  bool get skipStory;
  set skipStory(bool v);
}

/// 05_FRONTEND.md §8 `settings` 박스: bgmVolume, sfxVolume, battleSpeed,
/// locale, skipStory — 전부 primitive라 어댑터 없이 Hive가 그대로 다룬다.
class SettingsRepository implements SettingsStore {
  SettingsRepository(this._box);

  static const boxName = 'settings';
  final Box _box;

  @override
  double get bgmVolume => (_box.get('bgmVolume') as num?)?.toDouble() ?? 1.0;
  @override
  set bgmVolume(double v) => _box.put('bgmVolume', v);

  @override
  double get sfxVolume => (_box.get('sfxVolume') as num?)?.toDouble() ?? 1.0;
  @override
  set sfxVolume(double v) => _box.put('sfxVolume', v);

  @override
  int get battleSpeed => _box.get('battleSpeed') as int? ?? 1;
  @override
  set battleSpeed(int v) => _box.put('battleSpeed', v);

  @override
  String get locale => _box.get('locale') as String? ?? 'ko';
  @override
  set locale(String v) => _box.put('locale', v);

  @override
  bool get skipStory => _box.get('skipStory') as bool? ?? false;
  @override
  set skipStory(bool v) => _box.put('skipStory', v);
}
