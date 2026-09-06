import '../defs/stage_def.dart';
import '../defs/unit_def.dart';
import '../defs/weather_config.dart';
import '../skill/skill_trigger_def.dart';
import '../tag/tag_effect_def.dart';
import '../tag/tag_registry.dart';
import '../tag/tag_relation_rule.dart';

/// `BattleWorld`를 세우는 데 필요한 최소 구성.
///
/// `allyBaseHp`(모닥불 체력)와 집중력(focus*) 수치는 stage가 아니라 계정의
/// 캠프/집중력 성장치에서 오므로(growth.json, T-30) `StageDef`에 넣지 않고
/// 여기서 따로 받는다. 기본값은 growth.json §9의 집중력 Lv1 keyframe
/// (regenPerSec 18, cap 1000, startAmount 200)과 focusBoost 표를 그대로 옮긴
/// 것 — T-30이 실제 계정 레벨로 이 값들을 채워 넣기 전까지의 자리 표시자.
class BattleConfig {
  const BattleConfig({
    required this.stage,
    required this.allyBaseHp,
    this.formation = const [],
    this.focusBaseRegen = 18,
    this.focusBaseCap = 1000,
    this.startingPrayerPower = 200,
    this.focusBoostBonus = const [0, 7, 14],
    this.focusBoostCap = const [0, 300, 600],
    this.focusBoostCost = const [0, 150, 250],
    this.tagRegistry,
    this.tagEffects = const [],
    this.relationRules = const [],
    this.skillDefs = const {},
    this.weatherConfig = const WeatherConfig(),
    this.stageWeatherBias = 0,
  });

  final StageDef stage;
  final int allyBaseHp;

  /// 소환 가능한 편성 슬롯의 정적 정의(순서 = 슬롯 index).
  final List<UnitDef> formation;

  /// null이면 `BattleWorld`가 빈 레지스트리로 대체한다 (39종 태그 로딩은
  /// T-05 스코프라 여기선 강제하지 않음 — 태그를 안 쓰는 테스트는 그대로 둔다).
  final TagRegistry? tagRegistry;
  final List<TagEffectDef> tagEffects;
  final List<TagRelationRule> relationRules;

  /// 스킬 id -> 정의. 점 조회만 하고 순회하지 않는다.
  final Map<String, SkillTriggerDef> skillDefs;

  final int focusBaseRegen; // 초당 회복(집중력 레벨 기본)
  final int focusBaseCap;
  final int startingPrayerPower;

  /// index = focusBoostStage(0=미사용).
  final List<int> focusBoostBonus;
  final List<int> focusBoostCap;
  final List<int> focusBoostCost;

  /// 03_BATTLE_ENGINE.md §9 WeatherSystem(T-45).
  final WeatherConfig weatherConfig;

  /// §9 "스테이지 편향 기믹" — 던전 WEATHER_BIAS(07_DUNGEON_EXCHANGE.md §3.1
  /// `gimmick.biasPerSample`)가 있으면 여기 채워 넣는다. 기본 0 = 편향 없음.
  final int stageWeatherBias;
}
