import '../constants.dart';
import '../defs/unit_def.dart';
import '../effect/effect_instance.dart';
import '../effect/effect_params.dart';
import '../stat/modifier.dart';
import '../stat/modifier_source.dart';
import '../stat/stat_key.dart';
import '../stat/stat_sheet.dart';
import '../tag/tag_contribution.dart';
import '../tag/tag_effect_def.dart' show StatModDef;
import '../tag/tag_query.dart';
import '../tag/tag_registry.dart';
import '../tag/tag_relation_state.dart';
import '../tag/tag_stack.dart';
import 'entity_state.dart';

/// 03_BATTLE_ENGINE.md §2.
///
/// `TagQuery`(T-06)가 요구하는 [TagQueryTarget]을 구현한다 — T-06이 이
/// 티켓보다 먼저 배치돼 있어 최소 인터페이스로 앞서 정의해뒀던 것.
class BattleEntity implements TagQueryTarget {
  BattleEntity({
    required this.id,
    required this.side,
    required this.def,
    required this.spawnTick,
    required this.x,
  }) : stats = _baseStatsFrom(def) {
    hp = stats.get(StatKey.maxHp);
  }

  final int id; // 스폰 순서대로 단조 증가
  @override
  final Side side;
  final UnitDef def; // 정적 정의 (불변)
  final int spawnTick;

  /// DeathSystem이 사망 처리하는 순간의 tick. 살아있으면 null — 전투 결과
  /// 화면(T-26)의 "전선 붕괴 시점" 계산에 쓴다.
  int? deathTick;

  // 위치 (고정소수점, POS_SCALE=1000)
  int x;
  int xFrac = 0; // 이동 나머지 누적

  // 체력
  @override
  late int hp;
  int shieldHp = 0; // 껍질

  // 태그. tags는 tagContribs를 합산한 캐시라 통째로 재계산해 교체될 수
  // 있어(TagEffectResolver.onUnitTagsChanged, T-15) final이 아니다.
  TagStack tags = TagStack();
  final List<TagContribution> tagContribs = [];

  // 스탯
  final StatSheet stats;

  // 행동 상태
  EntityAction action = EntityAction.idle;
  int actionTimer = 0; // 남은 틱
  int attackCooldown = 0; // 다음 공격까지 남은 틱 (P 기준)
  int? lockedTargetId; // 단일 공격 표적 고정
  int completedAttacks = 0; // N회 공격 트리거용

  /// 이번 판정에서 실제로 맞은 대상 id들. DamageSystem(T-10)이 생기기 전까지
  /// AttackSystem의 판정 결과를 관측하기 위한 임시 훅 — T-10에서 실제 피해
  /// 큐(PendingDamage) 적재로 대체/확장된다.
  List<int> lastHitTargetIds = [];

  // TargetSystem(T-08)이 매 틱 갱신, MovementSystem/AttackSystem(T-09)이 읽음.
  int? currentTargetId;
  bool currentTargetInRange = false;

  // 넉백
  int knockbackTicksLeft = 0;
  int knockbackVelocity = 0; // 틱당 이동량(고정소수점), 부호는 후퇴 방향
  bool knockbackIsForced = false; // 종료 시 forcedKbImmuneUntilTick 갱신 여부
  int forcedKbImmuneUntilTick = 0;
  int consumedHpThresholds = 0; // 소비한 자연 넉백 임계 수 (회복해도 복구 안 됨)

  /// 관계 규칙(T-16) id -> 상태. 여기 자체를 순회하지 않고 rule.id로만
  /// 조회하므로(RelationSystem이 rules 리스트 순서로 접근) Map 순회 금지
  /// 규칙에 저촉되지 않는다.
  final Map<String, RelationState> relationStates = {};

  /// 상태 효과(T-17). StatusSystem이 매 틱 처리·만료시킨다.
  final List<EffectInstance> effects = [];
  int stunImmuneUntilTick = 0; // 멈칫 종료 후 재적용 면역
  int pushImmuneUntilTick = 0; // 밀치기 효과 자체의 재적용 대기(3초)

  /// ON_SPAWN/ON_DEATH/ON_HP_THRESHOLD처럼 "인스턴스 1회"인 스킬 트리거의
  /// 발동 여부(skill.id 기준). 멤버십만 확인·기록하고 순회하지 않는다.
  final Set<String> firedOnceTriggers = {};

  // 파생
  @override
  bool get isAlive => hp > 0;
  bool get isKnockedBack => knockbackTicksLeft > 0;

  /// 공격 대상 및 전선 차단에서 제외되는가 (기획서 6-1)
  bool get isTargetable => isAlive && !isKnockedBack;
  int get facingSign => side == Side.ally ? 1 : -1;

  // --- TagQueryTarget ---
  @override
  int get entityId => id;
  @override
  int get posX => x;
  @override
  bool get isKnockback => isKnockedBack;
  @override
  String? get role => def.role;
  @override
  int tagLevel(int tagIndex) => tags.levelOf(tagIndex);

  /// 03_BATTLE_ENGINE.md §14 직렬화(T-20). `tags`는 `tagContribs`의 순수
  /// 캐시라(TagEffectResolver._rebuildUnitTagStack와 동일한 계산) 내보내지
  /// 않는다 — 복원 시 `tagRegistry.buildStack(tagContribs)`로 다시 만든다.
  Map<String, Object?> serialize() => {
    'id': id,
    'side': side.index,
    'defId': def.id,
    'spawnTick': spawnTick,
    'deathTick': deathTick,
    'x': x,
    'xFrac': xFrac,
    'hp': hp,
    'shieldHp': shieldHp,
    'tagContribs': [for (final c in tagContribs) _tagContribToJson(c)],
    'statModifiers': [for (final m in stats.modifiers) _statModifierToJson(m)],
    'action': action.index,
    'actionTimer': actionTimer,
    'attackCooldown': attackCooldown,
    'lockedTargetId': lockedTargetId,
    'completedAttacks': completedAttacks,
    'lastHitTargetIds': lastHitTargetIds,
    'currentTargetId': currentTargetId,
    'currentTargetInRange': currentTargetInRange,
    'knockbackTicksLeft': knockbackTicksLeft,
    'knockbackVelocity': knockbackVelocity,
    'knockbackIsForced': knockbackIsForced,
    'forcedKbImmuneUntilTick': forcedKbImmuneUntilTick,
    'consumedHpThresholds': consumedHpThresholds,
    'relationStates': {
      for (final e in relationStates.entries) e.key: _relationStateToJson(e.value),
    },
    'effects': [for (final e in effects) _effectInstanceToJson(e)],
    'stunImmuneUntilTick': stunImmuneUntilTick,
    'pushImmuneUntilTick': pushImmuneUntilTick,
    'firedOnceTriggers': firedOnceTriggers.toList(),
  };

  /// [serialize]의 역. `def`는 호출부(BattleWorld.deserialize)가
  /// `defId`로 formation/datapack에서 찾아 넘긴다.
  static BattleEntity deserialize(
    Map<String, Object?> data,
    UnitDef def,
    TagRegistry tagRegistry,
  ) {
    final e = BattleEntity(
      id: data['id'] as int,
      side: Side.values[data['side'] as int],
      def: def,
      spawnTick: data['spawnTick'] as int,
      x: data['x'] as int,
    );
    e.deathTick = data['deathTick'] as int?;
    e.xFrac = data['xFrac'] as int;
    e.hp = data['hp'] as int;
    e.shieldHp = data['shieldHp'] as int;
    e.tagContribs.addAll([
      for (final c in data['tagContribs'] as List<Object?>)
        _tagContribFromJson(c as Map<String, Object?>),
    ]);
    e.tags = tagRegistry.buildStack(e.tagContribs);
    for (final m in data['statModifiers'] as List<Object?>) {
      e.stats.addModifier(_statModifierFromJson(m as Map<String, Object?>));
    }
    e.action = EntityAction.values[data['action'] as int];
    e.actionTimer = data['actionTimer'] as int;
    e.attackCooldown = data['attackCooldown'] as int;
    e.lockedTargetId = data['lockedTargetId'] as int?;
    e.completedAttacks = data['completedAttacks'] as int;
    e.lastHitTargetIds = [
      for (final id in data['lastHitTargetIds'] as List<Object?>) id as int,
    ];
    e.currentTargetId = data['currentTargetId'] as int?;
    e.currentTargetInRange = data['currentTargetInRange'] as bool;
    e.knockbackTicksLeft = data['knockbackTicksLeft'] as int;
    e.knockbackVelocity = data['knockbackVelocity'] as int;
    e.knockbackIsForced = data['knockbackIsForced'] as bool;
    e.forcedKbImmuneUntilTick = data['forcedKbImmuneUntilTick'] as int;
    e.consumedHpThresholds = data['consumedHpThresholds'] as int;
    (data['relationStates'] as Map<String, Object?>).forEach((k, v) {
      e.relationStates[k] = _relationStateFromJson(v as Map<String, Object?>);
    });
    e.effects.addAll([
      for (final ev in data['effects'] as List<Object?>)
        _effectInstanceFromJson(ev as Map<String, Object?>),
    ]);
    e.stunImmuneUntilTick = data['stunImmuneUntilTick'] as int;
    e.pushImmuneUntilTick = data['pushImmuneUntilTick'] as int;
    e.firedOnceTriggers.addAll([
      for (final t in data['firedOnceTriggers'] as List<Object?>) t as String,
    ]);
    return e;
  }

  static StatSheet _baseStatsFrom(UnitDef def) {
    final b = def.base;
    return StatSheet({
      StatKey.maxHp: b.maxHp,
      StatKey.atk: b.atk,
      StatKey.def: b.def,
      StatKey.attackPeriod: b.attackPeriod,
      StatKey.attackWindup: b.attackWindup,
      StatKey.attackRange: b.attackRange,
      StatKey.moveSpeed: b.moveSpeed,
      StatKey.hpSegments: b.hpSegments,
      StatKey.knockbackResist: b.knockbackResist,
      StatKey.knockbackDistance: b.knockbackDistance,
      StatKey.summonCost: b.summonCost,
      StatKey.resummonCooldown: b.resummonCooldownSec * ticksPerSec,
      StatKey.aoeMaxTargets: b.aoeMaxTargets,
      StatKey.prayerGainOnKill: def.killPrayerReward,
    });
  }
}

// --- T-20 직렬화 헬퍼: 전부 필드가 public인 단순 값 타입이라 해당 클래스를
// 건드리지 않고 여기서 변환한다. enum은 인덱스로 저장(내부 라운드트립
// 전용 포맷 — data/*.json의 문자열 포맷과는 무관).

Map<String, Object?> _tagContribToJson(TagContribution c) => {
  'tagIndex': c.tagIndex,
  'amount': c.amount,
  'kind': c.kind.index,
  'sourceId': c.sourceId,
  'expireTick': c.expireTick,
};

TagContribution _tagContribFromJson(Map<String, Object?> j) => TagContribution(
  tagIndex: j['tagIndex'] as int,
  amount: j['amount'] as int,
  kind: TagSourceKind.values[j['kind'] as int],
  sourceId: j['sourceId'] as String,
  expireTick: j['expireTick'] as int?,
);

Map<String, Object?> _modifierSourceToJson(ModifierSource s) => {
  'kind': s.kind.index,
  'id': s.id,
  'instanceId': s.instanceId,
};

ModifierSource _modifierSourceFromJson(Map<String, Object?> j) => ModifierSource(
  ModifierKind.values[j['kind'] as int],
  j['id'] as String,
  instanceId: j['instanceId'] as int?,
);

Map<String, Object?> _statModifierToJson(StatModifier m) => {
  'stat': m.stat.index,
  'op': m.op.index,
  'value': m.value,
  'source': _modifierSourceToJson(m.source),
  'exclusiveGroup': m.exclusiveGroup,
};

StatModifier _statModifierFromJson(Map<String, Object?> j) => StatModifier(
  stat: StatKey.values[j['stat'] as int],
  op: ModOp.values[j['op'] as int],
  value: j['value'] as int,
  source: _modifierSourceFromJson(j['source'] as Map<String, Object?>),
  exclusiveGroup: j['exclusiveGroup'] as String?,
);

Map<String, Object?> _statModDefToJson(StatModDef m) => {
  'stat': m.stat.index,
  'op': m.op.index,
  'value': m.value,
  'exclusiveGroup': m.exclusiveGroup,
};

StatModDef _statModDefFromJson(Map<String, Object?> j) => StatModDef(
  stat: StatKey.values[j['stat'] as int],
  op: ModOp.values[j['op'] as int],
  value: j['value'] as int,
  exclusiveGroup: j['exclusiveGroup'] as String?,
);

Map<String, Object?> _relationStateToJson(RelationState s) => {
  'active': s.active,
  'activeSince': s.activeSince,
  'offCounter': s.offCounter,
  'scale': s.scale,
};

RelationState _relationStateFromJson(Map<String, Object?> j) => RelationState()
  ..active = j['active'] as bool
  ..activeSince = j['activeSince'] as int
  ..offCounter = j['offCounter'] as int
  ..scale = j['scale'] as int;

Map<String, Object?> _effectParamsToJson(EffectParams p) => {
  'durationTicks': p.durationTicks,
  'movePct': p.movePct,
  'attackPeriodMult': p.attackPeriodMult,
  'distance': p.distance,
  'amount': p.amount,
  'pctOfMaxHp': p.pctOfMaxHp,
  'intervalTicks': p.intervalTicks,
  'mods': [for (final m in p.mods) _statModDefToJson(m)],
  'exclusiveGroup': p.exclusiveGroup,
  'tagIndex': p.tagIndex,
  'tagAmount': p.tagAmount,
};

EffectParams _effectParamsFromJson(Map<String, Object?> j) => EffectParams(
  durationTicks: j['durationTicks'] as int,
  movePct: j['movePct'] as int,
  attackPeriodMult: j['attackPeriodMult'] as int,
  distance: j['distance'] as int,
  amount: j['amount'] as int,
  pctOfMaxHp: j['pctOfMaxHp'] as int,
  intervalTicks: j['intervalTicks'] as int,
  mods: [
    for (final m in j['mods'] as List<Object?>)
      _statModDefFromJson(m as Map<String, Object?>),
  ],
  exclusiveGroup: j['exclusiveGroup'] as String?,
  tagIndex: j['tagIndex'] as int,
  tagAmount: j['tagAmount'] as int,
);

Map<String, Object?> _effectInstanceToJson(EffectInstance e) => {
  'type': e.type,
  'source': _modifierSourceToJson(e.source),
  'params': _effectParamsToJson(e.params),
  'ticksLeft': e.ticksLeft,
  'tickAccumulator': e.tickAccumulator,
};

EffectInstance _effectInstanceFromJson(Map<String, Object?> j) => EffectInstance(
  type: j['type'] as String,
  source: _modifierSourceFromJson(j['source'] as Map<String, Object?>),
  params: _effectParamsFromJson(j['params'] as Map<String, Object?>),
  ticksLeft: j['ticksLeft'] as int,
)..tickAccumulator = j['tickAccumulator'] as int;
