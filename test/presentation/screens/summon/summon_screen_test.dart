import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/domain/exchange/exchange_def.dart';
import 'package:wse_defense/domain/gacha/banner_def.dart';
import 'package:wse_defense/presentation/screens/summon/summon_screen.dart';

const _catalog = BannerCatalog(
  banners: [
    BannerDef(
      id: 'BNR_STANDARD',
      kind: 'STANDARD',
      nameKey: 'bnr.standard',
      cost: BannerCost(
        single: CostEntry(item: 'ITM_RECRUIT_TICKET', amount: 1),
        ten: CostEntry(item: 'ITM_RECRUIT_TICKET', amount: 10),
      ),
      rates: [
        RateEntry(rarity: 3, pickup: true, totalPct: 1500, pool: ['CHR_PICKUP']),
        RateEntry(rarity: 1, totalPct: 98500, pool: ['CHR_A1']),
      ],
      duplicateConversion: DuplicateConversion(rarity3: 10, rarity2: 5, rarity1: 1, item: 'ITM_COLLECT_FRAGMENT'),
    ),
    BannerDef(
      id: 'BNR_THEME_BEAR',
      kind: 'THEME',
      nameKey: 'bnr.theme_bear',
      cost: BannerCost(
        single: CostEntry(item: 'ITM_RECRUIT_TICKET', amount: 1),
        ten: CostEntry(item: 'ITM_RECRUIT_TICKET', amount: 10),
      ),
      givesExchangePoint: true,
      rates: [RateEntry(rarity: 1, totalPct: 100000, pool: ['CHR_BEAR'])],
      duplicateConversion: DuplicateConversion(rarity3: 10, rarity2: 5, rarity1: 1, item: 'ITM_COLLECT_FRAGMENT'),
      exchangeTargets: ['CHR_BEAR'],
    ),
  ],
  exchange: GachaExchangeRule(pointPerPull: 1, requiredPoints: 200),
);

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// 09_MILESTONES.md T-48 완료조건: "확률 표시, 1회/10회, 교환 포인트 적립·이월".
void main() {
  testWidgets('shows each rate tier\'s percentage and pickup marker', (tester) async {
    _useTallSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: SummonScreen(
          catalog: _catalog,
          heldItems: const {},
          exchangePoint: 0,
          onPull: (banner, count) {},
          onTrialTap: (characterId) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('레어도 3 (픽업): 1.5%'), findsOneWidget);
    expect(find.text('레어도 1: 98.5%'), findsOneWidget);
  });

  testWidgets('shows held ticket counts on the 1x/10x buttons', (tester) async {
    _useTallSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: SummonScreen(
          catalog: _catalog,
          heldItems: const {'ITM_RECRUIT_TICKET': 15},
          exchangePoint: 0,
          onPull: (banner, count) {},
          onTrialTap: (characterId) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1회 (ITM_RECRUIT_TICKET×1, 보유 15)'), findsOneWidget);
    expect(find.text('10회 (ITM_RECRUIT_TICKET×10, 보유 15)'), findsOneWidget);
  });

  testWidgets('only the exchange-point-granting banner shows exchange-point progress', (tester) async {
    _useTallSurface(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: SummonScreen(
          catalog: _catalog,
          heldItems: const {},
          exchangePoint: 40,
          onPull: (banner, count) {},
          onTrialTap: (characterId) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('summon_exchange_progress_BNR_STANDARD')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('summon_tab_BNR_THEME_BEAR')));
    await tester.pumpAndSettle();

    expect(find.text('교환 포인트 40 / 200'), findsOneWidget);
  });

  testWidgets('the 1x and 10x buttons invoke onPull with the current banner and count', (tester) async {
    _useTallSurface(tester);
    BannerDef? pulledBanner;
    int? pulledCount;

    await tester.pumpWidget(
      MaterialApp(
        home: SummonScreen(
          catalog: _catalog,
          heldItems: const {},
          exchangePoint: 0,
          onPull: (banner, count) {
            pulledBanner = banner;
            pulledCount = count;
          },
          onTrialTap: (characterId) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('summon_pull10_BNR_STANDARD')));
    await tester.pumpAndSettle();

    expect(pulledBanner?.id, 'BNR_STANDARD');
    expect(pulledCount, 10);
  });

  testWidgets('T-51: only pickup rows show a trial button, and tapping it reports the pickup character', (tester) async {
    _useTallSurface(tester);
    String? tappedCharacterId;

    await tester.pumpWidget(
      MaterialApp(
        home: SummonScreen(
          catalog: _catalog,
          heldItems: const {},
          exchangePoint: 0,
          onPull: (banner, count) {},
          onTrialTap: (characterId) => tappedCharacterId = characterId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('summon_trial_BNR_STANDARD_0')), findsOneWidget); // 픽업(레어도 3)
    expect(find.byKey(const ValueKey('summon_trial_BNR_STANDARD_1')), findsNothing); // 비픽업(레어도 1)

    await tester.tap(find.byKey(const ValueKey('summon_trial_BNR_STANDARD_0')));
    await tester.pumpAndSettle();

    expect(tappedCharacterId, 'CHR_PICKUP');
  });
}
