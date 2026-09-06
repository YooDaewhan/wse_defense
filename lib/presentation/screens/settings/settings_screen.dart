import 'package:flutter/material.dart';

import '../../../data/local/settings_repository.dart';

/// 05_FRONTEND.md §2 `/settings`: "계정 연결, 음량, 언어, 데이터 초기화".
/// 계정 연결(OAuth 등)과 데이터 초기화(Hive+서버 동시 삭제)는 별도
/// 백엔드/확인 플로우가 필요해 이번엔 다루지 않는다 -- 여기서는
/// `SettingsStore`가 이미 들고 있는 primitive 5종(음량 2개, 전투 속도,
/// 언어, 스토리 건너뛰기)만 즉시 반영한다. 서버 호출이 없는 순수 로컬
/// 상태라 저장 버튼 없이 바뀌는 즉시 저장한다.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.store});

  final SettingsStore store;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('배경음 ${(store.bgmVolume * 100).round()}%'),
          Slider(
            key: const ValueKey('settings_bgm_volume'),
            value: store.bgmVolume,
            onChanged: (v) => setState(() => store.bgmVolume = v),
          ),
          Text('효과음 ${(store.sfxVolume * 100).round()}%'),
          Slider(
            key: const ValueKey('settings_sfx_volume'),
            value: store.sfxVolume,
            onChanged: (v) => setState(() => store.sfxVolume = v),
          ),
          const SizedBox(height: 16),
          const Text('전투 속도'),
          Row(
            children: [
              for (final speed in [1, 2, 3])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    key: ValueKey('settings_battle_speed_$speed'),
                    label: Text('${speed}x'),
                    selected: store.battleSpeed == speed,
                    onSelected: (_) => setState(() => store.battleSpeed = speed),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('언어'),
          DropdownButton<String>(
            key: const ValueKey('settings_locale'),
            value: store.locale,
            items: const [
              DropdownMenuItem(value: 'ko', child: Text('한국어')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => store.locale = v);
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            key: const ValueKey('settings_skip_story'),
            title: const Text('스토리 건너뛰기'),
            value: store.skipStory,
            onChanged: (v) => setState(() => store.skipStory = v),
          ),
        ],
      ),
    );
  }
}
