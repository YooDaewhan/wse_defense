import '../constants.dart';
import '../defs/datapack.dart';
import '../defs/unit_def.dart';
import '../entity/base_entity.dart';
import '../entity/battle_entity.dart';
import '../entity/entity_store.dart';
import '../rng/deterministic_rng.dart';
import '../system/battle_system.dart';
import '../system/pending_damage.dart';
import '../tag/tag_query.dart';
import 'battle_config.dart';
import 'battle_input.dart';
import 'formation_slot.dart';

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
       prayerPower = config.startingPrayerPower,
       ultimateGauge = ultGaugeMax ~/ 2 {
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
  int weatherRegenPct = pctScale; // WeatherSystem(T-45) 전까지 100% 고정

  final List<FormationSlot> formation;

  /// 이번 틱에 큐잉된 피해. DamageSystem이 매 틱 소비 후 비운다.
  final List<PendingDamage> pendingDamage = [];

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
  BattleEntity spawnEntity(UnitDef def, Side side, int x) {
    final e = BattleEntity(
      id: _nextEntityId++,
      side: side,
      def: def,
      spawnTick: tick,
      x: x,
    );
    entities.add(e);
    return e;
  }

  /// 전장 경계 (고정소수점). 양쪽 진영 모두 같은 필드 안에서 움직이므로
  /// side별로 달라질 이유가 아직 없다 — 필요해지면(스테이지별 제한 등) 여기서 분기.
  int minX(Side side) => 0;
  int maxX(Side side) => config.stage.fieldLength * posScale;

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

int _fnvMix(int h, int value) {
  h = (h ^ (value & 0xffffffff)) & 0xffffffff;
  h = (h * 0x01000193) & 0xffffffff;
  return h;
}
