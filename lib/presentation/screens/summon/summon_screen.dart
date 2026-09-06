import 'package:flutter/material.dart';

import '../../../domain/gacha/banner_def.dart';

/// 05_FRONTEND.md `/summon`. 09_MILESTONES.md T-48 완료조건: "확률 표시,
/// 1회/10회, 교환 포인트 적립·이월, ratesVersion 원장 기록"(원장 기록은
/// 서버 `gachaPull` 쪽에서 처리 — `functions/src/gacha/gachaPull.ts`).
class SummonScreen extends StatelessWidget {
  const SummonScreen({
    super.key,
    required this.catalog,
    required this.heldItems,
    required this.exchangePoint,
    required this.onPull,
    required this.onTrialTap,
    required this.onExchangePickup,
  });

  final BannerCatalog catalog;

  /// itemId(ITM_RECRUIT_TICKET 등) -> 보유 수량.
  final Map<String, int> heldItems;

  /// `users/{uid}.currency.exchangePoint` — 배너 간 공유(이월).
  final int exchangePoint;

  final void Function(BannerDef banner, int count) onPull;

  /// 09_MILESTONES.md T-51 `/summon/trial/:id` 진입 -- 픽업 캐릭터 하나를 넘긴다.
  final void Function(String characterId) onTrialTap;

  /// 09_MILESTONES.md T-49 `exchangePickup` -- 교환 포인트로 지정 캐릭터
  /// 하나를 선택 획득한다(banner.exchangeTargets 중 하나).
  final void Function(BannerDef banner, String characterId) onExchangePickup;

  @override
  Widget build(BuildContext context) {
    final banners = catalog.banners;
    return DefaultTabController(
      length: banners.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('소환'),
          bottom: TabBar(
            tabs: [for (final banner in banners) Tab(text: banner.nameKey, key: ValueKey('summon_tab_${banner.id}'))],
          ),
        ),
        body: TabBarView(
          children: [
            for (final banner in banners)
              _BannerView(
                banner: banner,
                exchange: catalog.exchange,
                heldItems: heldItems,
                exchangePoint: exchangePoint,
                onPull: (count) => onPull(banner, count),
                onTrialTap: onTrialTap,
                onExchangePickup: (characterId) => onExchangePickup(banner, characterId),
              ),
          ],
        ),
      ),
    );
  }
}

class _BannerView extends StatelessWidget {
  const _BannerView({
    required this.banner,
    required this.exchange,
    required this.heldItems,
    required this.exchangePoint,
    required this.onPull,
    required this.onTrialTap,
    required this.onExchangePickup,
  });

  final BannerDef banner;
  final GachaExchangeRule exchange;
  final Map<String, int> heldItems;
  final int exchangePoint;
  final void Function(int count) onPull;
  final void Function(String characterId) onTrialTap;
  final void Function(String characterId) onExchangePickup;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: ValueKey('summon_banner_list_${banner.id}'),
      padding: const EdgeInsets.all(12),
      children: [
        if (banner.givesExchangePoint)
          Text(
            '교환 포인트 $exchangePoint / ${exchange.requiredPoints}',
            key: ValueKey('summon_exchange_progress_${banner.id}'),
          ),
        if (banner.givesExchangePoint && banner.exchangeTargets.isNotEmpty)
          Wrap(
            spacing: 8,
            children: [
              for (final characterId in banner.exchangeTargets)
                ElevatedButton(
                  key: ValueKey('summon_exchange_pickup_${banner.id}_$characterId'),
                  onPressed: exchangePoint >= exchange.requiredPoints ? () => onExchangePickup(characterId) : null,
                  child: Text('$characterId 선택 교환'),
                ),
            ],
          ),
        for (var i = 0; i < banner.rates.length; i++)
          _RateRow(banner: banner, rate: banner.rates[i], index: i, onTrialTap: onTrialTap),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: [
            ElevatedButton(
              key: ValueKey('summon_pull1_${banner.id}'),
              onPressed: () => onPull(1),
              child: Text('1회 (${banner.cost.single.item}×${banner.cost.single.amount}, '
                  '보유 ${heldItems[banner.cost.single.item] ?? 0})'),
            ),
            ElevatedButton(
              key: ValueKey('summon_pull10_${banner.id}'),
              onPressed: () => onPull(10),
              child: Text('10회 (${banner.cost.ten.item}×${banner.cost.ten.amount}, '
                  '보유 ${heldItems[banner.cost.ten.item] ?? 0})'),
            ),
          ],
        ),
      ],
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({required this.banner, required this.rate, required this.index, required this.onTrialTap});

  final BannerDef banner;
  final RateEntry rate;
  final int index;
  final void Function(String characterId) onTrialTap;

  @override
  Widget build(BuildContext context) {
    // totalPct는 밀리퍼센트(100000=100%) -> 퍼센트 표시는 /1000.
    final pct = rate.totalPct / 1000;
    final pickupLabel = rate.pickup ? ' (픽업)' : '';
    return Row(
      children: [
        Text(
          '레어도 ${rate.rarity}$pickupLabel: $pct%',
          key: ValueKey('summon_rate_${banner.id}_$index'),
        ),
        if (rate.pickup && rate.pool.isNotEmpty)
          TextButton(
            key: ValueKey('summon_trial_${banner.id}_$index'),
            onPressed: () => onTrialTap(rate.pool.first),
            child: const Text('체험'),
          ),
      ],
    );
  }
}
