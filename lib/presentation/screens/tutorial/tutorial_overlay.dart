import 'package:flutter/material.dart';

import '../../../domain/tutorial/tutorial_step.dart';

/// 05_FRONTEND.md §9.2: 현재 단계 안내 + 하이라이트 대상 표시.
///
/// 실제 스포트라이트 연출(해당 UI 요소만 밝히고 나머지를 어둡게/잠그기)은
/// HUD 각 요소에 GlobalKey를 배선해야 해서(P0~P1 범위 밖, 아트도 없음)
/// 하지 않는다 — 대신 강조 대상 이름을 라벨로 보여준다.
class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({super.key, required this.step});

  final TutorialStep? step;

  @override
  Widget build(BuildContext context) {
    final step = this.step;
    if (step == null) return const SizedBox.shrink();

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Material(
        key: const ValueKey('tutorial_overlay'),
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(step.textKey, key: const ValueKey('tutorial_text'), style: const TextStyle(color: Colors.white)),
              if (step.highlight != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '👉 ${step.highlight}',
                    key: const ValueKey('tutorial_highlight'),
                    style: const TextStyle(color: Colors.amber),
                  ),
                ),
              if (step.pauseSim)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '(일시정지됨)',
                    key: ValueKey('tutorial_paused'),
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
