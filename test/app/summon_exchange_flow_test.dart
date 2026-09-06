import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/app/router.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/domain/exchange/exchange_def.dart';
import 'package:wse_defense/domain/gacha/banner_def.dart';
import 'package:wse_defense/main.dart';

import '../support/test_app_scope.dart';

const _stage = StageDef(
  id: 'STG_1_1',
  index: 1,
  fieldLength: 2400,
  allyBaseX: 0,
  enemyBaseX: 2400,
  enemyBaseHp: 1000,
  timeLimitSec: 300,
);

const _catalog = BannerCatalog(
  banners: [
    BannerDef(
      id: 'BNR_STANDARD',
      kind: 'STANDARD',
      nameKey: 'bnr.standard',
      cost: BannerCost(single: CostEntry(item: 'ITM_RECRUIT_TICKET', amount: 1), ten: CostEntry(item: 'ITM_RECRUIT_TICKET', amount: 10)),
      rates: [RateEntry(rarity: 1, totalPct: 100000, pool: ['CHR_A1'])],
      duplicateConversion: DuplicateConversion(rarity3: 10, rarity2: 5, rarity1: 1, item: 'ITM_COLLECT_FRAGMENT'),
      givesExchangePoint: true,
      exchangeTargets: ['CHR_BEAR'],
    ),
  ],
  exchange: GachaExchangeRule(pointPerPull: 1, requiredPoints: 200),
);

const _exchangeConfig = ExchangeConfig(
  shops: [
    ShopDef(
      id: 'SHOP_DUNGEON_SUN',
      nameKey: 'shop.dungeon.sun',
      entries: [
        ExchangeEntryDef(
          id: 'EX_ANIMAL_MASK',
          cost: [CostEntry(item: 'ITM_SHARD_SUN_T3', amount: 10)],
          gain: GainDef(type: 'CURRENCY', id: 'ITM_GOLD', amount: 100),
        ),
      ],
    ),
  ],
);

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// 10_WIRING_PLAN.md T-61: 소환/교환/체험전 콜백이 실제 Callable을
/// 부르는지 확인한다. Firebase가 이 테스트 환경에 없어 호출은 항상
/// 실패하지만(T-59 ApiException 정리 덕에 크래시 없이 스낵바로 보임),
/// 그것으로 라우터가 빈 콜백(`() {}`)이 아니라 실제 배선을 타는지는
/// 확인할 수 있다.
void main() {
  testWidgets('10x pull attempts gachaPull and surfaces a readable error instead of crashing', (tester) async {
    _useTallSurface(tester);
    final scope = testAppScope()..bannerCatalog = _catalog;
    final router = buildAppRouter();

    await tester.pumpWidget(WseDefenseApp(router: router, appScope: scope));
    await tester.pump();
    router.go('/summon');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('summon_pull10_BNR_STANDARD')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('exchange pickup attempts exchangePickup and surfaces a readable error instead of crashing', (tester) async {
    _useTallSurface(tester);
    final scope = testAppScope()..bannerCatalog = _catalog;
    scope.setAccount(scope.account.copyWith(exchangePoint: 200)); // 요구치(200) 충족 -> 버튼 활성화
    final router = buildAppRouter();

    await tester.pumpWidget(WseDefenseApp(router: router, appScope: scope));
    await tester.pump();
    router.go('/summon');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('summon_tab_BNR_STANDARD')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('summon_exchange_pickup_BNR_STANDARD_CHR_BEAR')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('exchanging an entry attempts exchangeItems and surfaces a readable error instead of crashing', (tester) async {
    _useTallSurface(tester);
    final scope = testAppScope()..exchangeConfig = _exchangeConfig;
    final router = buildAppRouter();

    await tester.pumpWidget(WseDefenseApp(router: router, appScope: scope));
    await tester.pump();
    router.go('/exchange');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('exchange_button_EX_ANIMAL_MASK')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('starting a trial attempts startBattle(TRIAL) and surfaces a readable error instead of crashing', (tester) async {
    _useTallSurface(tester);
    final scope = testAppScope()..datapack = const Datapack(characters: {}, enemies: {}, stages: {'STG_1_1': _stage});
    final router = buildAppRouter();

    await tester.pumpWidget(WseDefenseApp(router: router, appScope: scope));
    await tester.pump();
    router.go('/summon/trial/CHR_BEAR');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('trial_start_button')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
