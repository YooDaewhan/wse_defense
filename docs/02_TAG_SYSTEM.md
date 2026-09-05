# 02. 태그 시스템 (Tag System)

> 이 게임의 성장·편성·전술의 중심 시스템.
> **종족 / 속성 / 기질 / 체격 / 특성 / 역할**을 전부 하나의 `Tag` 타입으로 통일하고,
> 태그마다 **레벨**을 두어 누적·강화되도록 한다.
> 데이터만 추가하면 새 태그·새 효과가 붙고, 지우면 깔끔히 사라지는 구조를 목표로 한다.

---

## 1. 핵심 개념 4가지

| 개념 | 설명 |
|---|---|
| **Tag** | 문자열 ID를 가진 분류표. `TAG_RACE_ANIMAL`, `TAG_ELEM_FIRE`, `TAG_TRAIT_CHUBBY` |
| **TagLevel** | 태그가 얼마나 쌓였는지. 정수. 같은 태그를 여러 출처에서 받으면 **합산** |
| **TagScope** | 그 레벨을 **어느 범위**에서 세느냐. `UNIT` / `FORMATION` / `FIELD` |
| **TagEffect** | 특정 스코프의 태그 레벨이 조건을 만족할 때 **누구에게 어떤 스탯 변화**를 주는지 |

### 요청하신 예시가 시스템에 어떻게 대응되는가

| 원하신 동작 | 시스템 표현 |
|---|---|
| "동물Lv1, 불Lv1, 통통함Lv1 인 캐릭터" | 캐릭터 정의의 `intrinsicTags: {RACE_ANIMAL:1, ELEM_FIRE:1, TRAIT_CHUBBY:1}` |
| "버프로 통통함을 받으면 통통함Lv2" | 런타임 `TagContribution(scope: UNIT, tag: TRAIT_CHUBBY, +1, source: buff)` → 유닛 스코프 합계 2 |
| "통통함Lv1 : 최대체력 +5%" | `TagEffect(scope: UNIT, target: SELF, perLevel: [MAX_HP PCT_ADD +5%])` → Lv2면 +10% |
| "동물 태그 3개 → 동물Lv3 : 동물계열 공격력 2% 방어력 2%" | `TagEffect(scope: FORMATION, tag: RACE_ANIMAL, tiers:[{minLevel:3, target:{hasTags:[RACE_ANIMAL]}, mods:[ATK+2%, DEF+2%]}])` |
| "신족 캐릭터가 동물탈(동물Lv1) 장착 → 팀 동물Lv4" | 장비의 `grantTags: {RACE_ANIMAL: 1}` 이 **유닛 스코프 태그를 올리고**, 팀 스코프는 유닛 스코프의 합이므로 자동으로 3→4 |
| "겁쟁이는 용감이 앞에 있으면 이동속도 느려짐" | `TagRelationRule(subject: 겁쟁이, other: 용감, relation: OTHER_IS_AHEAD, mods:[MOVE_SPEED −25%])` |

---

## 2. 태그 스코프 (가장 중요한 부분)

```
UNIT       개체 1명의 태그 레벨.
           = 고유태그 + 장비부여태그 + 스킬/버프로 받은 태그
           예: "이 곰은 지금 통통함Lv2"

FORMATION  편성 10칸 전체 기준 팀 태그 레벨. 전투 시작 시 1회 계산되고 전투 내내 고정.
           = Σ(편성된 모든 캐릭터의 UNIT 스코프 태그 레벨)   ※ 장비 포함, 런타임 버프 미포함
           예: "이 편성은 동물Lv4"

FIELD      지금 전장에 살아있는 아군(또는 적) 기준 태그 레벨. 2초마다 재계산.
           = Σ(살아있는 같은 편 유닛의 UNIT 스코프 태그 레벨)
           예: "지금 필드에 무리Lv5" → 무리 시너지 발동
```

### 2.1 왜 FORMATION과 FIELD를 나누는가

- **FORMATION**: 편성 화면에서 미리 보여줄 수 있다. 전투 전 계획의 재미. 기획서의
  "전투 전 전투편성때 오를 수 있는" 케이스가 이것.
- **FIELD**: 소환 순서·타이밍으로 실시간 변한다. "동물을 3마리 이상 깔면 강해진다" 같은
  운영형 시너지. 소환 전략과 직결.

같은 태그가 두 스코프의 효과를 동시에 가질 수 있다 (별개의 `TagEffect` 두 개).

### 2.2 팀 태그 레벨 계산 규칙

```
teamLevel(tag, scope) = clamp( Σ over units of unitLevel(tag, unit), 0, tagDef.maxTeamLevel )
```

- 한 캐릭터가 `RACE_ANIMAL: 2` 를 고유로 가지면 팀에 **2**를 기여한다 (거대 동물 컨셉).
- 장비로 받은 태그도 UNIT 레벨에 포함되므로 팀 기여에 포함된다. → **요청하신 동물탈 케이스**
- **런타임 버프로 받은 태그는 FORMATION에 포함되지 않는다.** (전투 전 확정값이어야 하므로)
  단 FIELD 스코프에는 포함된다 (다음 갱신 주기부터).

### 2.3 해석 순서와 순환 방지

태그가 효과를 주고, 효과가 다시 태그를 준다면 무한 루프가 난다. **패스를 고정한다.**

```
PASS 0  intrinsicTags + equipment.grantTags  ─────────────► unitTagLevel (확정)
PASS 1  unitTagLevel 합산 ─────────────────────────────► formationTagLevel (전투 시작 시 1회)
PASS 2  formationTagLevel/fieldTagLevel + unitTagLevel 로
        모든 TagEffect 평가 → StatModifier 생성
PASS 3  런타임 버프가 부여한 태그(TagContribution)는 unitTagLevel에 더해지되,
        FIELD 스코프 반영은 다음 갱신 주기(2초)부터.
        FORMATION 스코프는 절대 변하지 않는다.
```

- **TagEffect는 태그를 부여할 수 없다** (`mods`만 가능). 태그 부여는 `grantTags`(장비)와
  `EffectHandler`(스킬/버프)만 할 수 있다. → 순환 원천 차단.
- 스킬이 태그를 부여할 때는 반드시 지속시간(`durationTicks`)이 있거나 전투 종료까지 유지.

---

## 3. 데이터 모델

### 3.1 TagDef

```jsonc
// assets/data/v1/tags.json
{
  "tags": [
    {
      "id": "TAG_RACE_ANIMAL",
      "category": "RACE",          // RACE | ELEMENT | TEMPER | BUILD | TRAIT | ROLE | HABIT
      "nameKey": "tag.race.animal",
      "iconKey": "tag_race_animal",
      "maxUnitLevel": 5,
      "maxTeamLevel": 20,
      "hiddenUntilChapter": 0,     // UI 노출 시점(학습 부담 조절)
      "sortOrder": 100
    }
  ]
}
```

```dart
// lib/battle/tag/tag_def.dart
class TagDef {
  final String id;
  final TagCategory category;
  final int maxUnitLevel;   // 기본 5
  final int maxTeamLevel;   // 기본 20
  final int sortOrder;
}

enum TagCategory { race, element, temper, build, trait, role, habit }
```

### 3.2 TagStack (런타임 보관)

```dart
/// 한 유닛의 태그 레벨 집합. 결정론을 위해 정렬된 배열로 보관.
class TagStack {
  final List<int> _tagIndex;   // TagRegistry의 인덱스, 오름차순 정렬
  final List<int> _levels;     // _tagIndex와 같은 길이

  int levelOf(int tagIndex);          // 없으면 0
  bool has(int tagIndex) => levelOf(tagIndex) > 0;
  void add(int tagIndex, int delta);  // clamp(0, maxUnitLevel)
  Iterable<(int tag, int level)> entries();
}
```

> `String` 대신 **정수 인덱스**로 다루는 이유: 매 틱 수백 번 조회되므로 문자열 해시 비용을 없애고,
> 순회 순서를 배열 순서로 고정해 결정론을 확보하기 위함.
> `TagRegistry`가 로딩 시 `String id ↔ int index` 양방향 맵을 구축한다.

### 3.3 TagContribution (태그가 어디서 왔는지)

```dart
class TagContribution {
  final int tagIndex;
  final int amount;              // 보통 +1
  final TagSourceKind kind;      // intrinsic | equipment | skill | buff | stage
  final String sourceId;         // "EQP_ANIMAL_MASK", "SKL_BEAR_ROAR"
  final int? expireTick;         // null이면 영구
}

enum TagSourceKind { intrinsic, equipment, skill, buff, stage }
```

유닛은 `List<TagContribution>` 을 들고 있고, `TagStack`은 이를 합산한 캐시다.
버프 만료 시 해당 contribution을 제거하고 스택을 재계산 → **추가/제거가 대칭적**.

### 3.4 TagQuery (누구를 고를 것인가)

```jsonc
{
  "side": "SAME",                       // SAME | ENEMY | ANY  (기준: 효과의 소유자)
  "hasTags": ["TAG_RACE_ANIMAL"],       // 전부 보유 (AND)
  "anyTags": ["TAG_ELEM_FIRE", "TAG_ELEM_WIND"],  // 하나라도 (OR)
  "notTags": ["TAG_TRAIT_OLD"],
  "minTagLevel": { "TAG_RACE_ANIMAL": 2 },
  "roles": ["ROLE_ATTACKER"],
  "aliveOnly": true,
  "excludeKnockback": true,             // 넉백 중 유닛 제외
  "limit": 0,                           // 0 = 무제한
  "sort": "NEAREST"                     // NEAREST | FARTHEST | LOWEST_HP | ENTITY_ID
}
```

```dart
class TagQuery {
  bool matches(BattleEntity e, BattleEntity owner, BattleWorld w);
  List<BattleEntity> select(BattleWorld w, BattleEntity owner);
}
```

`limit`이 있고 동점이면 **entityId 오름차순**으로 자른다 (결정론).

### 3.5 TagEffect

```jsonc
// assets/data/v1/tag_effects.json
{
  "effects": [
    // (A) 유닛 스코프 · 레벨 비례
    {
      "id": "TEF_CHUBBY",
      "tag": "TAG_TRAIT_CHUBBY",
      "scope": "UNIT",
      "target": "SELF",
      "mode": "PER_LEVEL",
      "perLevel": [
        { "stat": "MAX_HP", "op": "PCT_ADD", "value": 5000 }   // +5% per level
      ],
      "levelCapForEffect": 5,
      "descKey": "tef.chubby"
    },

    // (B) 편성 스코프 · 구간(티어)
    {
      "id": "TEF_ANIMAL_TEAM",
      "tag": "TAG_RACE_ANIMAL",
      "scope": "FORMATION",
      "mode": "TIER",
      "tierMode": "HIGHEST",             // HIGHEST | CUMULATIVE
      "target": { "side": "SAME", "hasTags": ["TAG_RACE_ANIMAL"] },
      "tiers": [
        { "minLevel": 3,  "mods": [ {"stat":"ATK","op":"PCT_ADD","value":2000},
                                    {"stat":"DEF","op":"PCT_ADD","value":2000} ] },
        { "minLevel": 6,  "mods": [ {"stat":"ATK","op":"PCT_ADD","value":5000},
                                    {"stat":"DEF","op":"PCT_ADD","value":5000} ] },
        { "minLevel": 10, "mods": [ {"stat":"ATK","op":"PCT_ADD","value":9000},
                                    {"stat":"DEF","op":"PCT_ADD","value":9000},
                                    {"stat":"MOVE_SPEED","op":"PCT_ADD","value":5000} ] }
      ]
    },

    // (C) 필드 스코프 · 조건부
    {
      "id": "TEF_HERD_FIELD",
      "tag": "TAG_TRAIT_HERD",
      "scope": "FIELD",
      "mode": "TIER",
      "tierMode": "HIGHEST",
      "target": { "side": "SAME", "hasTags": ["TAG_TRAIT_HERD"] },
      "tiers": [
        { "minLevel": 3, "mods": [ {"stat":"ATK","op":"PCT_ADD","value":4000} ] },
        { "minLevel": 5, "mods": [ {"stat":"ATK","op":"PCT_ADD","value":8000},
                                   {"stat":"KNOCKBACK_RESIST","op":"FLAT_ADD","value":1} ] }
      ]
    },

    // (D) 상성: 속성 태그가 적에게 주는 피해 배율
    {
      "id": "TEF_FIRE_VS_WOOD",
      "tag": "TAG_ELEM_FIRE",
      "scope": "UNIT",
      "mode": "PER_LEVEL",
      "target": "SELF",
      "perLevel": [
        { "stat": "DMG_DEALT_VS", "op": "PCT_ADD", "value": 8000,
          "vs": { "hasTags": ["TAG_ELEM_WOOD"] } }
      ]
    }
  ]
}
```

```dart
class TagEffectDef {
  final String id;
  final int tagIndex;
  final TagScope scope;          // unit | formation | field
  final TagEffectMode mode;      // perLevel | tier
  final TierMode tierMode;
  final TagQuery? target;        // null이면 SELF
  final List<StatModDef> perLevel;
  final List<TagEffectTier> tiers;
  final int levelCapForEffect;
}
```

### 3.6 StatModDef (스탯 변경)

```jsonc
{ "stat": "ATK", "op": "PCT_ADD", "value": 2000, "vs": { /* TagQuery, 선택 */ } }
```

| op | 의미 | 합산 방식 |
|---|---|---|
| `FLAT_ADD` | 기본값에 정수 가산 | 모두 합산 |
| `PCT_ADD` | 퍼센트 가산 (밀리퍼센트) | 모두 합산 후 한 번에 적용 |
| `MULT` | 곱연산 | 각각 곱 |
| `SET_MIN` / `SET_MAX` | 하한/상한 클램프 | 마지막에 적용 |

**최종 계산식**
```
final = clamp( (base + ΣFLAT_ADD) * (PCT_SCALE + ΣPCT_ADD) / PCT_SCALE * Π(MULT) , min, max )
```
정수 연산이므로 각 곱마다 `~/ PCT_SCALE` 로 즉시 축소한다.

`vs` 가 있으면 상시 스탯이 아니라 **피해 계산 시점에 대상 조건을 검사**하는 조건부 모디파이어다
(`DMG_DEALT_VS`, `DMG_TAKEN_FROM`에만 사용).

### 3.7 StatKey 전체 목록

```dart
enum StatKey {
  maxHp,              // 최대 HP
  atk,                // 공격력
  def,                // 피해 감소율(밀리퍼센트). 방어력 개념
  attackPeriod,       // 공격 주기 P (틱). 낮을수록 빠름
  attackWindup,       // 발동 A (틱)
  attackRange,        // 사거리
  moveSpeed,          // 이동속도
  hpSegments,         // HP 구간 수 K
  knockbackResist,    // 강제 넉백 저항 단계
  knockbackDistance,  // 자신이 밀리는 거리
  summonCost,         // 소환 비용
  resummonCooldown,   // 재소환 대기
  healPower,          // 회복량
  healReceived,       // 받는 회복량
  dmgDealtVs,         // 조건부 주는 피해 (vs 필요)
  dmgTakenFrom,       // 조건부 받는 피해 (vs 필요)
  aoeMaxTargets,      // 범위 공격 최대 대상 수
  prayerGainOnKill,   // 처치 시 기도력 보너스
}
```

새 스탯 추가는 이 enum + `StatSheet` 의 base 소스 한 줄만 추가하면 된다.

---

## 4. 위치 관계 태그 (겁쟁이 / 용감)

### 4.1 요구사항 재확인

> 겁쟁이는 **용감이 앞에 있을 때** 이동속도 느려짐
> 용감은 **겁쟁이가 뒤에 있을 때** 이동속도 빨라짐

→ 소환 **순서**와 **타이밍**이 곧 위치를 만들고, 위치가 스탯을 바꾼다.
플레이어가 "누구를 먼저 부르는가"로 전선 밀도를 조종하게 되는 메커니즘.

### 4.2 "앞/뒤"의 정의

```dart
/// 아군은 오른쪽(+x)이 전진 방향, 적은 왼쪽(−x)이 전진 방향.
int facingSign(Side s) => s == Side.ally ? 1 : -1;

/// other가 subject보다 '앞'에 있는가 (subject 기준 전진 방향으로 더 나아갔는가)
bool isAhead(BattleEntity subject, BattleEntity other) =>
    (other.x - subject.x) * facingSign(subject.side) > 0;
```

거리는 항상 `(other.x - subject.x).abs()` 의 논리 단위 값을 쓴다.

### 4.3 TagRelationRule 스키마

```jsonc
// assets/data/v1/tag_relations.json
{
  "rules": [
    {
      "id": "TRL_COWARD_SLOWED_BY_BRAVE_AHEAD",
      "nameKey": "rel.coward.slow",
      "subject": { "side": "SAME", "hasTags": ["TAG_TRAIT_COWARD"], "aliveOnly": true },
      "other":   { "side": "SAME", "hasTags": ["TAG_TRAIT_BRAVE"],  "aliveOnly": true },
      "relation": "OTHER_IS_AHEAD",       // 아래 표 참조
      "rangeMin": 0,
      "rangeMax": 400,                    // 논리 단위. 0이면 무제한
      "requireCount": 1,                  // 조건을 만족하는 other 최소 수
      "scaleByOtherCount": false,
      "scaleBySubjectTagLevel": true,     // 겁쟁이Lv2면 효과 2배
      "mods": [ { "stat": "MOVE_SPEED", "op": "PCT_ADD", "value": -25000 } ],
      "minActiveTicks": 30,               // 한 번 켜지면 최소 1초 유지 (진동 방지)
      "offDelayTicks": 12,                // 조건 해제 후 0.4초 뒤 실제 해제
      "vfxKey": "rel_coward_sweat"
    },
    {
      "id": "TRL_BRAVE_BOOSTED_BY_COWARD_BEHIND",
      "subject": { "side": "SAME", "hasTags": ["TAG_TRAIT_BRAVE"] },
      "other":   { "side": "SAME", "hasTags": ["TAG_TRAIT_COWARD"] },
      "relation": "OTHER_IS_BEHIND",
      "rangeMax": 400,
      "requireCount": 1,
      "scaleByOtherCount": true,
      "maxScale": 3,
      "mods": [ { "stat": "MOVE_SPEED", "op": "PCT_ADD", "value": 12000 } ],
      "minActiveTicks": 30,
      "offDelayTicks": 12,
      "vfxKey": "rel_brave_flame"
    }
  ]
}
```

### 4.4 relation 종류

| relation | 조건 |
|---|---|
| `OTHER_IS_AHEAD` | other가 subject보다 전진 방향으로 앞 |
| `OTHER_IS_BEHIND` | other가 subject보다 뒤 |
| `OTHER_IS_ADJACENT` | 앞뒤 무관, 거리 `rangeMax` 이내 |
| `OTHER_IS_FRONTMOST` | 같은 편에서 가장 앞선 유닛이 other 조건을 만족 |
| `SUBJECT_IS_FRONTMOST` | subject 자신이 최전방일 때 |
| `SUBJECT_IS_REARMOST` | subject 자신이 최후방일 때 |
| `NO_OTHER_AHEAD` | 앞에 other 조건 유닛이 하나도 없음 (고립/선봉 컨셉) |
| `ENEMY_WITHIN` | 적 진영에서 other 조건을 만족하는 유닛이 범위 내 |

이 목록은 `RelationKind` enum 하나로 관리하고, `RelationEvaluator` 에 case를 추가하면
새 관계가 늘어난다. **데이터에서 새 규칙을 만드는 데는 코드 수정이 필요 없다.**

### 4.5 평가 주기와 진동 방지

```dart
const int RELATION_SAMPLE_TICKS = 6;  // 0.2초마다 재평가
```

```
매 RELATION_SAMPLE_TICKS 마다:
  for each rule (rules 리스트 순서 고정):
    subjects = rule.subject.select(world)        // entityId 오름차순
    for each subject:
      matched = count of others satisfying (rule.other ∧ relation ∧ range)
      wantActive = matched >= rule.requireCount
      state = subject.relationState[rule.id]

      if wantActive:
         state.offCounter = 0
         if !state.active: state.active = true; state.activeSince = tick
         state.scale = computeScale(rule, matched, subject)
      else:
         if state.active:
            if (tick - state.activeSince) < rule.minActiveTicks: keep active
            else:
               state.offCounter += RELATION_SAMPLE_TICKS
               if state.offCounter >= rule.offDelayTicks: state.active = false

      applyOrRemoveModifiers(subject, rule, state)
```

- `minActiveTicks` 로 **최소 유지 시간**, `offDelayTicks` 로 **해제 지연**을 둔다.
  두 장치가 없으면 겁쟁이가 느려짐↔빨라짐을 0.2초마다 반복해 애니메이션이 떨린다.
- 모디파이어는 `ModifierSource(kind: relation, id: rule.id)` 로 태깅해서 **통째로 제거** 가능.

### 4.6 성능

- subject/other 후보는 매 샘플마다 전수 검색하면 O(rules × N²).
  N=80(아군40+적40), rules=20 이면 0.2초마다 128,000회 → 모바일에서도 여유.
- 최적화가 필요해지면 `x` 정렬 배열 + 이분 탐색으로 range 윈도우를 잘라 O(rules × N × k)로 낮춘다.
  (M1에서는 전수 검색으로 시작. 조기 최적화 금지.)

### 4.7 UI 표현

- 전투 중: 관계가 활성화되면 유닛 발밑에 작은 아이콘(식은땀 / 불꽃)과 이동속도 화살표.
- 편성 화면: "이 편성에는 겁쟁이 2, 용감 1이 있습니다. 용감을 먼저 소환하면 겁쟁이가 느려집니다."
  같은 **예고 문구**를 규칙 `nameKey`로 자동 생성.
- 캐릭터 상세: 보유 태그 칩 + 해당 태그가 걸리는 관계 규칙 목록.

---

## 5. 장비와 태그

### 5.1 장비 정의 확장

```jsonc
// assets/data/v1/equipments.json
{
  "equipments": [
    {
      "id": "EQP_ANIMAL_MASK",
      "nameKey": "eqp.animal_mask",         // 동물탈
      "rarity": 3,
      "slot": "GEAR",                        // 친구별 1슬롯
      "equipCondition": { "notTags": [] },   // TagQuery로 장착 제한 가능
      "grantTags": { "TAG_RACE_ANIMAL": 1 }, // ★ 태그 부여
      "mods": [ { "stat": "MAX_HP", "op": "PCT_ADD", "value": 4000 } ],
      "enhance": {
        "maxLevel": 10,
        "perLevel": [ { "stat": "MAX_HP", "op": "PCT_ADD", "value": 800 } ],
        "grantTagAtLevel": { "5": { "TAG_RACE_ANIMAL": 1 } }  // +5강에서 동물Lv 추가 +1
      },
      "visualKey": "gear_animal_mask",       // 캐릭터에 실제로 그려지는 파츠
      "sourceKey": "dungeon.mon_thu.d4"
    },
    {
      "id": "EQP_BRAVE_BADGE",
      "nameKey": "eqp.brave_badge",
      "grantTags": { "TAG_TRAIT_BRAVE": 1 },
      "mods": [ { "stat": "ATK", "op": "PCT_ADD", "value": 6000 } ]
    },
    {
      "id": "EQP_EMBER_CHARM",
      "nameKey": "eqp.ember_charm",
      "grantTags": { "TAG_ELEM_FIRE": 1 },
      "mods": [ { "stat": "ATK", "op": "PCT_ADD", "value": 5000 } ]
    }
  ]
}
```

### 5.2 장비 태그가 만드는 설계 공간

- **시너지 진입권**: 동물 2명뿐인 편성에 동물탈 하나로 동물Lv3 티어를 연다.
- **속성 전환**: 불Lv0 캐릭터에 불 부적을 달아 불 시너지에 편입.
- **관계 조작**: 겁쟁이 캐릭터에 용감 뱃지를 달아 관계 규칙 자체를 바꾼다.
  (겁쟁이+용감을 동시에 가지면? → §6.3 상충 규칙 참조)
- **요일던전 보상 설계와 직결**: 어떤 태그를 열어주는 장비를 어느 던전에 넣느냐가
  곧 "이번 주에 무엇을 파밍할 이유"가 된다. → `07_DUNGEON_EXCHANGE.md`

### 5.3 강화와 태그

- 장비 강화 +5, +10 같은 마일스톤에서 태그 레벨 +1을 주면 강화 동기가 명확해진다.
- 태그를 주는 강화 단계는 **UI에 반드시 사전 표시**한다.

---

## 6. 시작 태그 카탈로그

> M1은 굵게 표시한 것만 노출한다. 나머지는 데이터에 존재하되 `hiddenUntilChapter`로 잠근다.

### 6.1 RACE (종족) — 캐릭터당 1~2개

| ID | 이름 | 컨셉 |
|---|---|---|
| **`TAG_RACE_ANIMAL`** | 동물 | 숲의 친구들 다수. 기본 시너지 축 |
| **`TAG_RACE_PLANT`** | 식물 | 버섯, 나무, 꽃 |
| `TAG_RACE_HUMAN` | 인간 | 소녀, 여행자, NPC 동료 |
| `TAG_RACE_SPIRIT` | 정령 | 물방울, 바람, 불씨 |
| `TAG_RACE_DIVINE` | 신 | 천계 계열. 후반 등장 |
| `TAG_RACE_DEMON` | 마족 | 악계 계열. 후반 등장 |
| `TAG_RACE_OBJECT` | 사물 | 도토리, 인형, 낡은 물건 |
| `TAG_RACE_YOKAI` | 요괴 | 이벤트/콜라보 슬롯 |

### 6.2 ELEMENT (속성)

| ID | 이름 | 상성(우세) |
|---|---|---|
| **`TAG_ELEM_FIRE`** | 불 | → 나무 |
| **`TAG_ELEM_WATER`** | 물 | → 불 |
| **`TAG_ELEM_WOOD`** | 나무 | → 물, 흙 |
| `TAG_ELEM_WIND` | 바람 | → 흙 |
| `TAG_ELEM_EARTH` | 흙 | → 불, 바람 |
| `TAG_ELEM_LIGHT` | 빛 | ↔ 어둠 (상호 우세) |
| `TAG_ELEM_DARK` | 어둠 | ↔ 빛 |

상성은 `TEF_*_VS_*` 태그 효과로 표현한다 (`DMG_DEALT_VS +8%`).
**상성 배율은 작게 시작**한다(8%). 편성 강요가 되면 재미가 줄기 때문.

### 6.3 HABIT (습성)

| ID | 이름 | 효과 방향 |
|---|---|---|
| **`TAG_HABIT_DIURNAL`** | 주행성 | 날씨 `맑음`일 때 강화 |
| **`TAG_HABIT_NOCTURNAL`** | 야행성 | 날씨 `밤`일 때 강화 |
| `TAG_HABIT_CREPUSCULAR` | 박명성 | 날씨 `노을`일 때 강화 |

> 기획서의 기질(해/달/들)은 **날씨 게이지를 미는 주체**이고,
> 습성은 **날씨 상태에서 이득을 보는 쪽**이다. 둘은 다른 축이며 조합이 생긴다.
> 예) 해 기질 + 야행성 = 자기가 만든 낮에서는 손해 → 팀 조합의 딜레마.

### 6.4 TEMPER (기질) — 캐릭터당 정확히 1개, 레벨 없음(항상 1)

| ID | 이름 |
|---|---|
| **`TAG_TEMPER_SUN`** | 해 |
| **`TAG_TEMPER_MOON`** | 달 |
| **`TAG_TEMPER_FIELD`** | 들 |

날씨 게이지 계산(`기획서 6-7`)은 이 태그를 읽어 `Ns/Nm/Nf`를 센다.
`WeatherSystem`이 태그 시스템을 소비하는 형태로 구현한다.

### 6.5 BUILD (체격)

| ID | 이름 | 기본 효과 (UNIT, PER_LEVEL) |
|---|---|---|
| **`TAG_BUILD_CHUBBY`** | 통통함 | `MAX_HP +5%` |
| **`TAG_BUILD_SMALL`** | 소동물 | `MOVE_SPEED +6%`, `SUMMON_COST −3%` |
| **`TAG_BUILD_LARGE`** | 커다람 | `MAX_HP +8%`, `KNOCKBACK_DISTANCE −10%`, `MOVE_SPEED −4%` |
| `TAG_BUILD_TINY` | 자그마함 | `MOVE_SPEED +10%`, `MAX_HP −5%` |

### 6.6 TRAIT (특성)

| ID | 이름 | 기본 효과 (UNIT, PER_LEVEL) |
|---|---|---|
| **`TAG_TRAIT_SWIFT`** | 재빠름 | `MOVE_SPEED +8%`, `ATTACK_PERIOD −3%` |
| **`TAG_TRAIT_FIERCE`** | 매서움 | `ATK +6%`, `MAX_HP −2%` |
| **`TAG_TRAIT_STURDY`** | 단단함 | `DEF +4%`, `KNOCKBACK_DISTANCE −15%` |
| **`TAG_TRAIT_WINGED`** | 날개 | `MOVE_SPEED +10%`, 특정 지형/근접 회피 규칙 |
| **`TAG_TRAIT_HERD`** | 무리 | FIELD 스코프 시너지 (§3.5 C) |
| `TAG_TRAIT_SLEEPY` | 잠꾸러기 | 등장 후 3초간 `ATK −30%`, 이후 `ATK +15%` |
| `TAG_TRAIT_SPIKY` | 뾰족함 | 근접 피격 시 반사 피해 |
| `TAG_TRAIT_OLD` | 낡음 | `SUMMON_COST −15%`, `MAX_HP −10%` |
| **`TAG_TRAIT_COWARD`** | 겁쟁이 | 관계 규칙 대상. 단독 효과: `SUMMON_COST −8%` |
| **`TAG_TRAIT_BRAVE`** | 용감 | 관계 규칙 대상. 단독 효과: `ATK +5%` |

**상충 규칙**: 같은 유닛이 `COWARD`와 `BRAVE`를 동시에 가지면?
→ `tags.json`의 `conflicts` 필드로 정의한다.

```jsonc
{
  "id": "TAG_TRAIT_COWARD",
  "conflicts": [
    { "with": "TAG_TRAIT_BRAVE", "resolve": "CANCEL_EQUAL" }
    // CANCEL_EQUAL: 두 태그 레벨을 같은 만큼 상쇄 (2 vs 1 → 1 vs 0)
    // HIGHER_WINS : 높은 쪽만 남기고 낮은 쪽 0
    // COEXIST     : 둘 다 유지 (관계 규칙이 둘 다 걸림)
  ]
}
```

상충 해석은 **PASS 0 직후** 1회 수행한다.

### 6.7 ROLE (역할) — 필터·시너지용

`TAG_ROLE_DEFENDER` / `TAG_ROLE_ATTACKER` / `TAG_ROLE_SUPPORT` / `TAG_ROLE_DISRUPTOR`

---

## 7. 기본 5종 캐릭터의 태그 배정 (기획서 6-8 연동)

| 친구 | 기질 | 종족 | 속성 | 체격 | 특성 | 역할 |
|---|---|---|---|---|---|---|
| 굴러다니는 도토리 | 들 | 사물, 식물 | 흙 | 자그마함 | 단단함, 무리 | 방어형 |
| 개울의 물방울 | 달 | 정령 | 물 | 소동물 | 재빠름 | 공격형 |
| 심술난 버섯 | 들 | 식물 | 나무 | 통통함 | 뾰족함, 겁쟁이 | 공격형 |
| 노래하는 새 | 해 | 동물 | 바람 | 소동물 | 날개, 재빠름 | 교란형 |
| 낮잠 자던 곰 | 달 | 동물 | 흙 | 커다람 | 잠꾸러기, 용감 | 방어형 |

> **주의:** 기획서 6-8의 최종 수치(HP/공격/P·A·R 등)는 **태그 효과 적용 전의 base 값이 아니라
> "태그가 적용된 뒤의 목표 체감치"** 다. 데이터 작업 시 다음 중 하나를 택한다.
>
> - **(권장) 방식 A** — 6-8 표를 그대로 `base`로 넣고, 위 태그의 기본 효과 수치를
>   전부 절반 이하로 낮춰 시작한다. 밸런스가 크게 흔들리지 않는다.
> - 방식 B — 태그 효과를 역산해 `base`를 낮춰 넣는다. 정확하지만 데이터 수정이 번거롭다.
>
> `tool/balance_sweep.dart`로 방식 A 적용 후 기본 5종의 DPS·생존시간이
> 기획서 값 대비 ±15% 안에 들어오는지 확인한다.

---

## 8. 해석 파이프라인 (구현 순서)

```dart
// lib/battle/tag/tag_effect_resolver.dart

class TagResolveResult {
  final List<StatModifier> mods;   // ModifierSource로 태깅됨
}

class TagEffectResolver {
  /// 전투 시작 시 1회.
  void resolveFormation(BattleWorld w) {
    // 1) 각 편성 캐릭터의 unitTagStack 구성 (intrinsic + equipment.grantTags)
    // 2) conflicts 해석
    // 3) formationTagLevels[tag] = Σ unitLevel
    // 4) scope==FORMATION 인 TagEffect 평가 → 대상 유닛에 영구 모디파이어 부여
    //    (아직 소환되지 않은 유닛에도 '소환 시 적용될 모디파이어 템플릿'으로 보관)
  }

  /// 유닛 소환 시 1회.
  void resolveUnitOnSpawn(BattleEntity e, BattleWorld w) {
    // scope==UNIT 인 TagEffect 평가 → e에 모디파이어 부여
    // formation 템플릿 모디파이어 적용
  }

  /// FIELD_SAMPLE_TICKS(60틱=2초)마다.
  void resolveField(BattleWorld w, Side side) {
    // fieldTagLevels 재계산 → scope==FIELD 효과 diff 적용
    // 변화 없는 태그는 건드리지 않는다 (모디파이어 재생성 최소화)
  }

  /// 유닛의 태그 스택이 바뀌었을 때 (버프 획득/만료, 장비 변경).
  void onUnitTagsChanged(BattleEntity e, BattleWorld w) {
    // scope==UNIT 효과만 재평가. FIELD는 다음 주기에 반영.
  }
}
```

```dart
const int FIELD_SAMPLE_TICKS = 60;    // 2초
const int RELATION_SAMPLE_TICKS = 6;  // 0.2초
```

### 8.1 모디파이어 출처 태깅 = "추가/제거 유연함"의 핵심

```dart
class ModifierSource {
  final ModifierKind kind;  // tagUnit | tagFormation | tagField | relation | skill | equipment | weather | stage
  final String id;          // "TEF_CHUBBY", "TRL_COWARD_SLOWED", "SKL_BEAR_ROAR"
  final int? instanceId;    // 같은 스킬 여러 인스턴스 구분
}

class StatSheet {
  void addModifier(StatModifier m);
  void removeBySource(ModifierKind kind, String id);   // ← 통째로 제거
  void removeByInstance(int instanceId);
  int get(StatKey k);       // 캐시 + dirty 플래그
}
```

이 한 가지 규칙 덕분에:
- 태그 효과를 데이터에서 지우면 → 다음 재평가에서 자동으로 사라진다.
- 버프가 만료되면 → `removeByInstance` 한 줄.
- 관계가 해제되면 → `removeBySource(relation, ruleId)` 한 줄.
- **어떤 기능도 다른 기능의 계산식을 직접 수정하지 않는다.**

---

## 9. 새 태그를 추가하는 절차 (체크리스트)

```
1. tags.json 에 TagDef 1개 추가 (id, category, maxUnitLevel, 아이콘 키)
2. tag_effects.json 에 TagEffect 추가 (UNIT / FORMATION / FIELD 중 필요한 것)
3. (선택) tag_relations.json 에 관계 규칙 추가
4. characters.json / equipments.json 에서 해당 태그를 부여
5. l10n ARB 에 nameKey, descKey 문자열 추가
6. assets/images/ui/tags/ 에 아이콘 1장 추가
7. tool/balance_sweep.dart 실행 → 승률 변화 확인
※ Dart 코드 수정 0줄
```

**코드 수정이 필요한 경우는 단 두 가지뿐이다.**
- 새로운 `StatKey`가 필요할 때
- 새로운 `RelationKind`가 필요할 때

---

## 10. 태그를 제거하는 절차

```
1. tags.json 에서 TagDef 삭제 또는 "deprecated": true
2. DatapackLoader가 로딩 시 존재하지 않는 태그 참조를 만나면
   → 경고 로그 후 무시 (크래시 금지). 이 관용성이 라이브 운영에서 필수.
3. 계정에 남아있는 장비의 grantTags 는 로딩 시 필터링
4. 대체 태그가 있으면 tags.json 의 "replacedBy" 로 마이그레이션
```

```jsonc
{ "id": "TAG_TRAIT_OLD", "deprecated": true, "replacedBy": "TAG_TRAIT_WORN" }
```

---

## 11. 검증 항목 (테스트로 고정)

- [ ] 동물 캐릭터 3명 편성 → `formationTagLevel[ANIMAL] == 3`
- [ ] 위 편성에 동물탈 장착 신족 1명 추가 → `== 4`, `TEF_ANIMAL_TEAM` 티어가 신족에게는
      적용되지 않음(대상 쿼리가 `hasTags:[ANIMAL]`이므로 동물탈 착용자는 **포함**됨)
- [ ] 통통함Lv1 유닛의 `MAX_HP` = base × 1.05, 버프로 Lv2 → base × 1.10
- [ ] 통통함 버프 만료 → 정확히 base × 1.05로 복귀 (부동소수 누적 오차 0)
- [ ] `MAX_HP`가 줄어들 때 현재 HP가 최대치를 넘지 않도록 클램프되고,
      **HP 임계(K) 소비 상태는 유지**된다 (넉백 무한 발동 방지)
- [ ] 겁쟁이 앞에 용감을 소환 → 0.2~0.4초 내 겁쟁이 이동속도 −25%
- [ ] 용감이 죽으면 `minActiveTicks` 경과 후 겁쟁이 속도 복귀
- [ ] 관계 규칙이 1초에 3회 이상 on/off 토글되지 않음 (진동 방지 검증)
- [ ] 같은 시드·같은 입력 → 태그 해석 결과 체크섬 동일
- [ ] `tags.json`에서 태그 1개를 제거해도 앱이 크래시하지 않음
