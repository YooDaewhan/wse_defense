import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/app/router.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/tag/tag_registry.dart';
import 'package:wse_defense/data/tag/tag_data_loader.dart';
import 'package:wse_defense/main.dart';

import '../support/test_app_scope.dart';

const _acorn = UnitDef(
  id: 'CHR_ACORN',
  base: UnitBaseStats(summonCost: 75, maxHp: 1200, atk: 90, attackPeriod: 60, attackWindup: 12, attackRecover: 48, attackRange: 130, moveSpeed: 100),
);

/// "편성 서버 동기화": 화면에서 캐릭터를 배정하면 서버(saveFormation)로도
/// 동기화를 시도한다. Firebase가 이 테스트 환경에 없어 실제 호출은
/// 실패하지만, 그 실패가 화면을 조용히 지나가는지(로컬 편집을 막지
/// 않는지)를 확인한다.
void main() {
  testWidgets('assigning a character in /formation attempts a server sync without crashing', (tester) async {
    // formation_screen_test.dart와 같은 이유: 필터 바만으로도 기본 테스트
    // 화면(600px)을 다 채워 편성 슬롯이 뷰포트 밖이라 아예 안 빌드된다.
    tester.view.physicalSize = const Size(800, 3600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final scope = testAppScope()
      ..datapack = const Datapack(characters: {'CHR_ACORN': _acorn}, enemies: {}, stages: {})
      ..tagBundle = TagBundle(registry: TagRegistry(const []), effects: const [], relations: const []);
    final router = buildAppRouter();

    await tester.pumpWidget(WseDefenseApp(router: router, appScope: scope));
    await tester.pump();
    router.go('/formation');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('formation_slot_0')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('pick_CHR_ACORN')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(scope.formation.current.first, 'CHR_ACORN'); // 로컬 편집 자체는 항상 성공
  });
}
