import 'package:flutter/material.dart';

import '../../../../game/tags/unit_detail_info.dart';

/// 05_FRONTEND.md §6.1: "유닛 탭 → 우측 슬라이드 패널에 전체 태그·
/// 모디파이어 내역(일시정지 상태에서만)." 호출부(BattleScreen)가 이미
/// 일시정지 여부를 확인하고 나서만 이 위젯을 보여준다.
class UnitDetailPanel extends StatelessWidget {
  const UnitDetailPanel({super.key, required this.info, required this.onClose});

  final UnitDetailInfo info;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        key: const ValueKey('unit_detail_panel'),
        color: Colors.black87,
        child: SizedBox(
          width: 220,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('태그 · 모디파이어', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('unit_detail_close'),
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onClose,
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 1),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('태그', style: TextStyle(color: Colors.white70)),
                      if (info.tags.isEmpty)
                        const Text('-', style: TextStyle(color: Colors.white38))
                      else
                        for (final t in info.tags)
                          Text('${t.tagId} Lv${t.level}', style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 12),
                      const Text('모디파이어', style: TextStyle(color: Colors.white70)),
                      if (info.modifiers.isEmpty)
                        const Text('-', style: TextStyle(color: Colors.white38))
                      else
                        for (final m in info.modifiers)
                          Text(
                            '${m.stat} ${m.op}${m.value} (${m.sourceLabel})',
                            style: const TextStyle(color: Colors.white),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
