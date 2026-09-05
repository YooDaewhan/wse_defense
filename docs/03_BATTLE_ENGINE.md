# 03. 전투 코어 엔진 (Battle Engine)

> 순수 Dart. Flutter/Flame 의존 0. 30틱/초 고정 결정론 시뮬레이션.
> 목표: **시스템 하나를 리스트에서 빼도 나머지가 돌아간다.**

---

## 1. 최상위 인터페이스

```dart
// lib/battle/world/battle_world.dart

class BattleWorld {
  BattleWorld({
    required BattleConfig config,
    required int rngSeed,
    required Datapack datapack,
  });

  int tick = 0;
  BattlePhase phase = BattlePhase.ready;   // ready | running | finished
  BattleOutcome? outcome;

  // 엔티티 저장소 — entityId 오름차순 정렬 유지
  final EntityStore entities = EntityStore();
  late final BaseEntity allyBase;   // 모닥불
  late final BaseEntity enemyBase;  // 둥지

  // 자원
  int prayerPower = 0;            // 현재 기도력 (밀리 단위 아님, 정수)
  int prayerPowerFrac = 0;        // 초당 회복의 틱 나머지 누적
  int focusBoostStage = 0;
  int ultimateGauge = 0;          // 0..ULT_GAUGE_MAX
  int ultimateStock = 0;

  // 날씨
  int weatherGauge = 0;           // −100..100
  WeatherState weather = WeatherState.dusk;

  final DeterministicRng rng;
  final BattleEventBus events = BattleEventBus();
  final List<BattleSystem> systems;      // ★ 실행 순서 = §3
  final InputQueue inputs = InputQueue();

  /// 정확히 1틱 진행. 외부에서 이것만 호출한다.
  void step() {
    if (phase != BattlePhase.running) return;
    for (final s in systems) {
      s.execute(this);
    }
    tick++;
  }

  void enqueueInput(BattleInput input) => inputs.add(tick, input);

  /// 렌더/UI 용 읽기 전용 스냅샷
  BattleSnapshot snapshot();

  /// 저장/복구용 직렬화 (재접속 대응)
  Uint8List serialize();
  static BattleWorld deserialize(Uint8List bytes, Datapack dp);

  /// 결정론 검증용
  int checksum();
}

enum BattlePhase { ready, running, finished }
enum BattleOutcome { allyWin, enemyWin, draw, timeout }
```

### 1.1 시간 진행 (호출자 쪽)

```dart
// lib/game/battle_game.dart  (Flame 레이어)
static const int _tickUs = 1000000 ~/ TICKS_PER_SEC;   // 33333
int _accumulatorUs = 0;

@override
void update(double dt) {
  final int dtUs = (dt * 1000000).round();
  _accumulatorUs += dtUs * speedMultiplier;   // 1 또는 2
  // 프레임 드랍 시 폭주 방지
  if (_accumulatorUs > _tickUs * 8) _accumulatorUs = _tickUs * 8;
  while (_accumulatorUs >= _tickUs) {
    world.step();
    _accumulatorUs -= _tickUs;
  }
  _renderAlpha = _accumulatorUs / _tickUs;   // 보간용 0..1
  viewModel.sync(world, _renderAlpha);
}
```

**2배속은 틱 간격을 줄이지 않고 틱을 2배 자주 밟는다.** 판정 순서·수치가 완전히 동일해진다.

---

## 2. 엔티티

```dart
// lib/battle/entity/battle_entity.dart

class BattleEntity {
  final int id;                  // 스폰 순서대로 단조 증가
  final Side side;               // ally | enemy
  final UnitDef def;             // 정적 정의 (불변)
  final int spawnTick;

  // 위치 (고정소수점, POS_SCALE=1000)
  int x;
  int xFrac = 0;                 // 이동 나머지 누적

  // 체력
  int hp;
  int shieldHp = 0;              // 껍질

  // 태그
  final TagStack tags = TagStack();
  final List<TagContribution> tagContribs = [];

  // 스탯
  final StatSheet stats = StatSheet();

  // 행동 상태
  EntityAction action = EntityAction.idle;
  int actionTimer = 0;           // 남은 틱
  int attackCooldown = 0;        // 다음 공격까지 남은 틱 (P 기준)
  int? lockedTargetId;           // 단일 공격 표적 고정
  int completedAttacks = 0;      // N회 공격 트리거용

  // 넉백
  int knockbackTicksLeft = 0;
  int knockbackVelocity = 0;     // 틱당 이동량(고정소수점), 부호는 후퇴 방향
  int forcedKbImmuneUntilTick = 0;
  int consumedHpThresholds = 0;  // 소비한 자연 넉백 임계 수 (회복해도 복구 안 됨)

  // 상태 효과
  final List<EffectInstance> effects = [];

  // 관계 태그 상태
  final Map<String, RelationState> relationStates = {};   // 순회 시 rules 순서로 접근

  // 파생
  bool get isAlive => hp > 0;
  bool get isKnockedBack => knockbackTicksLeft > 0;
  /// 공격 대상 및 전선 차단에서 제외되는가 (기획서 6-1)
  bool get isTargetable => isAlive && !isKnockedBack;
  int get facingSign => side == Side.ally ? 1 : -1;
}

enum EntityAction {
  idle,        // 대기 (표적 없음)
  moving,
  attackWindup,   // 선딜 A
  attackRecover,  // 후딜 R
  stunned,        // 멈칫
  knockback,
  dead,
}
```

### 2.1 기지 엔티티

```dart
class BaseEntity {
  final Side side;
  int hp;
  final int maxHp;
  int x;                  // 아군 0, 적 2400
  bool damageImmune = false;   // 보스 예고 중 무적
  bool destroyed = false;
}
```

기지는 일반 엔티티와 별도 클래스로 둔다. 이동·공격·태그가 없어 분기가 줄고 버그가 준다.

---

## 3. 시스템 실행 순서 (★ 변경 금지 · 결정론의 근거)

한 틱은 아래 순서로 정확히 1회씩 실행된다.

| # | 시스템 | 역할 |
|---:|---|---|
| 1 | `InputSystem` | 이번 틱의 입력 처리 (소환/필살기/집중강화). 유효성 검사 후 실행 |
| 2 | `ResourceSystem` | 기도력 자동 회복, 필살기 게이지 충전 |
| 3 | `SpawnSystem` | 스테이지 웨이브에 따른 적 스폰, 보스 트리거 상태 전이 |
| 4 | `EffectExpireSystem` | 만료된 `EffectInstance`·`TagContribution` 제거 |
| 5 | `TagResolveSystem` | 태그 스택 재계산이 필요한 유닛 처리. `FIELD_SAMPLE_TICKS`마다 필드 스코프 재평가 |
| 6 | `RelationSystem` | `RELATION_SAMPLE_TICKS`마다 위치 관계 규칙 평가 |
| 7 | `WeatherSystem` | 2초마다 게이지 갱신, 상태 전이, 날씨 모디파이어 갱신 |
| 8 | `StatusSystem` | 멈칫/느릿 등 상태 효과의 틱 처리 (지속피해·주기회복) |
| 9 | `KnockbackSystem` | 넉백 중 유닛 이동, 종료 처리 |
| 10 | `TargetSystem` | 각 유닛의 표적 결정 (사거리 내 유효 적) |
| 11 | `MovementSystem` | 표적 없거나 사거리 밖이면 전진. 충돌 정지 |
| 12 | `AttackSystem` | 공격 상태머신: cooldown → windup(A) → 판정 → recover(R) |
| 13 | `DamageSystem` | 이번 틱에 발생한 모든 피해를 **대상별 합산** 후 확정 적용 |
| 14 | `DeathSystem` | HP 0 처리, 사망 트리거, 처치 기도력 지급 |
| 15 | `VictorySystem` | 기지 파괴/시간 초과 판정 |
| 16 | `EventFlushSystem` | 이번 틱 이벤트를 렌더/사운드용 큐로 방출 |

```dart
// 조립부. 시스템을 빼거나 끼우는 유일한 장소.
List<BattleSystem> buildSystems({bool enableWeather = true}) => [
  InputSystem(),
  ResourceSystem(),
  SpawnSystem(),
  EffectExpireSystem(),
  TagResolveSystem(),
  RelationSystem(),
  if (enableWeather) WeatherSystem(),   // ← M1에서는 false
  StatusSystem(),
  KnockbackSystem(),
  TargetSystem(),
  MovementSystem(),
  AttackSystem(),
  DamageSystem(),
  DeathSystem(),
  VictorySystem(),
  EventFlushSystem(),
];
```

```dart
abstract class BattleSystem {
  String get id;
  void execute(BattleWorld w);
}
```

> **M1에서 `WeatherSystem`을 리스트에서 빼는 것**이 기획서의
> "M1에서는 날씨 효과를 끄고 기본 전투를 확인한다"의 구현이다. 플래그 분기가 코드에 흩어지지 않는다.

---

## 4. 공격 상태머신 (기획서 6-3 구현)

```
        ┌──────────────────────────────────────────┐
        │                                          │
   [idle/moving] ──표적이 사거리 내 & cooldown==0──► [attackWindup]
        ▲                                              │ A틱 경과
        │                                              ▼
        │                                        ★판정(Damage 큐에 등록)
        │                                              │
        │                                              ▼
        └────────── R틱 경과 ────────────────── [attackRecover]

넉백/멈칫 진입 시: 진행 중 공격 취소. attackCooldown은 P로 리셋되지 않고
그대로 남으며, 복귀 후 전체 선딜 A를 다시 거친다. (기획서 6-3)
```

```dart
class AttackSystem implements BattleSystem {
  void execute(BattleWorld w) {
    for (final e in w.entities.ordered) {     // entityId 오름차순
      if (!e.isAlive) continue;
      if (e.action == EntityAction.stunned) continue;   // 타이머 정지
      if (e.isKnockedBack) { _cancelAttack(e); continue; }

      if (e.attackCooldown > 0) e.attackCooldown--;

      switch (e.action) {
        case EntityAction.attackWindup:
          e.actionTimer--;
          if (e.actionTimer <= 0) {
            _resolveHit(w, e);                          // ★ 발동 시점
            e.completedAttacks++;
            e.action = EntityAction.attackRecover;
            e.actionTimer = e.stats.get(StatKey.attackPeriod)
                          - e.stats.get(StatKey.attackWindup);
            w.events.emit(AttackFiredEvent(e.id, e.lockedTargetId));
            SkillTriggerRunner.onAttackCompleted(w, e);  // N회 공격 트리거
          }
          break;

        case EntityAction.attackRecover:
          e.actionTimer--;
          if (e.actionTimer <= 0) e.action = EntityAction.idle;
          break;

        default:
          if (e.attackCooldown == 0 && e.currentTargetInRange) {
            e.action = EntityAction.attackWindup;
            e.actionTimer = e.stats.get(StatKey.attackWindup);
            e.attackCooldown = e.stats.get(StatKey.attackPeriod);
            e.lockedTargetId = e.currentTargetId;        // 단일: 시작 시 고정
            w.events.emit(AttackStartedEvent(e.id));
          }
      }
    }
  }
}
```

### 4.1 판정 규칙

| 공격 방식 | 표적 결정 | 헛침 |
|---|---|---|
| `SINGLE` | **공격 시작 시** 고정 | 발동 시 사거리 밖/사망이면 헛침 |
| `AOE` | **발동 시점**에 전방 사거리 내 유효 적 최대 `aoeMaxTargets`개 | 대상 0이면 헛침 |
| `PIERCE` | M2. 투사체 엔티티 생성, 타격 중복 방지 세트 유지 | — |

- 범위 대상 선택은 `NEAREST` 정렬 후 `aoeMaxTargets`개. 동거리는 `entityId` 오름차순.
- 공격속도 변화는 **다음 공격 시작부터** 반영 (`attackPeriod`를 windup 진입 시 스냅샷).

### 4.2 사거리 판정

```dart
/// 충돌 경계 간 거리 (기획서 6-1)
int gapBetween(BattleEntity a, BattleEntity b) =>
    ((a.x - b.x).abs() ~/ POS_SCALE) - a.def.collisionRadius - b.def.collisionRadius;

bool inRange(BattleEntity a, BattleEntity b) =>
    gapBetween(a, b) <= a.stats.get(StatKey.attackRange);
```

---

## 5. 이동과 충돌

```dart
class MovementSystem implements BattleSystem {
  void execute(BattleWorld w) {
    for (final e in w.entities.ordered) {
      if (!e.isAlive || e.isKnockedBack) continue;
      if (e.action != EntityAction.idle && e.action != EntityAction.moving) continue;
      if (e.currentTargetInRange) { e.action = EntityAction.idle; continue; }

      final int speed = e.stats.get(StatKey.moveSpeed);      // 논리단위/초
      final int perTick = speed * POS_SCALE ~/ TICKS_PER_SEC;
      int nx = e.x + perTick * e.facingSign;

      // 적 유닛과의 충돌: 서로 통과하지 않는다
      nx = _clampByBlockers(w, e, nx);
      // 기지 경계
      nx = nx.clamp(w.minX(e.side), w.maxX(e.side));

      if (nx != e.x) { e.x = nx; e.action = EntityAction.moving; }
      else { e.action = EntityAction.idle; }
    }
  }
}
```

- 같은 편끼리는 **겹쳐 지나간다** (기획서 6-1).
- 적과는 충돌 반경 경계에서 멈춘다. **넉백 중인 유닛은 차단 판정에서 제외** → 벽이 밀리면
  뒤의 딜러가 노출된다.
- `_clampByBlockers`는 `x` 정렬 리스트를 매 틱 1회 만들어 전방 탐색한다. O(N log N).

---

## 6. 피해 처리 순서 (동일 틱 다중 피해 · 기획서 6-4)

```dart
class PendingDamage {
  final int targetId;
  final int sourceId;
  final int amount;          // 최종 계산 완료된 값
  final DamageKind kind;     // direct | dot | reflect
  final bool causesForcedKb;
  final int forcedKbDistance;
}
```

`DamageSystem`은 이번 틱에 큐잉된 모든 `PendingDamage`를 다음 순서로 확정한다.

```
1. targetId 별로 그룹화 (targetId 오름차순)
2. 각 그룹 내 direct 피해를 합산 (sourceId 오름차순으로 누적하되 합계만 사용)
3. shieldHp 로 먼저 흡수, 초과분을 hp에서 차감          (껍질)
4. hp <= 0  → 사망 확정. 넉백으로 살아남지 않는다.
5. hp > 0   → HP 임계 통과 검사 (아래 §6.1)
6. 강제 넉백 적용 여부 판정 (§6.2)
```

**"먼저 처리된 공격이 무적을 만들어 나중 공격을 지우지 않는다"**를 이 합산 구조로 보장한다.

### 6.1 자연 넉백 임계 (K)

```dart
/// K = hpSegments (사망 포함 구간 수). 자연 넉백은 최대 K-1회.
/// 임계값: maxHp * i / K  (i = K-1 .. 1)
int thresholdsCrossed(int maxHp, int K, int newHp, int alreadyConsumed) {
  // newHp가 몇 번째 임계 아래로 내려갔는지
  int crossed = 0;
  for (int i = K - 1; i >= 1; i--) {
    final int th = maxHp * i ~/ K;
    if (newHp <= th) crossed++;
  }
  return (crossed - alreadyConsumed).clamp(0, K - 1 - alreadyConsumed);
}
```

- 한 번의 피해로 여러 임계를 넘으면 **임계는 모두 소비하고 넉백 애니메이션은 1회만**.
- 회복으로 HP가 올라가도 `consumedHpThresholds`는 되돌리지 않는다. → 반복 무적 방지.
- `MAX_HP`가 태그/버프 변화로 줄어들어도 `consumedHpThresholds`는 유지한다.

### 6.2 넉백 적용

```dart
const int NATURAL_KB_DISTANCE = 90;   // 논리 단위
const int NATURAL_KB_TICKS = 12;      // 0.4초
const int FORCED_KB_IMMUNE_TICKS = 30; // 강제 넉백 재적용 방지 1초
```

| 항목 | 자연 넉백 | 강제 넉백(밀치기) |
|---|---|---|
| 발생 | HP 임계 통과 | 스킬 효과 |
| 임계 소비 | O | X |
| 재적용 제한 | 없음 (임계가 유한하므로) | 종료 후 30틱 |
| 보스 저항 | 거리 그대로 | 거리 50% |
| 중첩 | 넉백 중 추가 임계 통과 → 무시 | 넉백 중 추가 적중 → 무시 |

넉백 중:
- 공격/피격 불가, 전선 차단 불가 (`isTargetable == false`)
- 지속피해 **적용 안 함**, 지속시간은 **흐른다**
- 회복은 **허용**
- 진행 중 공격 취소
- 경계(모닥불 앞/둥지 앞)에 닿아도 **정해진 넉백 시간은 유지**

```dart
class KnockbackSystem implements BattleSystem {
  void execute(BattleWorld w) {
    for (final e in w.entities.ordered) {
      if (e.knockbackTicksLeft <= 0) continue;
      e.x = (e.x + e.knockbackVelocity).clamp(w.minX(e.side), w.maxX(e.side));
      e.knockbackTicksLeft--;
      if (e.knockbackTicksLeft == 0) {
        e.action = EntityAction.idle;
        e.actionTimer = 0;
        // attackCooldown 은 유지 → 복귀 후 전체 선딜 A를 다시 거침
        w.events.emit(KnockbackEndEvent(e.id));
      }
    }
  }
}
```

---

## 7. 피해 계산식

```dart
int computeDamage(BattleWorld w, BattleEntity atk, BattleEntity tgt, int baseAtk) {
  int dmg = baseAtk;

  // 1) 공격자의 조건부 주는 피해 (속성 상성 등)
  final int dealtPct = atk.stats.conditionalPct(StatKey.dmgDealtVs, tgt, w);
  dmg = dmg * (PCT_SCALE + dealtPct) ~/ PCT_SCALE;

  // 2) 대상의 조건부 받는 피해
  final int takenPct = tgt.stats.conditionalPct(StatKey.dmgTakenFrom, atk, w);
  dmg = dmg * (PCT_SCALE + takenPct) ~/ PCT_SCALE;

  // 3) 대상의 피해 감소 (def). '뚫기'는 지정한 감소만 무시
  int reduce = tgt.stats.get(StatKey.def);                 // 밀리퍼센트
  if (atk.hasPierceAgainst(DefKind.def)) reduce = 0;
  reduce = reduce.clamp(0, 90000);                          // 최대 90% 감소
  dmg = dmg * (PCT_SCALE - reduce) ~/ PCT_SCALE;

  // 4) 최소 피해 보장
  return dmg < 1 ? 1 : dmg;
}
```

- 각 단계마다 즉시 `~/ PCT_SCALE`로 축소해 오버플로우/JS 53bit 문제를 회피한다.
- `def`는 방어력 수치가 아니라 **피해 감소 밀리퍼센트**로 통일한다 (계산이 단순, 상한이 명확).

---

## 8. 기도력 (기획서 6-2 구현)

```dart
class ResourceSystem implements BattleSystem {
  void execute(BattleWorld w) {
    // 초당 회복 = (집중력 레벨 기본 + 집중 단계 보너스) × 날씨 배율
    final int perSec = w.config.focusBaseRegen
                     + w.config.focusBoostBonus[w.focusBoostStage]
                     ;
    final int weathered = perSec * w.weatherRegenPct ~/ PCT_SCALE;

    // 틱 단위 정수 누적: 나머지를 frac에 보관해 오차 0
    w.prayerPowerFrac += weathered;
    final int gain = w.prayerPowerFrac ~/ TICKS_PER_SEC;
    w.prayerPowerFrac -= gain * TICKS_PER_SEC;

    final int cap = w.config.focusBaseCap + w.config.focusBoostCap[w.focusBoostStage];
    w.prayerPower = (w.prayerPower + gain).clamp(0, cap);

    // 필살기 게이지 (집중 강화 영향 없음)
    if (w.ultimateStock < ULT_MAX_STOCK) {
      w.ultimateGauge += ULT_GAUGE_PER_TICK;      // 60초 = 1800틱에 만충
      if (w.ultimateGauge >= ULT_GAUGE_MAX) {
        w.ultimateGauge -= ULT_GAUGE_MAX;
        w.ultimateStock++;
      }
    }
  }
}
```

| 상수 | 값 |
|---|---|
| `ULT_GAUGE_MAX` | 1800 (= 60초 × 30틱) |
| `ULT_GAUGE_PER_TICK` | 1 |
| `ULT_MAX_STOCK` | 1 |
| 시작 게이지 | `ULT_GAUGE_MAX ~/ 2` (50%) |

### 8.1 소환 처리

```dart
SummonResult trySummon(BattleWorld w, int slotIndex) {
  final slot = w.config.formation[slotIndex];
  final int cost = slot.summonCost;                 // 태그·장비 반영된 최종값
  final int cap  = w.currentPrayerCap;

  if (cost > cap)                       return SummonResult.costExceedsCap;
  if (w.prayerPower < cost)             return SummonResult.notEnoughPrayer;
  if (slot.cooldownLeft > 0)            return SummonResult.onCooldown;
  if (w.allyAliveCount >= UNIT_CAP)     return SummonResult.unitCapReached;

  w.prayerPower -= cost;                            // ★ 성공 시에만 차감
  slot.cooldownLeft = slot.resummonCooldownTicks;
  final e = w.spawnAlly(slot);
  TagEffectResolver.resolveUnitOnSpawn(e, w);
  SkillTriggerRunner.onSpawn(w, e);
  return SummonResult.ok;
}
```

`UNIT_CAP = 40` (편/각각). 실패 시 기도력 차감 없음. 실패 사유는 UI 토스트로 구분 표시.

---

## 9. 날씨 (기획서 6-7 구현)

```dart
class WeatherSystem implements BattleSystem {
  static const int SAMPLE_TICKS = 60;   // 2초

  void execute(BattleWorld w) {
    _accumulateActivity(w);             // 매 틱: 활약 플래그 수집
    if (w.tick % SAMPLE_TICKS != 0 || w.tick == 0) return;

    final int ns = w.activeSunKinds.length.clamp(0, 3);
    final int nm = w.activeMoonKinds.length.clamp(0, 3);
    final int nf = w.activeFieldKinds.length.clamp(0, 3);

    final int b = (6 * (ns - nm)).clamp(-12, 12);
    final int t = (w.weatherGauge + b).clamp(-100, 100);
    final int decayed = (t.abs() - 4 * nf);
    w.weatherGauge = t.sign * (decayed < 0 ? 0 : decayed);

    _applyStageBias(w);                 // 스테이지 편향 기믹
    _updateState(w);                    // 히스테리시스 전이
    _refreshWeatherModifiers(w);        // ModifierKind.weather 통째 교체
    _clearActivity(w);
  }

  void _updateState(BattleWorld w) {
    final g = w.weatherGauge;
    switch (w.weather) {
      case WeatherState.dusk:
        if (g >= 60) w.weather = WeatherState.clear;
        else if (g <= -60) w.weather = WeatherState.night;
        break;
      case WeatherState.clear:
        if (g <= -60) w.weather = WeatherState.night;      // 강제 큰 변화
        else if (g < 40) w.weather = WeatherState.dusk;
        break;
      case WeatherState.night:
        if (g >= 60) w.weather = WeatherState.clear;
        else if (g > -40) w.weather = WeatherState.dusk;
        break;
    }
  }
}
```

### 9.1 '활약' 판정 (기획서 정의 그대로)

```
살아있는 소환체가 2초 구간에
  - 유효 공격 판정 1회 이상 완료  OR
  - 실제 HP 회복 / 버프 적용 1회 이상 수행
→ 그 '종류(캐릭터 ID)'가 활동한 것으로 본다. 같은 종류 20개여도 활동 수 1.

인정하지 않는 것: 허공 공격, 최대 HP 상태 회복, 자기 HP 소비만, 시체/부활대기/넉백 중 행동
들 기질 추가: 그 구간에 실제 피해를 받은 경우도 활동 인정
```

```dart
// 구현: Set<String> 대신 정렬된 List<int>(characterIndex)로 보관해 결정론 유지
final List<int> activeSunKinds = [];   // 삽입 시 이분 삽입, 중복 제거
```

### 9.2 날씨 상태 효과

| 상태 | 아군 공격력 | 기도력 자동회복 | 아군 회복 |
|---|---:|---:|---|
| 맑음 | +15% | −10% | −20% |
| 노을 | — | — | — |
| 밤 | −10% | +10% | 최대HP 0.25%/초 |

- 날씨 회복 + 토닥임 합산 총 주기 회복은 **대상 최대HP의 2%/초** 상한.
- 날씨는 적·기지·필살기·고정 자기비용을 강화하지 않는다.
- 날씨 모디파이어는 `ModifierKind.weather` 로 태깅 → 상태 전이 시 `removeBySource` 후 재부여.

---

## 10. 효과 라이브러리 (플러그인 구조)

```dart
// lib/battle/effect/effect.dart

abstract class EffectHandler {
  String get type;                       // "STUN", "SLOW", "PUSH", "HEAL", ...
  /// 적용 시도. 이미 있으면 갱신 정책에 따라 처리.
  void apply(BattleWorld w, BattleEntity target, EffectParams p, EffectSource src);
  /// 매 틱 처리 (필요한 경우만)
  void onTick(BattleWorld w, BattleEntity target, EffectInstance inst) {}
  /// 제거 시 정리
  void onRemove(BattleWorld w, BattleEntity target, EffectInstance inst) {}
}

class EffectRegistry {
  static final Map<String, EffectHandler> _handlers = {};
  static void register(EffectHandler h) => _handlers[h.type] = h;
  static EffectHandler? of(String type) => _handlers[type];
}

// 등록부 — 새 효과 추가 시 여기 한 줄만 늘어난다
void registerAllEffects() {
  EffectRegistry.register(StunHandler());       // 멈칫
  EffectRegistry.register(SlowHandler());       // 느릿
  EffectRegistry.register(PushHandler());       // 밀치기
  EffectRegistry.register(HealOverTimeHandler());  // 토닥임
  EffectRegistry.register(AtkDownHandler());    // 기죽이기   (M2)
  EffectRegistry.register(RallyHandler());      // 기운내기   (M2)
  EffectRegistry.register(PierceHandler());     // 뚫기       (M2)
  EffectRegistry.register(ShellHandler());      // 껍질       (M2)
  EffectRegistry.register(GrantTagHandler());   // ★ 태그 부여 효과
  EffectRegistry.register(ReviveHandler());     // 벌떡       (M3)
}
```

### 10.1 기획서 6-5 효과 구현 메모

| 효과 | 구현 포인트 |
|---|---|
| 멈칫 `STUN` | 같은 효과는 `max(잔여, 신규)`, 합산 없음. 종료 후 30틱 재적용 면역. `action=stunned` 로 모든 타이머 정지 |
| 느릿 `SLOW` | 이동 −30%는 `MOVE_SPEED PCT_ADD −30000`, 공격빈도 −20%는 `attackPeriod = 기존/0.8` → `MULT 125000`. **다음 공격부터** 반영 |
| 밀치기 `PUSH` | 강제 넉백. 보스는 거리 50%. `forcedKbImmuneUntilTick` 확인 |
| 기죽이기 `ATK_DOWN` | 같은 계열 **최강 효과만 적용** → `StatSheet`에 `exclusiveGroup` 개념 추가 |
| 토닥임 `HOT` | 같은 종류 소환체의 동일 회복은 중첩 X, 대상당 **가장 강한 주기 회복만**. `exclusiveGroup: "HOT_<skillId>"` |
| 기운내기 `RALLY` | 자기 최대HP 5% 소비. HP ≤ 비용이면 발동 안 함. **자기 비용은 자연 넉백·날씨 활약을 만들지 않음** → `DamageKind.selfCost` 로 별도 처리 |
| 뚫기 `PIERCE` | `pierceTargets: [DEF]` 만 무시. 넉백 무적·껍질·보스 피해상한은 무시 못함 |
| 껍질 `SHELL` | `shieldHp` 별도 필드. 초과분 본체 이월. 자연 넉백은 본체 HP 기준 |
| 벌떡 `REVIVE` | 부활 시 `hp=maxHp`, `consumedHpThresholds=0`. 처치 보상은 **최종 사망 1회만** |

### 10.2 `exclusiveGroup` (동일 계열 최강만 적용)

```dart
class StatModifier {
  final StatKey stat;
  final ModOp op;
  final int value;
  final ModifierSource source;
  final String? exclusiveGroup;   // 같은 그룹이면 value 절대값 최대인 것만 유효
}
```

`StatSheet.recompute()` 에서 `exclusiveGroup`별로 최댓값 1개만 선택한다.

---

## 11. 스킬 트리거 (기획서 6-6 구현)

```dart
enum TriggerKind {
  passive,        // 상시
  onNthAttack,    // N회 공격 완료
  onChance,       // 확률
  onHpThreshold,  // HP 임계 (생애 1회)
  onSpawn,        // 등장 (인스턴스 1회)
  onDeath,        // 사망 (최종 사망만)
  onWeatherState, // 날씨 상태일 때 (M2)
  onTagLevel,     // ★ 특정 태그 레벨 이상일 때
}
```

```dart
class SkillTriggerRunner {
  static void onAttackCompleted(BattleWorld w, BattleEntity e) { ... }
  static void onSpawn(BattleWorld w, BattleEntity e) { ... }
  static void onDeath(BattleWorld w, BattleEntity e, bool isFinal) { ... }
  static void onHpChanged(BattleWorld w, BattleEntity e, int before, int after) { ... }
  static void onTagsChanged(BattleWorld w, BattleEntity e) { ... }
}
```

- `onNthAttack`: **완료된 기본 공격 동작** 기준. 범위로 5명 맞혀도 1회. 넉백 취소는 증가 X.
- `onChance`: `chanceUnit: "PER_ATTACK" | "PER_TARGET"` 를 데이터로 구분. 기본 `PER_ATTACK`.
  판정은 `rng.stream(RngStream.skillProc).roll(p)`.
- `onHpThreshold`: **생애 1회**. `firedTriggers` 비트마스크로 관리.
- 캐릭터당 핵심 트리거는 1~2개로 제한 (데이터 검증 룰로 강제).

### 11.1 간절한 기도 (필살기)

```dart
void castUltimate(BattleWorld w) {
  if (w.ultimateStock <= 0) return;
  if (w.config.ultimateSealed) return;               // 필살기 봉인 기믹
  w.ultimateStock--;
  for (final e in w.entities.ordered) {
    if (e.side != Side.enemy || !e.isTargetable) continue;   // 넉백 중 무적 제외
    w.queueDamage(PendingDamage(
      targetId: e.id, sourceId: SOURCE_ULTIMATE,
      amount: ULT_DAMAGE,                            // 300
      kind: DamageKind.direct,
      causesForcedKb: true,
      forcedKbDistance: e.isBoss ? ULT_KB ~/ 2 : ULT_KB,
    ));
  }
  // 적 둥지는 대상 제외
  w.events.emit(UltimateCastEvent(w.tick));
}
```

---

## 12. 보스 등장 (기획서 6-9 구현)

```dart
enum BossTriggerState { pending, warning, spawned }

class BossTrigger {
  final String id;                 // 보스 둘이면 각각 독립 ID
  final BossTriggerCondition cond; // time | nestFirstHit | baseHpThreshold | enemyKilled
  BossTriggerState state = BossTriggerState.pending;
  int warningTicksLeft = 0;
  bool protectNestUntilBossDead = false;
}
```

```
pending → (조건 충족 틱에 단 1회) → warning
  · 그 타격이 둥지를 파괴할 피해라도 HP 1을 남기고 등장 보호(damageImmune=true)
  · warningTicks = 45
warning → (45틱 경과) → spawned
  · 보스 생성, damageImmune = false
  · 단, protectNestUntilBossDead 스테이지는 보스 사망까지 보호 유지
spawned → 종료 (재진입 없음)
```

- 다단히트/일격 피해/저장 복구에서도 **한 번만 등장**해야 한다 → `state` 를 `serialize()`에 포함.
- 동시 상한에 걸려 보스가 사라지지 않도록 **보스용 1칸 예약** (`UNIT_CAP - 1`을 일반 스폰 상한으로).
- 일반 적 스폰이 상한에 걸리면 최대 5초 대기 후 취소, 다음 정규 스폰은 유지.

---

## 13. 이벤트 (렌더/사운드 연결)

```dart
sealed class BattleEvent { final int tick; }

class SpawnEvent      extends BattleEvent { final int entityId; }
class AttackStartedEvent extends BattleEvent { final int entityId; }
class AttackFiredEvent   extends BattleEvent { final int entityId; final int? targetId; }
class DamageDealtEvent   extends BattleEvent { final int targetId, amount; final bool isCrit; }
class HealedEvent        extends BattleEvent { final int targetId, amount; }
class KnockbackStartEvent extends BattleEvent { final int entityId; final bool forced; }
class KnockbackEndEvent  extends BattleEvent { final int entityId; }
class StunnedEvent       extends BattleEvent { final int entityId; final int ticks; }
class DeathEvent         extends BattleEvent { final int entityId; }
class TagLevelChangedEvent extends BattleEvent { final int entityId, tagIndex, level; }
class RelationActivatedEvent extends BattleEvent { final int entityId; final String ruleId; }
class RelationDeactivatedEvent extends BattleEvent { final int entityId; final String ruleId; }
class WeatherChangedEvent extends BattleEvent { final WeatherState from, to; }
class BossWarningEvent   extends BattleEvent {}
class BossSpawnedEvent   extends BattleEvent { final int entityId; }
class UltimateCastEvent  extends BattleEvent {}
class BaseDamagedEvent   extends BattleEvent { final Side side; final int amount, hpLeft; }
class BattleEndedEvent   extends BattleEvent { final BattleOutcome outcome; }
```

- 이벤트는 **전투 로직에 영향을 주지 않는다** (순수 알림). 렌더가 구독을 끊어도 시뮬은 동일.
- `EventFlushSystem`이 틱 종료 시 `List<BattleEvent>`를 뷰모델로 넘기고 버퍼를 비운다.

---

## 14. 입력 로그와 리플레이

```dart
sealed class BattleInput { final int tick; }
class SummonInput     extends BattleInput { final int slotIndex; }
class UltimateInput   extends BattleInput {}
class FocusBoostInput extends BattleInput { final int stage; }
class PageSwitchInput extends BattleInput { final int page; }   // 편성 2페이지 전환

class InputLog {
  final int seed;
  final String dataVersion;
  final String stageId;
  final List<BattleInput> inputs;      // tick 오름차순
  final String formationHash;

  /// 서버 제출용 압축 인코딩 (varint delta)
  Uint8List encode();
}
```

- 리플레이 = `BattleWorld(config, seed)` 새로 만들고 `InputLog` 재생.
- `test/battle/golden_replay/` 에 실제 플레이 로그를 골든 파일로 저장해 회귀 테스트.
- 밸런스 수정 후 골든 리플레이 결과가 바뀌면 **의도한 변경인지 확인**하고 골든 갱신.

---

## 15. 헤드리스 밸런스 도구

```bash
# 단일 전투 시뮬
dart run tool/headless_sim.dart --stage STG_1_10 --formation preset_a.json --seed 12345 -v

# 편성 조합 스윕: 승률/전선위치/클리어시간/소환수 집계
dart run tool/balance_sweep.dart \
  --stage STG_1_10 --trials 200 \
  --formations formations/*.json \
  --weather on,off \
  --out reports/stage_1_10.csv
```

출력 컬럼: `formationId, weather, winRate, avgClearSec, avgSummons, avgFrontlineX, p95ClearSec, deathsPerMin`

기획서 §12 검증 항목 중 다음을 이 도구로 자동화한다.
- 저비용 벽 / 원거리 / 범위 / 교란 편성 비교
- 해·달·들·혼합 편성의 날씨 켬·끔 비교
- 태그 시너지 티어 진입 전/후 비교 (**신규**)

---

## 16. 성능 목표

| 항목 | 목표 |
|---|---|
| 유닛 80개(아군40+적40) 동시 | 1틱 처리 ≤ 1.5ms (중저가 안드로이드) |
| 렌더 | 60fps 유지, 스파이크 없음 |
| 메모리 | 전투 중 힙 증가 ≤ 40MB, 틱당 신규 할당 ≈ 0 |
| 2배속 | 1틱 처리 시간 동일 (틱을 2번 밟을 뿐) |

**틱당 할당 0에 가깝게 만드는 방법**
- `PendingDamage`, `StatModifier`, `EffectInstance` 는 오브젝트 풀 재사용
- 매 틱 `List` 새로 만들지 않기. `world.scratchBuffer` 재사용
- `entities.ordered` 는 스폰/사망 시에만 재정렬
- 문자열 연결·로그는 `assert()` 안이나 debug 플래그 뒤로
