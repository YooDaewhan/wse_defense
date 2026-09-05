import 'package:flutter/material.dart';

/// 05_FRONTEND.md §7: 기도력 게이지. "다음 소환 가능 시점을 눈금으로
/// 표시한다" — [tickCosts](아직 감당 못 하는 슬롯들의 비용)마다 그 위치에
/// 작은 눈금을 그린다.
class PrayerGauge extends StatelessWidget {
  const PrayerGauge({super.key, required this.current, required this.cap, this.tickCosts = const []});

  final int current;
  final int cap;
  final List<int> tickCosts;

  @override
  Widget build(BuildContext context) {
    final fraction = cap <= 0 ? 0.0 : (current / cap).clamp(0.0, 1.0);
    return SizedBox(
      height: 20,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: fraction, minHeight: 20),
              ),
              if (cap > 0)
                for (final cost in tickCosts)
                  Positioned(
                    left: ((cost / cap).clamp(0.0, 1.0) * width - 1).clamp(0.0, width - 2),
                    top: 0,
                    bottom: 0,
                    child: Container(key: ValueKey('prayer_tick_$cost'), width: 2, color: Colors.black87),
                  ),
            ],
          );
        },
      ),
    );
  }
}
