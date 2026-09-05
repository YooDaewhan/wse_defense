import 'package:hive/hive.dart';

/// 05_FRONTEND.md §8 `settings` 박스: bgmVolume, sfxVolume, battleSpeed,
/// locale, skipStory — 전부 primitive라 어댑터 없이 Hive가 그대로 다룬다.
class SettingsRepository {
  SettingsRepository(this._box);

  static const boxName = 'settings';
  final Box _box;

  double get bgmVolume => (_box.get('bgmVolume') as num?)?.toDouble() ?? 1.0;
  set bgmVolume(double v) => _box.put('bgmVolume', v);

  double get sfxVolume => (_box.get('sfxVolume') as num?)?.toDouble() ?? 1.0;
  set sfxVolume(double v) => _box.put('sfxVolume', v);

  int get battleSpeed => _box.get('battleSpeed') as int? ?? 1;
  set battleSpeed(int v) => _box.put('battleSpeed', v);

  String get locale => _box.get('locale') as String? ?? 'ko';
  set locale(String v) => _box.put('locale', v);

  bool get skipStory => _box.get('skipStory') as bool? ?? false;
  set skipStory(bool v) => _box.put('skipStory', v);
}
