import '../constants.dart';
import '../defs/datapack.dart';
import '../defs/unit_def.dart';
import '../entity/base_entity.dart';
import '../entity/battle_entity.dart';
import '../entity/entity_store.dart';
import '../event/battle_event.dart';
import '../rng/deterministic_rng.dart';
import '../skill/skill_trigger_runner.dart';
import '../system/battle_system.dart';
import '../system/pending_damage.dart';
import '../tag/tag_contribution.dart';
import '../tag/tag_effect_resolver.dart';
import '../tag/tag_query.dart';
import '../tag/tag_registry.dart';
import '../tag/tag_stack.dart';
import 'battle_config.dart';
import 'battle_input.dart';
import 'formation_slot.dart';
import 'spawn_runtime.dart';
import 'weather_state.dart';

enum BattlePhase { ready, running, finished }

enum BattleOutcome { allyWin, enemyWin, draw, timeout }

/// 03_BATTLE_ENGINE.md §1 최상위 인터페이스의 뼈대.
///
/// 아직 스킵한 것: `weather`(T-45), `events`(태울 시스템이 없어 아직 필요
/// 없음), `snapshot()`(T-22), `serialize()/deserialize()`(T-20). 지금
/// 만들어봐야 아무도 채우지 않는 필드라 해당 티켓에서 추가한다.
class BattleWorld {
  BattleWorld({
    required this.config,
    required int rngSeed,
    required this.datapack,
    this.systems = const [],
  }) : rng = DeterministicRng(rngSeed),
       formation = [for (final def in config.formation) FormationSlot(def)],
       waveStates = [
         for (final w in config.stage.waves) WaveRuntimeState(w),
       ],
       bossTriggers = [
         for (final b in config.stage.bossTriggers) BossTriggerRuntime(b),
       ],
       prayerPower = config.startingPrayerPower,
       ultimateGauge = ultGaugeMax ~/ 2,
       weatherGauge = config.weatherConfig.gaugeStart,
       tagRegistry = config.tagRegistry ?? TagRegistry(const []) {
    // 좌표는 고정소수점(POS_SCALE)로 저장한다 (01_ARCHITECTURE.md §3.1).
    allyBase = BaseEntity(
      side: Side.ally,
      x: config.stage.allyBaseX * posScale,
      maxHp: config.allyBaseHp,
    );
    enemyBase = BaseEntity(
      side: Side.enemy,
      x: config.stage.enemyBaseX * posScale,
      maxHp: config.stage.enemyBaseHp,
    );
    tagEffectResolver.resolveFormation(this); // 02_TAG_SYSTEM.md §8: 전투 시작 시 1회
  }

  final BattleConfig config;
  final Datapack datapack;
  final DeterministicRng rng;
  final List<BattleSystem> systems; // ★ 실행 순서 = 03_BATTLE_ENGINE.md §3

  int tick = 0;
  BattlePhase phase = BattlePhase.ready;
  BattleOutcome? outcome;

  // 엔티티 저장소 — entityId 오름차순 정렬 유지
  final EntityStore entities = EntityStore();
  late final BaseEntity allyBase; // 모닥불
  late final BaseEntity enemyBase; // 둥지
  int _nextEntityId = 0;

  int prayerPower; // 현재 기도력 (밀리 단위 아님, 정수)
  int prayerPowerFrac = 0; // 초당 회복의 틱 나머지 누적
  int focusBoostStage = 0;
  int ultimateGauge; // 0..ultGaugeMax
  int ultimateStock = 0;
  int weatherRegenPct = pctScale; // WeatherSystem(T-45)이 매 샘플마다 갱신

  /// 03_BATTLE_ENGINE.md §9 WeatherSystem(T-45). `weatherGauge`는 기본값이
  /// config에서 오므로(gaugeStart) 필드 자체엔 기본값을 두지 않고 생성자
  /// 초기화 리스트에서만 채운다.
  WeatherState weather = WeatherState.dusk;
  int weatherGauge;
  final List<int> activeSunKinds = [];
  final List<int> activeMoonKinds = [];
  final List<int> activeFieldKinds = [];

  final List<FormationSlot> formation;
  final List<WaveRuntimeState> waveStates;
  final List<BossTriggerRuntime> bossTriggers;

  final TagRegistry tagRegistry;
  late final TagEffectResolver tagEffectResolver = TagEffectResolver(
    tagRegistry,
    config.tagEffects,
  );

  /// §2.2: 전투 시작 시 1회 계산되고 이후 절대 변하지 않는다.
  TagStack formationTagLevel = TagStack();

  /// §2: 2초마다 재계산되는, 그 순간 살아있는 같은 편 유닛 기준 태그 레벨.
  TagStack allyFieldTagLevel = TagStack();
  TagStack enemyFieldTagLevel = TagStack();

  /// 이번 틱에 큐잉된 피해. DamageSystem이 매 틱 소비 후 비운다.
  final List<PendingDamage> pendingDamage = [];

  /// §13: 순수 알림 버퍼 — 어떤 시스템도 이 리스트를 읽지 않고 추가만 한다.
  /// `EventFlushSystem`이 틱 끝에서 비운다. 렌더가 그 전에 [drainEvents]로
  /// 먼저 가져가도 되고, 아예 안 가져가도(구독 없음) 시뮬 결과는 같다.
  final List<BattleEvent> events = [];

  /// 지금까지 쌓인 이벤트를 전부 꺼내고 비운다.
  List<BattleEvent> drainEvents() {
    if (events.isEmpty) return const [];
    final drained = List<BattleEvent>.of(events);
    events.clear();
    return drained;
  }

  final InputQueue inputs = InputQueue();
  void enqueueInput(BattleInput input) => inputs.add(tick, input);

  int get currentPrayerCap =>
      config.focusBaseCap + config.focusBoostCap[focusBoostStage];

  int get allyAliveCount => _aliveCount(Side.ally);
  int get enemyAliveCount => _aliveCount(Side.enemy);

  int _aliveCount(Side side) {
    var count = 0;
    for (final e in entities.ordered) {
      if (e.side == side && e.isAlive) count++;
    }
    return count;
  }

  /// 새 엔티티를 만들어 등록하고 돌려준다. id는 스폰 순서대로 단조 증가.
  /// intrinsicTags를 태그 스택으로 구성하고 태그 효과까지 적용한다
  /// (§8 resolveUnitOnSpawn). 장비 grantTags는 아직 없다(T-39/T-44 스코프).
  BattleEntity spawnEntity(UnitDef def, Side side, int x) {
    final e = BattleEntity(
      id: _nextEntityId++,
      side: side,
      def: def,
      spawnTick: tick,
      x: x,
    );
    for (final entry in def.intrinsicTags.entries) {
      final idx = tagRegistry.indexOf(entry.key);
      if (idx == -1) continue; // 존재하지 않는 태그 참조 -> 무시
      e.tagContribs.add(
        TagContribution(
          tagIndex: idx,
          amount: entry.value,
          kind: TagSourceKind.intrinsic,
          sourceId: def.id,
        ),
      );
    }
    tagEffectResolver.resolveUnitOnSpawn(e, this);
    entities.add(e);
    SkillTriggerRunner.onSpawn(this, e);
    return e;
  }

  /// 전장 경계 (고정소수점). 양쪽 진영 모두 같은 필드 안에서 움직이므로
  /// side별로 달라질 이유가 아직 없다 — 필요해지면(스테이지별 제한 등) 여기서 분기.
  int minX(Side side) => 0;
  int maxX(Side side) => config.stage.fieldLength * posScale;

  int? _sunTagIndex;
  int? _moonTagIndex;
  int? _fieldTagIndex;

  /// 03_BATTLE_ENGINE.md §9.1 "활약" 판정. 아군만 집계한다(날씨는 플레이어
  /// 기질 시스템이라 적/기지는 대상 밖) — "종류"는 편성 슬롯 인덱스로
  /// 식별한다(같은 슬롯에서 여러 번 재소환해도 하나의 종류).
  void recordWeatherActivity(BattleEntity e) {
    if (e.side != Side.ally) return;
    final slotIndex = config.formation.indexWhere((d) => d.id == e.def.id);
    if (slotIndex == -1) return;

    _sunTagIndex ??= tagRegistry.indexOf('TAG_TEMPER_SUN');
    _moonTagIndex ??= tagRegistry.indexOf('TAG_TEMPER_MOON');
    _fieldTagIndex ??= tagRegistry.indexOf('TAG_TEMPER_FIELD');

    if (_sunTagIndex! != -1 && e.tags.levelOf(_sunTagIndex!) > 0) {
      _insertSortedUnique(activeSunKinds, slotIndex);
    }
    if (_moonTagIndex! != -1 && e.tags.levelOf(_moonTagIndex!) > 0) {
      _insertSortedUnique(activeMoonKinds, slotIndex);
    }
    if (_fieldTagIndex! != -1 && e.tags.levelOf(_fieldTagIndex!) > 0) {
      _insertSortedUnique(activeFieldKinds, slotIndex);
    }
  }

  /// 정확히 1틱 진행. 외부에서 이것만 호출한다.
  void step() {
    if (phase != BattlePhase.running) return;
    for (final s in systems) {
      s.execute(this);
    }
    tick++;
  }

  /// 결정론 검증용. hashCode(플랫폼/실행마다 다를 수 있음)는 쓰지 않고
  /// FNV-1a를 32비트로 직접 굴려 VM/dart2js 어디서든 동일한 값이 나오게 한다.
  /// 03_BATTLE_ENGINE.md §14 직렬화(T-20). `config`/`datapack`/`systems`는
  /// 여기 담지 않는다 — 리플레이는 항상 그것들을 그대로 다시 넘겨 새
  /// `BattleWorld`를 만들고 그 위에 이 상태를 얹는 방식이라(§14 "리플레이 =
  /// BattleWorld(config, seed) 새로 만들고 재생"), 정적 구성까지 중복 저장할
  /// 이유가 없다. `inputs`/`pendingDamage`는 정의상 한 틱 처리 안에서만
  /// 채워졌다 비워지므로(§1 enqueueInput 문서, DamageSystem 문서) 틱 경계에서
  /// 호출되는 이 메서드 시점엔 항상 비어 있다 — 그래도 만약을 위해 그대로
  /// 저장/복원한다.
  Map<String, Object?> serialize() => {
    'tick': tick,
    'phase': phase.index,
    'outcome': outcome?.index,
    'nextEntityId': _nextEntityId,
    'allyBaseHp': allyBase.hp,
    'allyBaseDestroyed': allyBase.destroyed,
    'allyBaseDamageImmune': allyBase.damageImmune,
    'enemyBaseHp': enemyBase.hp,
    'enemyBaseDestroyed': enemyBase.destroyed,
    'enemyBaseDamageImmune': enemyBase.damageImmune,
    'prayerPower': prayerPower,
    'prayerPowerFrac': prayerPowerFrac,
    'focusBoostStage': focusBoostStage,
    'ultimateGauge': ultimateGauge,
    'ultimateStock': ultimateStock,
    'weatherRegenPct': weatherRegenPct,
    'weather': weather.index,
    'weatherGauge': weatherGauge,
    'activeSunKinds': activeSunKinds,
    'activeMoonKinds': activeMoonKinds,
    'activeFieldKinds': activeFieldKinds,
    'rng': rng.exportState(),
    'formationCooldowns': [for (final s in formation) s.cooldownLeft],
    'waveSpawnedCounts': [for (final w in waveStates) w.spawnedCount],
    'bossTriggers': [
      for (final b in bossTriggers)
        {'state': b.state.index, 'warningTicksLeft': b.warningTicksLeft},
    ],
    'formationTagLevel': _tagStackToJson(formationTagLevel),
    'allyFieldTagLevel': _tagStackToJson(allyFieldTagLevel),
    'enemyFieldTagLevel': _tagStackToJson(enemyFieldTagLevel),
    'pendingDamage': [for (final p in pendingDamage) _pendingDamageToJson(p)],
    'entities': [for (final e in entities.ordered) e.serialize()],
  };

  /// [serialize]의 역. `config`/`datapack`/`systems`는 호출부가 원본과
  /// 동일한 값을 다시 넘긴다(리플레이 원칙, 위 주석 참고).
  static BattleWorld deserialize(
    Map<String, Object?> data, {
    required BattleConfig config,
    required Datapack datapack,
    required int rngSeed,
    List<BattleSystem> systems = const [],
  }) {
    final w = BattleWorld(
      config: config,
      rngSeed: rngSeed,
      datapack: datapack,
      systems: systems,
    );
    w.tick = data['tick'] as int;
    w.phase = BattlePhase.values[data['phase'] as int];
    final outcomeIdx = data['outcome'] as int?;
    w.outcome = outcomeIdx == null ? null : BattleOutcome.values[outcomeIdx];
    w._nextEntityId = data['nextEntityId'] as int;
    w.allyBase.hp = data['allyBaseHp'] as int;
    w.allyBase.destroyed = data['allyBaseDestroyed'] as bool;
    w.allyBase.damageImmune = data['allyBaseDamageImmune'] as bool;
    w.enemyBase.hp = data['enemyBaseHp'] as int;
    w.enemyBase.destroyed = data['enemyBaseDestroyed'] as bool;
    w.enemyBase.damageImmune = data['enemyBaseDamageImmune'] as bool;
    w.prayerPower = data['prayerPower'] as int;
    w.prayerPowerFrac = data['prayerPowerFrac'] as int;
    w.focusBoostStage = data['focusBoostStage'] as int;
    w.ultimateGauge = data['ultimateGauge'] as int;
    w.ultimateStock = data['ultimateStock'] as int;
    w.weatherRegenPct = data['weatherRegenPct'] as int;
    w.weather = WeatherState.values[data['weather'] as int];
    w.weatherGauge = data['weatherGauge'] as int;
    w.activeSunKinds.addAll([for (final v in data['activeSunKinds'] as List<Object?>) v as int]);
    w.activeMoonKinds.addAll([for (final v in data['activeMoonKinds'] as List<Object?>) v as int]);
    w.activeFieldKinds.addAll([for (final v in data['activeFieldKinds'] as List<Object?>) v as int]);
    w.rng.restoreState(data['rng'] as Map<String, Object?>);

    final formationCooldowns = data['formationCooldowns'] as List<Object?>;
    for (var i = 0; i < formationCooldowns.length; i++) {
      w.formation[i].cooldownLeft = formationCooldowns[i] as int;
    }
    final waveSpawnedCounts = data['waveSpawnedCounts'] as List<Object?>;
    for (var i = 0; i < waveSpawnedCounts.length; i++) {
      w.waveStates[i].spawnedCount = waveSpawnedCounts[i] as int;
    }
    final bossTriggers = data['bossTriggers'] as List<Object?>;
    for (var i = 0; i < bossTriggers.length; i++) {
      final bt = bossTriggers[i] as Map<String, Object?>;
      w.bossTriggers[i].state = BossTriggerState.values[bt['state'] as int];
      w.bossTriggers[i].warningTicksLeft = bt['warningTicksLeft'] as int;
    }

    w.formationTagLevel = _tagStackFromJson(
      data['formationTagLevel'] as List<Object?>,
    );
    w.allyFieldTagLevel = _tagStackFromJson(
      data['allyFieldTagLevel'] as List<Object?>,
    );
    w.enemyFieldTagLevel = _tagStackFromJson(
      data['enemyFieldTagLevel'] as List<Object?>,
    );
    w.pendingDamage.addAll([
      for (final p in data['pendingDamage'] as List<Object?>)
        _pendingDamageFromJson(p as Map<String, Object?>),
    ]);

    for (final ed in data['entities'] as List<Object?>) {
      final entityData = ed as Map<String, Object?>;
      final defId = entityData['defId'] as String;
      final def = _findUnitDef(config, datapack, defId);
      if (def == null) {
        throw StateError('직렬화 복원 실패: UnitDef를 찾을 수 없음 - $defId');
      }
      w.entities.add(BattleEntity.deserialize(entityData, def, w.tagRegistry));
    }
    return w;
  }

  int checksum() {
    var h = 0x811c9dc5;
    h = _fnvMix(h, tick);
    h = _fnvMix(h, phase.index);
    h = _fnvMix(h, outcome?.index ?? -1);
    h = _fnvMix(h, allyBase.hp);
    h = _fnvMix(h, enemyBase.hp);
    for (final e in entities.ordered) {
      h = _fnvMix(h, e.id);
      h = _fnvMix(h, e.x);
      h = _fnvMix(h, e.hp);
      h = _fnvMix(h, e.action.index);
    }
    return h;
  }
}

/// 03_BATTLE_ENGINE.md §9.1: "삽입 시 이분 삽입, 중복 제거" — Set 대신
/// 정렬된 List를 써서 순회 순서가 결정론을 깨지 않게 한다.
void _insertSortedUnique(List<int> list, int value) {
  var lo = 0;
  var hi = list.length;
  while (lo < hi) {
    final mid = (lo + hi) >> 1;
    if (list[mid] < value) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  if (lo < list.length && list[lo] == value) return;
  list.insert(lo, value);
}

int _fnvMix(int h, int value) {
  h = (h ^ (value & 0xffffffff)) & 0xffffffff;
  h = (h * 0x01000193) & 0xffffffff;
  return h;
}

// --- T-20 직렬화 헬퍼 ---

List<Object?> _tagStackToJson(TagStack s) => [
  for (final (tagIndex, level) in s.entries()) [tagIndex, level],
];

TagStack _tagStackFromJson(List<Object?> raw) {
  final s = TagStack();
  for (final entry in raw) {
    final pair = entry as List<Object?>;
    s.add(pair[0] as int, pair[1] as int);
  }
  return s;
}

Map<String, Object?> _pendingDamageToJson(PendingDamage p) => {
  'targetId': p.targetId,
  'sourceId': p.sourceId,
  'amount': p.amount,
  'kind': p.kind.index,
  'causesForcedKb': p.causesForcedKb,
  'forcedKbDistance': p.forcedKbDistance,
};

PendingDamage _pendingDamageFromJson(Map<String, Object?> j) => PendingDamage(
  targetId: j['targetId'] as int,
  sourceId: j['sourceId'] as int,
  amount: j['amount'] as int,
  kind: DamageKind.values[j['kind'] as int],
  causesForcedKb: j['causesForcedKb'] as bool,
  forcedKbDistance: j['forcedKbDistance'] as int,
);

/// 편성(아군 소환 슬롯) 우선, 없으면 캐릭터/적 데이터팩 순으로 조회한다.
/// `spawnEntity`가 실제로 엔티티를 만들 때 def를 가져오는 두 경로와 동일.
UnitDef? _findUnitDef(BattleConfig config, Datapack datapack, String id) {
  for (final u in config.formation) {
    if (u.id == id) return u;
  }
  return datapack.characterById(id) ?? datapack.enemyById(id);
}
