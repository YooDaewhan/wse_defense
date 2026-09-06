import 'package:wse_defense/data/local/settings_repository.dart';

class InMemorySettingsStore implements SettingsStore {
  @override
  double bgmVolume = 1.0;
  @override
  double sfxVolume = 1.0;
  @override
  int battleSpeed = 1;
  @override
  String locale = 'ko';
  @override
  bool skipStory = false;
}
