import '../constants.dart';
import '../defs/weather_config.dart';
import '../heal/heal_budget.dart';
import '../stat/modifier.dart';
import '../stat/modifier_source.dart';
import '../stat/stat_key.dart';
import '../tag/tag_query.dart' show Side;
import '../world/battle_world.dart';
import '../world/weather_state.dart';
import 'battle_system.dart';

const _weatherModifierSource = ModifierSource(ModifierKind.weather, 'WEATHER');

/// 03_BATTLE_ENGINE.md §9. 매 틱 실행되지만 실제 게이지/상태 갱신은
/// `sampleTicks`(기본 60틱=2초)마다만 일어난다 — "활약" 기록 자체는
/// AttackSystem/DamageSystem/HealHandler/StatBuffHandler가 그 즉시
/// `BattleWorld.recordWeatherActivity()`를 불러 채워두므로, 여기서는
/// 주기적으로 집계·정리만 한다.
class WeatherSystem implements BattleSystem {
  @override
  void execute(BattleWorld w) {
    if (w.tick % ticksPerSec == 0) {
      _resetHealBudget(w);
      _applyWeatherHot(w);
    }

    final cfg = w.config.weatherConfig;
    if (w.tick % cfg.sampleTicks != 0 || w.tick == 0) return;

    final ns = w.activeSunKinds.length.clamp(0, cfg.maxKindsPerTemper);
    final nm = w.activeMoonKinds.length.clamp(0, cfg.maxKindsPerTemper);
    final nf = w.activeFieldKinds.length.clamp(0, cfg.maxKindsPerTemper);

    final b = (cfg.biasFactor * (ns - nm)).clamp(-cfg.biasClamp, cfg.biasClamp);
    final t = (w.weatherGauge + b).clamp(cfg.gaugeMin, cfg.gaugeMax);
    final decayed = t.abs() - cfg.fieldDecayFactor * nf;
    w.weatherGauge = t.sign * (decayed < 0 ? 0 : decayed);

    _applyStageBias(w);

    final previous = w.weather;
    _updateState(w, cfg);
    if (w.weather != previous) _refreshWeatherModifiers(w, cfg);

    _clearActivity(w);
  }

  void _applyStageBias(BattleWorld w) {
    final bias = w.config.stageWeatherBias;
    if (bias == 0) return;
    final cfg = w.config.weatherConfig;
    w.weatherGauge = (w.weatherGauge + bias).clamp(cfg.gaugeMin, cfg.gaugeMax);
  }

  /// 히스테리시스: 상태별로 "들어오는" 문턱과 "나가는" 문턱이 다르다 —
  /// 경계값 근처에서 게이지가 오르내려도 상태가 팔딱거리지 않는다.
  void _updateState(BattleWorld w, WeatherConfig cfg) {
    final g = w.weatherGauge;
    switch (w.weather) {
      case WeatherState.dusk:
        if (g >= cfg.toClear) {
          w.weather = WeatherState.clear;
        } else if (g <= cfg.toNight) {
          w.weather = WeatherState.night;
        }
      case WeatherState.clear:
        if (g <= cfg.toNight) {
          w.weather = WeatherState.night;
        } else if (g < cfg.clearExit) {
          w.weather = WeatherState.dusk;
        }
      case WeatherState.night:
        if (g >= cfg.toClear) {
          w.weather = WeatherState.clear;
        } else if (g > cfg.nightExit) {
          w.weather = WeatherState.dusk;
        }
    }
  }

  /// 03_BATTLE_ENGINE.md §9.2: "날씨 모디파이어는 ModifierKind.weather로
  /// 태깅 → 상태 전이 시 removeBySource 후 재부여". 적/기지/필살기/고정
  /// 자기비용은 강화하지 않는다 — 아군 엔티티에만 건다.
  void _refreshWeatherModifiers(BattleWorld w, WeatherConfig cfg) {
    final effect = cfg.effectOf(w.weather);
    for (final e in w.entities.ordered) {
      if (e.side != Side.ally) continue;
      e.stats.removeBySource(ModifierKind.weather, 'WEATHER');
      if (effect.allyAtkPct != 0) {
        e.stats.addModifier(
          StatModifier(stat: StatKey.atk, op: ModOp.pctAdd, value: effect.allyAtkPct, source: _weatherModifierSource),
        );
      }
      if (effect.allyHealPct != 0) {
        e.stats.addModifier(
          StatModifier(
            stat: StatKey.healReceived,
            op: ModOp.pctAdd,
            value: effect.allyHealPct,
            source: _weatherModifierSource,
          ),
        );
      }
    }
    w.weatherRegenPct = pctScale + effect.prayerRegenPct;
  }

  void _resetHealBudget(BattleWorld w) {
    for (final e in w.entities.ordered) {
      e.healBudgetUsedPctThisSecond = 0;
    }
  }

  void _applyWeatherHot(BattleWorld w) {
    final effect = w.config.weatherConfig.effectOf(w.weather);
    if (effect.hotPctPerSec <= 0) return;
    for (final e in w.entities.ordered) {
      if (e.side != Side.ally || !e.isAlive) continue;
      final granted = grantFromHealBudget(e, effect.hotPctPerSec, w.config.weatherConfig.healCapPctPerSec);
      if (granted <= 0) continue;
      final maxHp = e.stats.get(StatKey.maxHp);
      var next = e.hp + maxHp * granted ~/ pctScale;
      if (next > maxHp) next = maxHp;
      e.hp = next;
    }
  }

  void _clearActivity(BattleWorld w) {
    w.activeSunKinds.clear();
    w.activeMoonKinds.clear();
    w.activeFieldKinds.clear();
  }
}
