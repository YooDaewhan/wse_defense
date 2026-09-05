import 'package:flutter/material.dart';

import '../../../../game/hud/summon_slot_status.dart';

/// 05_FRONTEND.md §7 "소환 슬롯 상태 표시" 표 그대로:
/// 가능(밝게) / 기도력 부족(비용 빨강, 60% 어둡게, 남은 대기 초) /
/// 쿨타임(원형 오버레이 + 남은 초) / 상한 도달("가득" 배지) /
/// 비용 초과(자물쇠 + "집중 강화 필요").
class SummonSlotWidget extends StatelessWidget {
  const SummonSlotWidget({
    super.key,
    required this.status,
    required this.cost,
    this.cooldownSecLeft = 0,
    this.cooldownFraction = 0,
    this.waitSecLeft = 0,
    required this.onTap,
  });

  final SummonSlotStatus status;
  final int cost;
  final int cooldownSecLeft;
  final double cooldownFraction; // 1(막 걸림) -> 0(곧 풀림)
  final int waitSecLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dimmed = status == SummonSlotStatus.notEnoughPrayer;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: dimmed ? 0.4 : 1.0,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(color: const Color(0xFF8D6E63)),
              Text(
                '$cost',
                style: TextStyle(
                  color: status == SummonSlotStatus.notEnoughPrayer ? Colors.red : Colors.white,
                ),
              ),
              if (status == SummonSlotStatus.onCooldown) ...[
                Positioned.fill(
                  child: CircularProgressIndicator(
                    key: const ValueKey('cooldown_overlay'),
                    value: cooldownFraction,
                  ),
                ),
                Positioned(
                  bottom: 2,
                  child: Text('${cooldownSecLeft}s', key: const ValueKey('cooldown_seconds')),
                ),
              ],
              if (status == SummonSlotStatus.unitCapReached)
                const Positioned(
                  top: 0,
                  child: _Badge(key: ValueKey('cap_badge'), text: '가득'),
                ),
              if (status == SummonSlotStatus.costExceedsCap)
                const Positioned(
                  child: Icon(Icons.lock, key: ValueKey('locked_icon'), color: Colors.white70),
                ),
              if (status == SummonSlotStatus.notEnoughPrayer)
                Positioned(
                  bottom: 2,
                  child: Text('${waitSecLeft}s', key: const ValueKey('wait_seconds')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    color: Colors.black87,
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
  );
}
