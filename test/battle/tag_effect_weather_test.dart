import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/stat/modifier.dart';
import 'package:wse_defense/battle/stat/stat_key.dart';
import 'package:wse_defense/battle/system/battle_system.dart';
import 'package:wse_defense/battle/system/weather_system.dart';
import 'package:wse_defense/battle/tag/tag_def.dart';
import 'package:wse_defense/battle/tag/tag_effect_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/tag/tag_registry.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/battle/world/weather_state.dart';

UnitDef _unit(String id, {Map<String, int> intrinsicTags = const {}}) => UnitDef(
  id: id,
  intrinsicTags: intrinsicTags,
  base: UnitBaseStats(
    maxHp: 1000,
    atk: 100,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 100,
  ),
);

/// 04_DATA_SCHEMA.md §3 예시(TEF_NOCTURNAL_NIGHT)와 같은 모양 — "야행성은
/// 밤에만 ATK +10%".
TagEffectDef _nocturnalEffect(TagRegistry registry) => TagEffectDef(
  id: 'TEF_NOCTURNAL_NIGHT',
  tagIndex: registry.indexOf('TAG_HABIT_NOCTURNAL'),
  scope: TagScope.unit,
  mode: TagEffectMode.perLevel,
  perLevel: const [StatModDef(stat: StatKey.atk, op: ModOp.pctAdd, value: 10000)],
  requireWeather: const [WeatherState.night],
);

BattleWorld _newWorld({
  required TagRegistry registry,
  required List<TagEffectDef> effects,
  List<UnitDef> formation = const [],
  List<BattleSystem> systems = const [],
}) => BattleWorld(
  config: BattleConfig(
    stage: const StageDef(
      id: 'STG_TEST',
      index: 1,
      fieldLength: 2400,
      allyBaseX: 0,
      enemyBaseX: 2400,
      enemyBaseHp: 1000,
      timeLimitSec: 300,
    ),
    allyBaseHp: 10000,
    formation: formation,
    tagRegistry: registry,
    tagEffects: effects,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: systems,
)..phase = BattlePhase.running;

void main() {
  final registry = TagRegistry([const TagDef(id: 'TAG_HABIT_NOCTURNAL', category: TagCategory.habit)]);

  test('T-47: 야행성 유닛은 밤이 아니면 강화되지 않고, 밤이면 강화된다', () {
    final effects = [_nocturnalEffect(registry)];
    final w = _newWorld(registry: registry, effects: effects);
    final e = w.spawnEntity(_unit('CHR_OWL', intrinsicTags: {'TAG_HABIT_NOCTURNAL': 1}), Side.ally, 0);

    expect(w.weather, WeatherState.dusk); // 기본 상태(밤 아님)
    expect(e.stats.get(StatKey.atk), 100); // 강화 없음

    w.weather = WeatherState.night;
    w.tagEffectResolver.reapplyWeatherGatedEffects(w);
    expect(e.stats.get(StatKey.atk), 110); // +10%

    w.weather = WeatherState.dusk;
    w.tagEffectResolver.reapplyWeatherGatedEffects(w);
    expect(e.stats.get(StatKey.atk), 100); // 밤이 아니면 도로 해제
  });

  test('T-47: 상태 전이 시 모디파이어 정확히 교체 -- WeatherSystem이 실제로 전이할 때만 반영', () {
    final effects = [_nocturnalEffect(registry)];
    final owlDef = _unit('CHR_OWL', intrinsicTags: {'TAG_HABIT_NOCTURNAL': 1});
    final w = _newWorld(registry: registry, effects: effects, formation: [owlDef], systems: [WeatherSystem()]);
    final e = w.spawnEntity(owlDef, Side.ally, 0);

    // 밤에는 WeatherSystem 자체의 "아군 공격력 -10%" 모디파이어도 같이
    // 붙어(§9.2) 최종 ATK 수치만으로는 야행성 효과가 켜졌는지 가려낼 수
    // 없다(+10%와 -10%가 우연히 상쇄) — 그래서 이 테스트는 태그 효과가
    // 남긴 모디파이어 자체(source.id)의 존재로 직접 확인한다.
    bool hasNocturnalModifier() => e.stats.modifiers.any((m) => m.source.id == 'TEF_NOCTURNAL_NIGHT');

    expect(hasNocturnalModifier(), isFalse);

    // 게이지를 직접 밤(-60 이하)으로 몰아넣고, 실제 WeatherSystem 표본
    // 갱신(60틱마다)이 상태를 바꿀 때까지 진행한다.
    w.weatherGauge = -60;
    for (var i = 0; i < 61; i++) {
      w.step();
    }
    expect(w.weather, WeatherState.night);
    expect(hasNocturnalModifier(), isTrue); // 전이 시점에 정확히 켜짐

    // 다시 밤을 벗어나면(-40 초과) dusk로 전이하고, 모디파이어도 같이 꺼진다.
    w.weatherGauge = -30;
    for (var i = 0; i < 60; i++) {
      w.step();
    }
    expect(w.weather, WeatherState.dusk);
    expect(hasNocturnalModifier(), isFalse); // 정확히 꺼짐
  });
}
