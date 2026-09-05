import '../constants.dart';
import '../defs/unit_def.dart';
import '../stat/stat_key.dart';
import '../stat/stat_sheet.dart';
import '../tag/tag_contribution.dart';
import '../tag/tag_query.dart';
import '../tag/tag_relation_state.dart';
import '../tag/tag_stack.dart';
import 'entity_state.dart';

/// 03_BATTLE_ENGINE.md §2.
///
/// `TagQuery`(T-06)가 요구하는 [TagQueryTarget]을 구현한다 — T-06이 이
/// 티켓보다 먼저 배치돼 있어 최소 인터페이스로 앞서 정의해뒀던 것.
///
/// `effects`(EffectInstance, T-17)와 `relationStates`(RelationState, T-16)는
/// 아직 그 타입들이 없어 스킵한다. 해당 티켓에서 필드를 추가한다.
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
