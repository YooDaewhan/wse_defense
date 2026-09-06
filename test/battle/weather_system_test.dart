import 'package:flutter_test/flutter_test.dart';
import 'package:wse_defense/battle/defs/datapack.dart';
import 'package:wse_defense/battle/defs/stage_def.dart';
import 'package:wse_defense/battle/defs/unit_def.dart';
import 'package:wse_defense/battle/defs/weather_config.dart';
import 'package:wse_defense/battle/effect/effect_params.dart';
import 'package:wse_defense/battle/effect/effect_registry.dart';
import 'package:wse_defense/battle/stat/modifier_source.dart';
import 'package:wse_defense/battle/system/battle_system.dart';
import 'package:wse_defense/battle/system/status_system.dart';
import 'package:wse_defense/battle/system/weather_system.dart';
import 'package:wse_defense/battle/tag/tag_def.dart';
import 'package:wse_defense/battle/tag/tag_query.dart';
import 'package:wse_defense/battle/tag/tag_registry.dart';
import 'package:wse_defense/battle/world/battle_config.dart';
import 'package:wse_defense/battle/world/battle_world.dart';
import 'package:wse_defense/battle/world/canonical_systems.dart';
import 'package:wse_defense/battle/world/weather_state.dart';

UnitDef _unit(String id, {Map<String, int> intrinsicTags = const {}, int maxHp = 1000}) => UnitDef(
  id: id,
  intrinsicTags: intrinsicTags,
  base: UnitBaseStats(
    maxHp: maxHp,
    atk: 100,
    attackPeriod: 60,
    attackWindup: 12,
    attackRecover: 48,
    attackRange: 100,
    moveSpeed: 0,
  ),
);

BattleWorld _newWorld({
  required TagRegistry registry,
  List<UnitDef> formation = const [],
  WeatherConfig weatherConfig = const WeatherConfig(),
  required List<BattleSystem> systems,
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
    weatherConfig: weatherConfig,
  ),
  rngSeed: 1,
  datapack: const Datapack(characters: {}, enemies: {}, stages: {}),
  systems: systems,
)..phase = BattlePhase.running;

final _temperRegistry = TagRegistry([
  const TagDef(id: 'TAG_TEMPER_SUN', category: TagCategory.temper),
  const TagDef(id: 'TAG_TEMPER_MOON', category: TagCategory.temper),
  const TagDef(id: 'TAG_TEMPER_FIELD', category: TagCategory.temper),
]);

void main() {
  test('활약 판정: 같은 종류(슬롯) 20번 활동해도 카운트는 1 (§9.1)', () {
    final sun = _unit('T_SUN', intrinsicTags: {'TAG_TEMPER_SUN': 1});
    final w = _newWorld(registry: _temperRegistry, formation: [sun], systems: [WeatherSystem()]);

    for (var i = 0; i < 20; i++) {
      final e = w.spawnEntity(sun, Side.ally, 0);
      w.recordWeatherActivity(e);
    }

    expect(w.activeSunKinds, [0]);
  });

  test('B=clamp(6(Ns-Nm), ±12), G\'=sign(T)*max(0,|T|-4Nf) 공식 그대로', () {
    final sun1 = _unit('T_SUN1', intrinsicTags: {'TAG_TEMPER_SUN': 1});
    final sun2 = _unit('T_SUN2', intrinsicTags: {'TAG_TEMPER_SUN': 1});
    final w = _newWorld(registry: _temperRegistry, formation: [sun1, sun2], systems: [WeatherSystem()]);

    final e1 = w.spawnEntity(sun1, Side.ally, 0);
    final e2 = w.spawnEntity(sun2, Side.ally, 0);
    w.recordWeatherActivity(e1);
    w.recordWeatherActivity(e2);
    // ns=2, nm=0 -> B=12(상한). T=0+12=12. nf=0 -> decayed=12. gauge=+12.
    // tick==0인 샘플은 건너뛰므로(첫 샘플이 스퓨리어스하지 않도록) 실제
    // 첫 표본은 tick=60에서 일어난다 -> 61번째 step()에서 처리된다.
    for (var i = 0; i < 61; i++) {
      w.step();
    }
    expect(w.weatherGauge, 12);
  });

  test('필드(들) 기질 활동이 게이지 절대값을 깎는다(fieldDecayFactor)', () {
    final sun1 = _unit('T_SUN1', intrinsicTags: {'TAG_TEMPER_SUN': 1});
    final field1 = _unit('T_FIELD1', intrinsicTags: {'TAG_TEMPER_FIELD': 1});
    final w = _newWorld(registry: _temperRegistry, formation: [sun1, field1], systems: [WeatherSystem()]);

    final eSun = w.spawnEntity(sun1, Side.ally, 0);
    final eField = w.spawnEntity(field1, Side.ally, 0);
    w.recordWeatherActivity(eSun);
    w.recordWeatherActivity(eField);
    // ns=1, nm=0 -> B=6. T=0+6=6. nf=1 -> decayed=6-4=2. gauge=+2.
    for (var i = 0; i < 61; i++) {
      w.step();
    }
    expect(w.weatherGauge, 2);
  });

  test('히스테리시스: 경계 근처에서 게이지가 오르내려도 상태가 팔딱거리지 않는다', () {
    final w = _newWorld(registry: _temperRegistry, systems: [WeatherSystem()]);

    w.weather = WeatherState.clear;
    w.weatherGauge = 45;
    // tick==0 샘플은 건너뛰므로 첫 실제 표본은 tick=60(61번째 step)에서.
    for (var i = 0; i < 61; i++) {
      w.step();
    }
    expect(w.weather, WeatherState.clear); // clearExit(40) 안 넘음 -> 유지

    w.weatherGauge = 39;
    for (var i = 0; i < 60; i++) {
      w.step();
    }
    expect(w.weather, WeatherState.dusk); // 39<40 -> 이탈

    // DUSK에서 45로 되돌아가도(단순 문턱 40이었다면 CLEAR로 복귀했을 값)
    // DUSK -> CLEAR는 toClear(60)를 넘어야 하므로 그대로 DUSK에 머문다.
    w.weatherGauge = 45;
    for (var i = 0; i < 60; i++) {
      w.step();
    }
    expect(w.weather, WeatherState.dusk);
  });

  test('회복 총량 상한 2%/초: 날씨(밤) 회복 + 토닥임 합산도 상한을 넘지 않는다', () {
    EffectRegistry.reset();
    registerAllEffects();

    final w = _newWorld(
      registry: _temperRegistry,
      systems: [WeatherSystem(), const StatusSystem()],
    );
    w.weather = WeatherState.night; // hotPctPerSec=250(0.25%)
    // maxHp를 10000으로 잡아 퍼센트가 정수로 딱 나누어떨어지게 한다
    // (밀리퍼센트 계산의 절삭 오차로 기대값이 흔들리지 않도록).
    final e = w.spawnEntity(_unit('T_ALLY', maxHp: 10000), Side.ally, 0);
    e.hp = 5000;

    // 매초(30틱)마다 5%(요청)를 회복하려는 토닥임 -- 밤 회복(0.25%)과 합쳐
    // 2%(상한) 넘게 요청하지만 실제로는 2%만 반영돼야 한다.
    EffectRegistry.of('HEAL')!.apply(
      w,
      e,
      const EffectParams(pctOfMaxHp: 5000, intervalTicks: 30, durationTicks: 30 * 100),
      const ModifierSource(ModifierKind.skill, 'SKL_TEST_HOT'),
    );

    for (var i = 0; i < 30; i++) {
      w.step();
    }

    expect(e.hp, 5000 + 200); // maxHp(10000) * healCapPctPerSec(2%) = 200
  });

  test('시스템 리스트에서 빼면 M1 동작과 완전히 동일', () {
    final withoutWeather = canonicalBattleSystems(includeWeather: false);
    expect(withoutWeather.any((s) => s is WeatherSystem), isFalse);
    expect(withoutWeather.length, canonicalBattleSystems().length - 1);
    expect(
      withoutWeather.map((s) => s.runtimeType).toList(),
      [
        for (final s in canonicalBattleSystems())
          if (s is! WeatherSystem) s.runtimeType,
      ],
    );
  });
}
