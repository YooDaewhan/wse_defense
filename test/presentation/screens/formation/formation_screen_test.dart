import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/data/datapack/datapack_loader.dart';
import 'package:wse_defense/data/tag/tag_data_loader.dart';
import 'package:wse_defense/presentation/screens/formation/formation_screen.dart';

import 'support/in_memory_formation_store.dart';

Future<String> _readAsset(String path) => File('assets/data/v1/$path').readAsString();

/// 필터 바(카테고리 5개, 태그 칩이 많음)만으로도 기본 테스트 화면(600px)을
/// 다 채워 편성 슬롯/팀 태그 패널이 뷰포트+캐시 범위 밖이라 아예 안 빌드되던
/// 문제 -- 실기에서도 스크롤해야 보이는 건 같지만, 테스트는 스크롤 대신
/// 화면을 넉넉하게 키워 전부 한 번에 보이게 한다.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// 슬롯을 탭해 인라인 선택 패널을 열고, 특정 캐릭터 칩을 눌러 배정한다.
Future<void> _assign(WidgetTester tester, int slotIndex, String characterId) async {
  await tester.tap(find.byKey(ValueKey('formation_slot_$slotIndex')));
  await tester.pump();
  await tester.tap(find.byKey(ValueKey('pick_$characterId')));
  await tester.pump();
}

void main() {
  // 실제 디스크 영속성(Hive)은 test/data/local/hive_persistence_test.dart가
  // 이미 검증했다 — 여기서는 인메모리 가짜 저장소로 화면의 상호작용
  // 로직(즉시 갱신, 필터 독립성, 프리셋 적용)만 확인한다. 실제 Hive Box를
  // 위젯 이벤트 핸들러 안에서 직접 건드리면(테스트 하네스에서) box.flush()/
  // close()가 영영 안 끝나는 문제를 겪어서(원인 미확인, 환경 특이적으로
  // 보임) 이 접근으로 우회했다.
  late Datapack datapack;
  late TagBundle tagBundle;

  setUpAll(() async {
    datapack = await DatapackLoader(_readAsset).load();
    tagBundle = await loadTagBundle(_readAsset);
  });

  testWidgets('an empty formation already hints at the first animal tier (level 0, 3 needed)', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      MaterialApp(home: FormationScreen(datapack: datapack, tagBundle: tagBundle, repository: InMemoryFormationStore())),
    );

    expect(find.text('○ TAG_RACE_ANIMAL Lv3 (TAG_RACE_ANIMAL 3 더 필요)'), findsOneWidget);
    expect(find.byKey(const ValueKey('team_tag_TAG_RACE_ANIMAL')), findsNothing); // 아직 레벨 0(기여 없음)
  });

  testWidgets('assigning an animal-tagged character updates the team tag panel immediately', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      MaterialApp(home: FormationScreen(datapack: datapack, tagBundle: tagBundle, repository: InMemoryFormationStore())),
    );

    await _assign(tester, 0, 'CHR_BEAR'); // TAG_RACE_ANIMAL:1

    expect(find.text('TAG_RACE_ANIMAL Lv1'), findsOneWidget);
    expect(find.text('○ TAG_RACE_ANIMAL Lv3 (TAG_RACE_ANIMAL 2 더 필요)'), findsOneWidget);
  });

  testWidgets('adding a second animal-tagged character raises the level again, immediately', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      MaterialApp(home: FormationScreen(datapack: datapack, tagBundle: tagBundle, repository: InMemoryFormationStore())),
    );

    await _assign(tester, 0, 'CHR_BEAR');
    await _assign(tester, 1, 'CHR_BIRD'); // 둘 다 TAG_RACE_ANIMAL:1

    expect(find.text('TAG_RACE_ANIMAL Lv2'), findsOneWidget);
    expect(find.text('○ TAG_RACE_ANIMAL Lv3 (TAG_RACE_ANIMAL 1 더 필요)'), findsOneWidget);
  });

  testWidgets('the role filter narrows the picker to defenders only', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      MaterialApp(home: FormationScreen(datapack: datapack, tagBundle: tagBundle, repository: InMemoryFormationStore())),
    );

    await tester.tap(find.byKey(const ValueKey('filter_역할_ROLE_DEFENDER')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('formation_slot_0')));
    await tester.pump();

    expect(find.byKey(const ValueKey('pick_CHR_ACORN')), findsOneWidget); // 방어형
    expect(find.byKey(const ValueKey('pick_CHR_DROPLET')), findsNothing); // 공격형 -> 안 보임
  });

  testWidgets('the damage-type filter is independent of the role filter (both apply, AND)', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      MaterialApp(home: FormationScreen(datapack: datapack, tagBundle: tagBundle, repository: InMemoryFormationStore())),
    );

    await tester.tap(find.byKey(const ValueKey('filter_역할_ROLE_DEFENDER')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('filter_물리·마법_MAGICAL')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('formation_slot_0')));
    await tester.pump();

    // 방어형(도토리=물리) AND 마법 -> 둘 다 만족하는 캐릭터가 없어야 정상.
    expect(find.byKey(const ValueKey('pick_CHR_ACORN')), findsNothing);
    expect(find.byKey(const ValueKey('pick_CHR_DROPLET')), findsNothing);
  });

  testWidgets('applying a preset immediately reassigns the slots and refreshes the team tag panel', (tester) async {
    _useTallSurface(tester);
    final store = InMemoryFormationStore()..savePreset(0, ['CHR_BEAR', 'CHR_BIRD']);

    await tester.pumpWidget(
      MaterialApp(home: FormationScreen(datapack: datapack, tagBundle: tagBundle, repository: store)),
    );
    expect(find.textContaining('chr.bear'), findsNothing); // 아직 적용 전

    await tester.tap(find.byKey(const ValueKey('preset_apply_0')));
    await tester.pump();

    expect(find.textContaining('chr.bear'), findsOneWidget);
    expect(find.text('TAG_RACE_ANIMAL Lv2'), findsOneWidget); // 곰+새 -> 즉시 갱신
  });

  testWidgets('saving a preset stores exactly the current slots', (tester) async {
    _useTallSurface(tester);
    final store = InMemoryFormationStore();

    await tester.pumpWidget(
      MaterialApp(home: FormationScreen(datapack: datapack, tagBundle: tagBundle, repository: store)),
    );

    await _assign(tester, 0, 'CHR_BEAR');
    await tester.tap(find.byKey(const ValueKey('preset_save_0')));
    await tester.pump();

    expect(store.preset(0).first, 'CHR_BEAR');
  });

  /// 10_WIRING_PLAN.md "편성 서버 동기화": startBattle이 실제로 읽는 건
  /// 서버 문서라, 로컬 편집을 서버에도 반영해야 실제 출격이 막히지 않는다.
  group('onSyncFormation (서버 동기화)', () {
    testWidgets('assigning a character syncs preset 0 with the new slots', (tester) async {
      _useTallSurface(tester);
      final synced = <(int, List<String?>)>[];
      await tester.pumpWidget(
        MaterialApp(
          home: FormationScreen(
            datapack: datapack,
            tagBundle: tagBundle,
            repository: InMemoryFormationStore(),
            onSyncFormation: (index, slots) => synced.add((index, slots)),
          ),
        ),
      );

      await _assign(tester, 0, 'CHR_BEAR');

      expect(synced, hasLength(1));
      expect(synced.single.$1, 0);
      expect(synced.single.$2[0], 'CHR_BEAR');
    });

    testWidgets('applying a preset syncs preset 0 with that preset\'s slots', (tester) async {
      _useTallSurface(tester);
      final store = InMemoryFormationStore()..savePreset(1, ['CHR_BEAR', 'CHR_BIRD']);
      final synced = <(int, List<String?>)>[];

      await tester.pumpWidget(
        MaterialApp(
          home: FormationScreen(
            datapack: datapack,
            tagBundle: tagBundle,
            repository: store,
            onSyncFormation: (index, slots) => synced.add((index, slots)),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('preset_apply_1')));
      await tester.pump();

      expect(synced, hasLength(1));
      expect(synced.single.$1, 0); // 프리셋 1을 적용했어도 동기화 대상은 활성 편성(0)
      expect(synced.single.$2[0], 'CHR_BEAR');
    });

    testWidgets('saving preset 2 syncs preset 2, not preset 0', (tester) async {
      _useTallSurface(tester);
      final synced = <(int, List<String?>)>[];
      await tester.pumpWidget(
        MaterialApp(
          home: FormationScreen(
            datapack: datapack,
            tagBundle: tagBundle,
            repository: InMemoryFormationStore(),
            onSyncFormation: (index, slots) => synced.add((index, slots)),
          ),
        ),
      );

      await _assign(tester, 0, 'CHR_BEAR'); // synced[0] = (0, ...)
      await tester.tap(find.byKey(const ValueKey('preset_save_2')));
      await tester.pump();

      expect(synced.last.$1, 2);
      expect(synced.last.$2[0], 'CHR_BEAR');
    });
  });
}
