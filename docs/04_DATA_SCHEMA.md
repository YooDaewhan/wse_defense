# 04. 데이터 스키마

> 모든 게임 데이터는 `assets/data/v{N}/` 아래 JSON. 앱 빌드에 포함(오프라인 시작 보장)하고,
> 원격 데이터팩으로 덮어쓸 수 있게 한다. `dataVersion` 문자열이 전투 검증 키의 일부다.

---

## 1. 데이터팩 구조

```
assets/data/v1/
├─ manifest.json          # 버전, 파일 목록, 각 파일 sha256
├─ tags.json
├─ tag_effects.json
├─ tag_relations.json
├─ characters.json
├─ skills.json
├─ enemies.json
├─ equipments.json
├─ growth.json
├─ weather.json
├─ dungeons.json
├─ exchange.json
├─ items.json
├─ banners.json
├─ stages/
│  ├─ chapter_1.json
│  ├─ chapter_2.json
│  └─ chapter_3.json
└─ story/
   ├─ prologue.json
   └─ chapter_1.json
```

```jsonc
// manifest.json
{
  "dataVersion": "1.0.7",
  "minAppVersion": "1.0.0",
  "files": [
    { "path": "tags.json", "sha256": "..." },
    { "path": "characters.json", "sha256": "..." }
  ]
}
```

```dart
class DatapackLoader {
  /// 1. 로컬 캐시(Hive)의 dataVersion 확인
  /// 2. Firestore gameData/current 의 dataVersion 비교
  /// 3. 다르면 Cloud Storage에서 파일 다운로드 → sha256 검증 → 캐시 저장
  /// 4. 실패 시 번들 데이터로 폴백 (앱은 항상 실행되어야 한다)
  Future<Datapack> load();
}
```

**관용성 규칙 (라이브 운영 필수)**
- 알 수 없는 필드 → 무시
- 존재하지 않는 ID 참조 → 경고 로그 + 해당 항목만 스킵. **크래시 금지**
- `deprecated: true` 항목 → 로딩하되 UI 노출 제외

---

## 2. tags.json

```jsonc
{
  "$schema": "tags",
  "tags": [
    {
      "id": "TAG_RACE_ANIMAL",
      "category": "RACE",
      "nameKey": "tag.race.animal",
      "descKey": "tag.race.animal.desc",
      "iconKey": "tag_race_animal",
      "colorHex": "#C08A4A",
      "maxUnitLevel": 5,
      "maxTeamLevel": 20,
      "hiddenUntilChapter": 0,
      "sortOrder": 100,
      "conflicts": [],
      "deprecated": false
    },
    {
      "id": "TAG_TRAIT_COWARD",
      "category": "TRAIT",
      "nameKey": "tag.trait.coward",
      "iconKey": "tag_trait_coward",
      "maxUnitLevel": 3,
      "maxTeamLevel": 10,
      "sortOrder": 610,
      "conflicts": [ { "with": "TAG_TRAIT_BRAVE", "resolve": "CANCEL_EQUAL" } ]
    }
  ]
}
```

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `id` | string | O | `TAG_<CATEGORY>_<NAME>` |
| `category` | enum | O | RACE, ELEMENT, TEMPER, BUILD, TRAIT, ROLE, HABIT |
| `maxUnitLevel` | int | — | 기본 5 |
| `maxTeamLevel` | int | — | 기본 20 |
| `hiddenUntilChapter` | int | — | 0=항상 노출 |
| `conflicts[].resolve` | enum | — | CANCEL_EQUAL, HIGHER_WINS, COEXIST |
| `replacedBy` | string | — | 마이그레이션 대상 태그 |

---

## 3. tag_effects.json

```jsonc
{
  "effects": [
    {
      "id": "TEF_CHUBBY",
      "tag": "TAG_BUILD_CHUBBY",
      "scope": "UNIT",                  // UNIT | FORMATION | FIELD
      "mode": "PER_LEVEL",              // PER_LEVEL | TIER
      "target": "SELF",                 // "SELF" 또는 TagQuery 객체
      "levelCapForEffect": 5,
      "perLevel": [
        { "stat": "MAX_HP", "op": "PCT_ADD", "value": 5000 }
      ],
      "descKey": "tef.chubby",
      "hiddenUntilChapter": 0
    },
    {
      "id": "TEF_ANIMAL_TEAM",
      "tag": "TAG_RACE_ANIMAL",
      "scope": "FORMATION",
      "mode": "TIER",
      "tierMode": "HIGHEST",            // HIGHEST | CUMULATIVE
      "target": { "side": "SAME", "hasTags": ["TAG_RACE_ANIMAL"] },
      "tiers": [
        { "minLevel": 3,  "mods": [{"stat":"ATK","op":"PCT_ADD","value":2000},
                                   {"stat":"DEF","op":"PCT_ADD","value":2000}] },
        { "minLevel": 6,  "mods": [{"stat":"ATK","op":"PCT_ADD","value":5000},
                                   {"stat":"DEF","op":"PCT_ADD","value":5000}] },
        { "minLevel": 10, "mods": [{"stat":"ATK","op":"PCT_ADD","value":9000},
                                   {"stat":"DEF","op":"PCT_ADD","value":9000},
                                   {"stat":"MOVE_SPEED","op":"PCT_ADD","value":5000}] }
      ],
      "descKey": "tef.animal.team"
    },
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
    },
    {
      "id": "TEF_NOCTURNAL_NIGHT",
      "tag": "TAG_HABIT_NOCTURNAL",
      "scope": "UNIT",
      "mode": "PER_LEVEL",
      "target": "SELF",
      "requireWeather": ["NIGHT"],       // 날씨 조건부 (M2)
      "perLevel": [
        { "stat": "ATK", "op": "PCT_ADD", "value": 10000 },
        { "stat": "MOVE_SPEED", "op": "PCT_ADD", "value": 6000 }
      ]
    }
  ]
}
```

### 3.1 StatModDef

```jsonc
{
  "stat": "ATK",
  "op": "PCT_ADD",           // FLAT_ADD | PCT_ADD | MULT | SET_MIN | SET_MAX
  "value": 2000,             // PCT_*는 밀리퍼센트 (2000 = 2%)
  "vs": { /* TagQuery */ },  // DMG_DEALT_VS / DMG_TAKEN_FROM 에만
  "exclusiveGroup": "ATK_DOWN"  // 같은 그룹은 절대값 최대 1개만 적용
}
```

### 3.2 StatKey 문자열 ↔ enum 매핑

| JSON | Dart |
|---|---|
| `MAX_HP` | `StatKey.maxHp` |
| `ATK` | `StatKey.atk` |
| `DEF` | `StatKey.def` |
| `ATTACK_PERIOD` | `StatKey.attackPeriod` |
| `ATTACK_WINDUP` | `StatKey.attackWindup` |
| `ATTACK_RANGE` | `StatKey.attackRange` |
| `MOVE_SPEED` | `StatKey.moveSpeed` |
| `HP_SEGMENTS` | `StatKey.hpSegments` |
| `KNOCKBACK_RESIST` | `StatKey.knockbackResist` |
| `KNOCKBACK_DISTANCE` | `StatKey.knockbackDistance` |
| `SUMMON_COST` | `StatKey.summonCost` |
| `RESUMMON_COOLDOWN` | `StatKey.resummonCooldown` |
| `HEAL_POWER` | `StatKey.healPower` |
| `HEAL_RECEIVED` | `StatKey.healReceived` |
| `DMG_DEALT_VS` | `StatKey.dmgDealtVs` |
| `DMG_TAKEN_FROM` | `StatKey.dmgTakenFrom` |
| `AOE_MAX_TARGETS` | `StatKey.aoeMaxTargets` |
| `PRAYER_GAIN_ON_KILL` | `StatKey.prayerGainOnKill` |

---

## 4. tag_relations.json

```jsonc
{
  "rules": [
    {
      "id": "TRL_COWARD_SLOWED_BY_BRAVE_AHEAD",
      "nameKey": "rel.coward.slow",
      "descKey": "rel.coward.slow.desc",
      "enabled": true,
      "subject": { "side": "SAME", "hasTags": ["TAG_TRAIT_COWARD"], "aliveOnly": true },
      "other":   { "side": "SAME", "hasTags": ["TAG_TRAIT_BRAVE"],  "aliveOnly": true,
                   "excludeKnockback": true },
      "relation": "OTHER_IS_AHEAD",
      "rangeMin": 0,
      "rangeMax": 400,
      "requireCount": 1,
      "scaleByOtherCount": false,
      "scaleBySubjectTagLevel": true,
      "maxScale": 3,
      "mods": [ { "stat": "MOVE_SPEED", "op": "PCT_ADD", "value": -25000 } ],
      "minActiveTicks": 30,
      "offDelayTicks": 12,
      "vfxKey": "rel_coward_sweat",
      "sfxKey": "sfx_rel_coward"
    },
    {
      "id": "TRL_BRAVE_BOOSTED_BY_COWARD_BEHIND",
      "nameKey": "rel.brave.boost",
      "enabled": true,
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
    },
    {
      "id": "TRL_HERD_ADJACENT",
      "nameKey": "rel.herd.pack",
      "subject": { "side": "SAME", "hasTags": ["TAG_TRAIT_HERD"] },
      "other":   { "side": "SAME", "hasTags": ["TAG_TRAIT_HERD"] },
      "relation": "OTHER_IS_ADJACENT",
      "rangeMax": 250,
      "requireCount": 2,
      "scaleByOtherCount": true,
      "maxScale": 4,
      "mods": [ { "stat": "DEF", "op": "PCT_ADD", "value": 3000 } ],
      "minActiveTicks": 30,
      "offDelayTicks": 12
    },
    {
      "id": "TRL_LONE_VANGUARD",
      "nameKey": "rel.lone.vanguard",
      "subject": { "side": "SAME", "hasTags": ["TAG_TRAIT_FIERCE"] },
      "other":   { "side": "SAME" },
      "relation": "NO_OTHER_AHEAD",
      "rangeMax": 0,
      "requireCount": 0,
      "mods": [ { "stat": "ATK", "op": "PCT_ADD", "value": 15000 } ],
      "minActiveTicks": 30,
      "offDelayTicks": 12
    }
  ]
}
```

| `relation` 값 | 조건 |
|---|---|
| `OTHER_IS_AHEAD` | other가 subject 전방 |
| `OTHER_IS_BEHIND` | other가 subject 후방 |
| `OTHER_IS_ADJACENT` | 방향 무관, 거리 이내 |
| `OTHER_IS_FRONTMOST` | 같은 편 최전방 유닛이 other 조건 만족 |
| `SUBJECT_IS_FRONTMOST` | subject 자신이 최전방 |
| `SUBJECT_IS_REARMOST` | subject 자신이 최후방 |
| `NO_OTHER_AHEAD` | 전방에 other 조건 유닛 0 |
| `ENEMY_WITHIN` | 적 진영에 other 조건 유닛이 범위 내 |

---

## 5. characters.json

```jsonc
{
  "characters": [
    {
      "id": "CHR_ACORN",
      "nameKey": "chr.acorn",                 // 굴러다니는 도토리
      "rarity": 1,                            // 1=기본 2=중간 3=최고
      "role": "ROLE_DEFENDER",
      "obtain": "STARTER",                    // STARTER | STORY | GACHA | EVENT | EXCHANGE
      "releaseChapter": 1,

      "intrinsicTags": {
        "TAG_TEMPER_FIELD": 1,
        "TAG_RACE_OBJECT": 1,
        "TAG_RACE_PLANT": 1,
        "TAG_ELEM_EARTH": 1,
        "TAG_BUILD_TINY": 1,
        "TAG_TRAIT_STURDY": 1,
        "TAG_TRAIT_HERD": 1,
        "TAG_ROLE_DEFENDER": 1
      },

      "base": {
        "summonCost": 75,
        "maxHp": 1200,
        "atk": 90,
        "attackPeriod": 60,
        "attackWindup": 12,
        "attackRecover": 48,
        "attackRange": 130,
        "moveSpeed": 100,
        "hpSegments": 3,
        "resummonCooldownSec": 4,
        "collisionRadius": 26,
        "knockbackDistance": 90,
        "knockbackResist": 0,
        "def": 0,
        "attackMode": "SINGLE",               // SINGLE | AOE | PIERCE
        "aoeMaxTargets": 1,
        "damageType": "PHYSICAL",             // PHYSICAL | MAGICAL
        "attackReach": "MELEE"                // MELEE | RANGED
      },

      "growth": {
        "hpPerBondLevel": 34,                 // 동행 레벨당 가산
        "atkPerBondLevel": 2
      },

      "skills": ["SKL_ACORN_ROLL"],
      "equipSlot": "GEAR",

      "art": {
        "atlasKey": "chr_acorn",
        "scale": 1.0,
        "anchorY": 1.0,
        "shadowRadius": 22,
        "clips": {
          "idle":     { "frames": 4, "fps": 8,  "loop": true },
          "move":     { "frames": 6, "fps": 12, "loop": true },
          "attack":   { "frames": 8, "windupFrames": 3, "impactFrame": 3, "recoverFrames": 4 },
          "hit":      { "frames": 3, "fps": 20, "loop": false },
          "knockback":{ "frames": 4, "fps": 12, "loop": false },
          "death":    { "frames": 6, "fps": 12, "loop": false },
          "spawn":    { "frames": 5, "fps": 15, "loop": false }
        }
      },

      "voiceKeys": { "summon": "vo_acorn_summon", "death": "vo_acorn_death" },
      "storyKeys": ["story.acorn.1", "story.acorn.2"],
      "affinityRewards": [
        { "level": 1, "type": "VOICE", "value": "vo_acorn_greet" },
        { "level": 3, "type": "STORY", "value": "story.acorn.2" },
        { "level": 5, "type": "SKIN",  "value": "SKN_ACORN_LEAF_HAT" }
      ]
    }
  ]
}
```

### 5.1 기본 5종 base 수치 (기획서 6-8)

| id | nameKey | 기질 | cost | maxHp | atk | P/A/R | range | speed | K | resummon | mode |
|---|---|---|---:|---:|---:|---|---:|---:|---:|---:|---|
| `CHR_ACORN` | 굴러다니는 도토리 | 들 | 75 | 1200 | 90 | 60/12/48 | 130 | 100 | 3 | 4s | SINGLE |
| `CHR_DROPLET` | 개울의 물방울 | 달 | 200 | 480 | 300 | 90/18/72 | 420 | 80 | 2 | 8s | SINGLE |
| `CHR_MUSHROOM` | 심술난 버섯 | 들 | 350 | 900 | 420 | 120/30/90 | 300 | 60 | 3 | 12s | AOE(5) |
| `CHR_BIRD` | 노래하는 새 | 해 | 500 | 700 | 180 | 75/15/60 | 480 | 70 | 1 | 18s | SINGLE |
| `CHR_BEAR` | 낮잠 자던 곰 | 달 | 900 | 3400 | 1100 | 105/36/69 | 200 | 50 | 4 | 30s | AOE(3) |

> `02_TAG_SYSTEM.md §7`의 주의사항 참조 — 태그 효과 수치를 절반으로 낮춰 시작한다.

---

## 6. skills.json

```jsonc
{
  "skills": [
    {
      "id": "SKL_BIRD_LULLABY",
      "nameKey": "skl.bird.lullaby",
      "trigger": {
        "kind": "ON_NTH_ATTACK",         // §03 §11 TriggerKind
        "n": 3
      },
      "target": {
        "side": "ENEMY",
        "sort": "NEAREST",
        "limit": 1,
        "withinRange": true,
        "excludeKnockback": true
      },
      "actions": [
        { "type": "STUN", "durationTicks": 15 }     // 0.5초 멈칫
      ],
      "descKey": "skl.bird.lullaby.desc",
      "vfxKey": "vfx_lullaby",
      "sfxKey": "sfx_lullaby"
    },
    {
      "id": "SKL_BEAR_ROAR",
      "trigger": { "kind": "ON_SPAWN" },
      "target": { "side": "SAME", "hasTags": ["TAG_RACE_ANIMAL"], "limit": 5,
                  "sort": "NEAREST" },
      "actions": [
        { "type": "GRANT_TAG", "tag": "TAG_TRAIT_BRAVE", "amount": 1,
          "durationTicks": 300 }                    // 10초간 용감 +1 → 관계 규칙 발동
      ]
    },
    {
      "id": "SKL_MUSHROOM_SPORE",
      "trigger": { "kind": "ON_CHANCE", "chance": 25000, "chanceUnit": "PER_ATTACK" },
      "target": { "side": "ENEMY", "withinRange": true, "limit": 3, "sort": "NEAREST" },
      "actions": [
        { "type": "SLOW", "durationTicks": 90, "movePct": -30000, "attackPeriodMult": 125000 }
      ]
    },
    {
      "id": "SKL_DROPLET_SPLASH",
      "trigger": { "kind": "ON_TAG_LEVEL", "tag": "TAG_ELEM_WATER",
                   "scope": "FIELD", "minLevel": 3 },
      "target": "SELF",
      "actions": [
        { "type": "STAT_BUFF", "mods": [{"stat":"ATK","op":"PCT_ADD","value":15000}],
          "durationTicks": 0 }                      // 0 = 조건 유지되는 동안
      ]
    }
  ]
}
```

### 6.1 action `type` 목록

| type | 파라미터 | 마일스톤 |
|---|---|---|
| `DAMAGE` | `atkPct`, `flat`, `pierce` | M1 |
| `STUN` | `durationTicks` | M1 |
| `SLOW` | `durationTicks`, `movePct`, `attackPeriodMult` | M1 |
| `PUSH` | `distance`, `bossPct` | M1 |
| `HEAL` | `amount`, `pctOfMaxHp`, `intervalTicks`, `durationTicks` | M1 |
| `STAT_BUFF` | `mods[]`, `durationTicks` (0=조건부 상시) | M1 |
| `GRANT_TAG` | `tag`, `amount`, `durationTicks` | M1 |
| `ATK_DOWN` | `pct`, `durationTicks`, `exclusiveGroup` | M2 |
| `RALLY` | `selfHpCostPct`, `mods[]`, `limit`, `durationTicks` | M2 |
| `SHELL` | `shieldHp`, `durationTicks` | M2 |
| `PIERCE_MARK` | `pierceTargets[]` | M2 |
| `PCT_DAMAGE` | `currentHpPct`, `cap`, `cooldownTicks` | M3 |
| `EXECUTE` | `excludeBoss`, `excludeBase` | M3 |
| `REVIVE` | `hpPct`, `count` | M3 |

---

## 7. enemies.json

```jsonc
{
  "enemies": [
    {
      "id": "ENM_SQUIRREL",
      "nameKey": "enm.squirrel",
      "isBoss": false,
      "intrinsicTags": { "TAG_RACE_ANIMAL": 1, "TAG_BUILD_SMALL": 1,
                         "TAG_TRAIT_SWIFT": 1 },
      "base": {
        "maxHp": 400, "atk": 60,
        "attackPeriod": 45, "attackWindup": 9, "attackRecover": 36,
        "attackRange": 120, "moveSpeed": 120, "hpSegments": 1,
        "collisionRadius": 22, "attackMode": "SINGLE", "aoeMaxTargets": 1,
        "def": 0, "knockbackResist": 0, "knockbackDistance": 90
      },
      "killPrayerReward": 10,
      "skills": [],
      "art": { "atlasKey": "enm_squirrel", "clips": { /* characters와 동일 구조 */ } }
    },
    {
      "id": "ENM_FOREST_BEAR",
      "nameKey": "enm.forest_bear",
      "isBoss": true,
      "intrinsicTags": { "TAG_RACE_ANIMAL": 2, "TAG_BUILD_LARGE": 2,
                         "TAG_TRAIT_FIERCE": 1 },
      "base": {
        "maxHp": 24000, "atk": 1600,
        "attackPeriod": 130, "attackWindup": 45, "attackRecover": 85,
        "attackRange": 320, "moveSpeed": 30, "hpSegments": 3,
        "collisionRadius": 70, "attackMode": "AOE", "aoeMaxTargets": 5,
        "def": 10000, "knockbackResist": 2, "knockbackDistance": 45
      },
      "killPrayerReward": 200,
      "damageCapPerHit": 4000,
      "art": { "atlasKey": "enm_forest_bear", "scale": 1.6 }
    }
  ]
}
```

### 7.1 첫 장 적 수치 (기획서 6-9)

| id | HP | atk | P/A/R | range | speed | K | mode | 처치 기도력 |
|---|---:|---:|---|---:|---:|---:|---|---:|
| `ENM_SQUIRREL` 쪼르르 다람쥐 | 400 | 60 | 45/9/36 | 120 | 120 | 1 | SINGLE | 10 |
| `ENM_WOLF` 뾰로통 늑대 | 1600 | 220 | 75/18/57 | 150 | 80 | 2 | SINGLE | 35 |
| `ENM_TURTLE` 등껍질 거북 | 6000 | 300 | 120/30/90 | 130 | 40 | 1 | SINGLE | 60 |
| `ENM_HEDGEHOG` 가시 고슴도치 | 900 | 480 | 150/45/105 | 460 | 60 | 2 | AOE(3) | 30 |
| `ENM_FOREST_BEAR` 숲의 큰곰 | 24000 | 1600 | 130/45/85 | 320 | 30 | 3 | AOE(5) | 200 |

---

## 8. stages/chapter_1.json

```jsonc
{
  "chapterId": "CH_1",
  "nameKey": "chapter.1",
  "themeKey": "sunlit_forest",
  "stages": [
    {
      "id": "STG_1_10",
      "index": 10,
      "nameKey": "stage.1.10",
      "backgroundKey": "bg_big_tree",
      "bgmKey": "bgm_boss_forest",

      "fieldLength": 2400,
      "allyBaseX": 0,
      "enemyBaseX": 2400,
      "enemyBaseHp": 18000,
      "timeLimitSec": 300,
      "minClearSec": 45,                 // ★ 서버 경량 검증용 하한
      "targetClearSec": [180, 240],

      "recommendedBondLevel": 24,

      "weather": {
        "mode": "GAUGE",                 // GAUGE | FIXED | AUTO_CYCLE
        "startGauge": 0,
        "biasPerSample": 0,
        "fixedState": null,
        "cycle": null
      },

      "restrictions": {
        "maxFormationSlots": 10,
        "requiredTags": [],
        "bannedTags": [],
        "ultimateSealed": false,
        "growthLocked": null
      },

      "waves": [
        { "enemyId": "ENM_SQUIRREL", "startSec": 0,  "intervalSec": 6,
          "count": -1, "stopSec": 180, "spawnX": 2350 },
        { "enemyId": "ENM_WOLF",     "startSec": 15, "intervalSec": 12,
          "count": -1, "stopSec": 180, "spawnX": 2350 },
        { "enemyId": "ENM_TURTLE",   "startSec": 40, "intervalSec": 25,
          "count": -1, "stopSec": 180, "spawnX": 2350 },
        { "enemyId": "ENM_HEDGEHOG", "startSec": 60, "intervalSec": 20,
          "count": -1, "stopSec": 180, "spawnX": 2350 }
      ],

      "bossTriggers": [
        {
          "id": "BOSS_1_10_MAIN",
          "enemyId": "ENM_FOREST_BEAR",
          "condition": { "kind": "NEST_FIRST_HIT" },
          "warningTicks": 45,
          "protectNestUntilBossDead": false,
          "spawnX": 2380,
          "announceInFormation": true
        }
      ],

      "rewards": {
        "first": [ { "type": "GOLD", "amount": 3000 },
                   { "type": "RECRUIT_TICKET", "amount": 1 },
                   { "type": "CHARACTER", "id": "CHR_FIREFLY" } ],
        "repeat": [ { "type": "GOLD", "amount": 300 } ]
      },

      "storyBefore": "story.ch1.before_10",
      "storyAfter": "story.ch1.after_10"
    }
  ]
}
```

### 8.1 bossTriggers `condition.kind`

| kind | 파라미터 |
|---|---|
| `TIME` | `atSec` |
| `NEST_FIRST_HIT` | — |
| `NEST_HP_BELOW` | `pct` |
| `CAMP_HP_BELOW` | `pct` |
| `ENEMY_KILLED` | `enemyId`, `count` |
| `ALL_WAVES_DONE` | — |

### 8.2 스테이지 기믹 매핑 (기획서 §8)

| 기획서 기믹 | 스키마 필드 |
|---|---|
| 보스 트리거 | `bossTriggers[]` |
| 제한 시간 | `timeLimitSec` |
| 기도력 부족 | `prayerModifier: { regenPct: -30000 }` |
| 편성 제한 | `restrictions.maxFormationSlots`, `requiredTags`, `bannedTags` |
| 필살기 봉인 | `restrictions.ultimateSealed` |
| 성장 고정 | `restrictions.growthLocked: { bondLevel: 20, focusLevel: 5, ... }` |
| 날씨 고정·편향 | `weather.mode = FIXED / GAUGE + biasPerSample` |
| 주기적 날씨 변화 | `weather.mode = AUTO_CYCLE`, `cycle: [{state, sec}]` |
| 보스 둘 | `bossTriggers` 배열에 2개 (각각 독립 `id`) |

---

## 9. growth.json

```jsonc
{
  "focus": {                         // 소녀의 집중력
    "keyframes": [
      { "level": 1,  "regenPerSec": 18, "cap": 1000, "startAmount": 200, "goldCost": 0 },
      { "level": 10, "regenPerSec": 31, "cap": 1600, "startAmount": 250 },
      { "level": 20, "regenPerSec": 45, "cap": 2200, "startAmount": 300 }
    ],
    "interpolate": "LINEAR_INT",
    "goldCostFormula": { "base": 500, "growth": 1.18 }
  },
  "camp": {                          // 캠프 방어 (모닥불 HP)
    "keyframes": [
      { "level": 1,  "hp": 10000 },
      { "level": 10, "hp": 28000 },
      { "level": 20, "hp": 50000 }
    ],
    "interpolate": "LINEAR_INT",
    "goldCostFormula": { "base": 400, "growth": 1.20 }
  },
  "focusBoost": [                    // 전투 중 집중 강화
    { "stage": 0, "regenBonus": 0,  "capBonus": 0,   "cost": 0 },
    { "stage": 1, "regenBonus": 7,  "capBonus": 300, "cost": 150 },
    { "stage": 2, "regenBonus": 14, "capBonus": 600, "cost": 250 }
  ],
  "bond": {                          // 동행 레벨
    "maxLevel": 120,
    "goldCostFormula": { "base": 200, "growth": 1.12 }
  }
}
```

**보간 구현**
```dart
int lerpInt(int l0, int v0, int l1, int v1, int level) {
  if (level <= l0) return v0;
  if (level >= l1) return v1;
  return v0 + (v1 - v0) * (level - l0) ~/ (l1 - l0);
}
```

---

## 10. weather.json

```jsonc
{
  "gauge": { "min": -100, "max": 100, "start": 0 },
  "sample": { "ticks": 60, "maxKindsPerTemper": 3,
              "biasFactor": 6, "biasClamp": 12, "fieldDecayFactor": 4 },
  "thresholds": { "toClear": 60, "toNight": -60,
                  "clearExit": 40, "nightExit": -40 },
  "states": {
    "CLEAR": {
      "allyAtkPct": 15000, "prayerRegenPct": -10000, "allyHealPct": -20000,
      "hotPctPerSec": 0
    },
    "DUSK": { "allyAtkPct": 0, "prayerRegenPct": 0, "allyHealPct": 0, "hotPctPerSec": 0 },
    "NIGHT": {
      "allyAtkPct": -10000, "prayerRegenPct": 10000, "allyHealPct": 0,
      "hotPctPerSec": 250
    }
  },
  "healCapPctPerSec": 2000
}
```

---

## 11. items.json / exchange.json / dungeons.json

`07_DUNGEON_EXCHANGE.md` 에서 상세 정의. 요약 스키마만 여기 둔다.

```jsonc
// items.json
{
  "items": [
    { "id": "ITM_SHARD_SUN_T1", "type": "SHARD", "nameKey": "itm.shard.sun.t1",
      "tier": 1, "iconKey": "shard_sun_t1", "stackable": true, "maxStack": 9999 },
    { "id": "ITM_GOLD", "type": "CURRENCY", "nameKey": "itm.gold" },
    { "id": "ITM_RECRUIT_TICKET", "type": "CURRENCY", "nameKey": "itm.recruit_ticket" }
  ]
}
```

```jsonc
// exchange.json
{
  "shops": [
    {
      "id": "SHOP_DUNGEON_SUN",
      "nameKey": "shop.dungeon.sun",
      "entries": [
        { "id": "EX_ANIMAL_MASK",
          "cost": [ { "item": "ITM_SHARD_SUN_T3", "amount": 10 } ],
          "gain": { "type": "EQUIPMENT", "id": "EQP_ANIMAL_MASK" },
          "limit": 0,               // 0 = 무제한
          "resetPeriod": "NONE" }
      ]
    }
  ]
}
```

---

## 12. banners.json (소환)

```jsonc
{
  "banners": [
    {
      "id": "BNR_STANDARD",
      "kind": "STANDARD",              // STANDARD | THEME | COLLAB
      "nameKey": "bnr.standard",
      "startAtUtc": null, "endAtUtc": null,
      "cost": { "single": { "item": "ITM_RECRUIT_TICKET", "amount": 1 },
                "ten":    { "item": "ITM_RECRUIT_TICKET", "amount": 10 } },
      "givesExchangePoint": false,
      "rates": [
        { "rarity": 3, "pickup": true,  "totalPct": 1500,  "pool": ["CHR_X"] },
        { "rarity": 3, "pickup": false, "totalPct": 1500,  "pool": ["CHR_BEAR","CHR_..."] },
        { "rarity": 2, "totalPct": 17000, "pool": [ ... ] },
        { "rarity": 1, "totalPct": 80000, "pool": [ ... ] }
      ],
      "duplicateConversion": { "rarity3": 30, "rarity2": 10, "rarity1": 3,
                               "item": "ITM_COLLECT_FRAGMENT" }
    }
  ],
  "exchange": { "pointPerPull": 1, "requiredPoints": 200, "carryOver": true }
}
```

> `totalPct`는 밀리퍼센트 (1500 = 1.5%). 4개 구간 합 = 100000.

---

## 13. story/*.json

```jsonc
{
  "scenes": [
    {
      "id": "story.ch1.after_10",
      "unlockCondition": { "kind": "STAGE_CLEAR", "stageId": "STG_1_10" },
      "journalCategory": "MAIN",
      "skippable": true,
      "replayable": true,
      "beats": [
        { "type": "BG", "key": "bg_big_tree_dusk" },
        { "type": "BGM", "key": "bgm_story_quiet" },
        { "type": "LINE", "speakerKey": "spk.girl",
          "textKey": "story.ch1.after_10.l1", "portraitKey": "por_girl_soft" },
        { "type": "SFX", "key": "sfx_leaf_rustle" },
        { "type": "LINE", "speakerKey": "spk.narration",
          "textKey": "story.ch1.after_10.l2" },
        { "type": "FADE", "to": "BLACK", "durationMs": 800 }
      ]
    }
  ]
}
```

---

## 14. 데이터 검증 (CI에서 실행)

`tool/validate_data.dart` 가 다음을 검사하고 실패 시 CI를 깨뜨린다.

- [ ] 모든 참조 ID 존재 (character→skill, skill→tag, stage→enemy, exchange→equipment ...)
- [ ] 태그 ID 네이밍 규칙 `TAG_<CATEGORY>_<NAME>` 준수 & category 필드와 일치
- [ ] `0 < attackWindup < attackPeriod` (기획서 6-3)
- [ ] `attackRecover == attackPeriod - attackWindup` (기본값일 때)
- [ ] `hpSegments >= 1`
- [ ] banner rates 합계 == 100000
- [ ] 캐릭터당 핵심 트리거 스킬 ≤ 2개
- [ ] 캐릭터당 `TAG_TEMPER_*` 정확히 1개
- [ ] `TagEffect.target` 이 존재하는 태그만 참조
- [ ] 관계 규칙 `subject`/`other` 가 서로 무한 순환하는 스탯 참조를 만들지 않음
- [ ] 모든 `nameKey`/`descKey` 가 ARB에 존재
- [ ] 모든 `iconKey`/`atlasKey`/`bgKey` 가 `assets/` 에 존재
- [ ] `minClearSec` 가 `targetClearSec[0]` 의 절반 이하
