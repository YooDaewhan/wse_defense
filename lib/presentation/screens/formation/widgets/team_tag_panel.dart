import 'package:flutter/material.dart';

import '../../../../domain/formation/team_tag_preview.dart';

/// 05_FRONTEND.md §3.1 팀 태그 패널: 팀 태그 레벨, 활성 티어, 다음 티어까지
/// 남은 양, 이 편성에서 발동 가능한 관계 규칙 예고.
class TeamTagPanel extends StatelessWidget {
  const TeamTagPanel({super.key, required this.preview});

  final TeamTagPreview preview;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('team_tag_panel'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('팀 태그', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: [
              for (final entry in preview.formationLevels.entries)
                Text('${entry.key} Lv${entry.value}', key: ValueKey('team_tag_${entry.key}')),
            ],
          ),
          const SizedBox(height: 8),
          for (final tier in preview.activeTiers)
            Text('✔ ${tier.tagId} Lv${tier.minLevel}', key: ValueKey('active_tier_${tier.effectId}_${tier.minLevel}')),
          for (final hint in preview.nextTierHints)
            Text(
              '○ ${hint.tagId} Lv${hint.nextTierMinLevel} (${hint.tagId} ${hint.levelsNeeded} 더 필요)',
              key: ValueKey('next_tier_${hint.effectId}'),
            ),
          if (preview.relationHints.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('발동 가능한 관계', style: TextStyle(fontWeight: FontWeight.bold)),
            for (final hint in preview.relationHints)
              Text(
                '⚠ ${hint.nameKey.isEmpty ? hint.ruleId : hint.nameKey}',
                key: ValueKey('relation_hint_${hint.ruleId}'),
              ),
          ],
        ],
      ),
    );
  }
}
