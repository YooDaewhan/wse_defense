import 'package:flutter/material.dart';

import '../../../domain/account/account_state.dart';

/// 05_FRONTEND.md §2 `/camp`: 메인 허브. 10_WIRING_PLAN.md T-58 완료조건:
/// "재화(금화, 기도력 관련 표시) + 동행/집중력/캠프 레벨을 AccountState에서
/// 읽어 표시, 9개 화면 진입 동선. 화면 자체에 로직 없음 — 읽고 넘길 뿐".
class CampScreen extends StatelessWidget {
  const CampScreen({
    super.key,
    required this.account,
    required this.onAdventureTap,
    required this.onFormationTap,
    required this.onSummonTap,
    required this.onDungeonTap,
    required this.onExchangeTap,
    required this.onInventoryTap,
    required this.onMailTap,
    required this.onJournalTap,
    required this.onSettingsTap,
  });

  final AccountState account;
  final VoidCallback onAdventureTap;
  final VoidCallback onFormationTap;
  final VoidCallback onSummonTap;
  final VoidCallback onDungeonTap;
  final VoidCallback onExchangeTap;
  final VoidCallback onInventoryTap;
  final VoidCallback onMailTap;
  final VoidCallback onJournalTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('캠프')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Text('금화 ${account.gold}', key: const ValueKey('camp_gold')),
              Text('동행 Lv.${account.bondLevel}', key: const ValueKey('camp_bond_level')),
              // 집중력이 전투 중 기도력의 회복량·상한·시작량을 정한다(04_DATA_SCHEMA.md
              // §9 prayer) -- 그 산출 수치 자체는 전투 안에서만 존재해 여기서는
              // 계산하지 않고(로직 없음) 레벨만 그대로 보여준다.
              Text('집중력 Lv.${account.focusLevel} (기도력 회복·상한 결정)', key: const ValueKey('camp_focus_level')),
              Text('캠프 방어 Lv.${account.campLevel}', key: const ValueKey('camp_defense_level')),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _NavButton(label: '모험', keySuffix: 'adventure', onTap: onAdventureTap),
              _NavButton(label: '편성', keySuffix: 'formation', onTap: onFormationTap),
              _NavButton(label: '소환', keySuffix: 'summon', onTap: onSummonTap),
              _NavButton(label: '요일던전', keySuffix: 'dungeon', onTap: onDungeonTap),
              _NavButton(label: '교환소', keySuffix: 'exchange', onTap: onExchangeTap),
              _NavButton(label: '보관함', keySuffix: 'inventory', onTap: onInventoryTap),
              _NavButton(label: '우편', keySuffix: 'mail', onTap: onMailTap),
              _NavButton(label: '여행 수첩', keySuffix: 'journal', onTap: onJournalTap),
              _NavButton(label: '설정', keySuffix: 'settings', onTap: onSettingsTap),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.keySuffix, required this.onTap});

  final String label;
  final String keySuffix;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(key: ValueKey('camp_nav_$keySuffix'), onPressed: onTap, child: Text(label));
}
