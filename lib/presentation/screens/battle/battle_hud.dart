import 'package:flutter/material.dart';

import '../../../battle/constants.dart';
import '../../../battle/world/battle_world.dart';
import '../../../battle/world/summon.dart';
import '../../../battle/world/ultimate.dart';
import '../../../game/hud/summon_slot_status.dart';
import 'widgets/prayer_gauge.dart';
import 'widgets/summon_slot_widget.dart';

const int _slotsPerPage = 5;

/// 05_FRONTEND.md §7 전투 HUD. 기도력 게이지·소환 슬롯(5칸+페이지)·필살기·
/// 집중강화·배속·기지 HP·타이머. `world`를 직접 훑어 그리는 순수 뷰라
/// 프레임마다 부모(BattleScreen)가 다시 빌드해주기만 하면 된다 — 자체
/// 폴링은 하지 않는다.
class BattleHud extends StatefulWidget {
  const BattleHud({
    super.key,
    required this.world,
    required this.speedMultiplier,
    required this.onSpeedChanged,
  });

  final BattleWorld world;
  final double speedMultiplier;
  final ValueChanged<double> onSpeedChanged;

  @override
  State<BattleHud> createState() => _BattleHudState();
}

class _BattleHudState extends State<BattleHud> {
  int _page = 0;

  BattleWorld get _w => widget.world;

  void _tapSlot(int slotIndex) {
    final result = trySummon(_w, slotIndex);
    if (result != SummonResult.ok) {
      _toast(_messageFor(result));
    }
    setState(() {}); // world는 직접 mutate되므로 로컬 리빌드만 필요
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  static String _messageFor(SummonResult r) => switch (r) {
    SummonResult.ok => '',
    SummonResult.invalidSlot => '잘못된 슬롯입니다',
    SummonResult.costExceedsCap => '집중 강화가 필요합니다',
    SummonResult.notEnoughPrayer => '기도력이 부족합니다',
    SummonResult.onCooldown => '아직 재사용 대기 중입니다',
    SummonResult.unitCapReached => '더 이상 소환할 수 없습니다(상한 도달)',
  };

  @override
  Widget build(BuildContext context) {
    final tickCosts = [
      for (var i = 0; i < _w.formation.length; i++)
        if (summonSlotStatus(_w, i) == SummonSlotStatus.notEnoughPrayer) _w.formation[i].def.base.summonCost,
    ];
    final pageCount = (_w.formation.length / _slotsPerPage).ceil().clamp(1, 1 << 30);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TopBar(world: _w, speedMultiplier: widget.speedMultiplier, onSpeedChanged: widget.onSpeedChanged),
        _BaseHpBar(world: _w),
        PrayerGauge(current: _w.prayerPower, cap: _w.currentPrayerCap, tickCosts: tickCosts),
        if (pageCount > 1) _PageTabs(page: _page, pageCount: pageCount, onChanged: (p) => setState(() => _page = p)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = _page * _slotsPerPage; i < (_page + 1) * _slotsPerPage; i++)
              if (i < _w.formation.length)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: SummonSlotWidget(
                    key: ValueKey('summon_slot_$i'),
                    status: summonSlotStatus(_w, i),
                    cost: _w.formation[i].def.base.summonCost,
                    cooldownSecLeft: (_w.formation[i].cooldownLeft / ticksPerSec).ceil(),
                    cooldownFraction: _cooldownFraction(i),
                    waitSecLeft: (ticksUntilAffordable(_w, i) / ticksPerSec).ceil(),
                    onTap: () => _tapSlot(i),
                  ),
                ),
            const SizedBox(width: 16),
            _UltimateButton(world: _w, onTap: () => setState(() => castUltimate(_w))),
          ],
        ),
      ],
    );
  }

  double _cooldownFraction(int slotIndex) {
    final slot = _w.formation[slotIndex];
    final total = slot.def.base.resummonCooldownSec * ticksPerSec;
    if (total <= 0) return 0;
    return (slot.cooldownLeft / total).clamp(0.0, 1.0);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.world, required this.speedMultiplier, required this.onSpeedChanged});
  final BattleWorld world;
  final double speedMultiplier;
  final ValueChanged<double> onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    final remainingSec = (world.config.stage.timeLimitSec - world.tick / ticksPerSec).clamp(0, 1 << 30).toInt();
    final mm = (remainingSec ~/ 60).toString().padLeft(2, '0');
    final ss = (remainingSec % 60).toString().padLeft(2, '0');
    return Row(
      children: [
        TextButton(
          key: const ValueKey('speed_toggle'),
          onPressed: () => onSpeedChanged(speedMultiplier >= 2.0 ? 1.0 : 2.0),
          child: Text('x${speedMultiplier.toInt()}'),
        ),
        const Spacer(),
        Text('⏱ $mm:$ss', key: const ValueKey('battle_timer')),
      ],
    );
  }
}

class _BaseHpBar extends StatelessWidget {
  const _BaseHpBar({required this.world});
  final BattleWorld world;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          '🔥 ${world.allyBase.hp}/${world.allyBase.maxHp}',
          key: const ValueKey('ally_base_hp'),
        ),
      ),
      Expanded(
        child: Text(
          '🪹 ${world.enemyBase.hp}/${world.enemyBase.maxHp}',
          key: const ValueKey('enemy_base_hp'),
        ),
      ),
    ],
  );
}

class _UltimateButton extends StatelessWidget {
  const _UltimateButton({required this.world, required this.onTap});
  final BattleWorld world;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    key: const ValueKey('ultimate_button'),
    onPressed: world.ultimateStock > 0 ? onTap : null,
    child: Text('간절한 기도 ⚡${world.ultimateStock}'),
  );
}

class _PageTabs extends StatelessWidget {
  const _PageTabs({required this.page, required this.pageCount, required this.onChanged});
  final int page;
  final int pageCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var p = 0; p < pageCount; p++)
        TextButton(
          key: ValueKey('page_tab_$p'),
          onPressed: () => onChanged(p),
          style: TextButton.styleFrom(
            backgroundColor: p == page ? Colors.brown.shade200 : null,
          ),
          child: Text('${p + 1}페이지'),
        ),
    ],
  );
}
