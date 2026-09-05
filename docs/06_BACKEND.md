# 06. 백엔드 (Firebase)

> Firebase Auth + Firestore + Cloud Functions(TypeScript, Node 20) + Cloud Storage.
> 원칙: **클라이언트는 자기 문서를 읽기만 한다. 모든 상태 변경은 Callable Function을 통한다.**

---

## 1. 원칙

1. **쓰기는 전부 서버.** Firestore 보안 규칙에서 클라이언트 write를 전면 금지한다.
   (예외: `settings` 같은 무해한 개인 설정 필드 일부)
2. **모든 소비/지급은 트랜잭션 + 멱등키.** 같은 요청이 두 번 와도 한 번만 적용.
3. **원장(ledger) 유지.** 재화 증감은 `transactions` 컬렉션에 append-only로 남긴다.
   수정이 필요하면 지우지 않고 **보정 거래**를 추가한다.
4. **서버 시각 기준.** 일일/주간 초기화, 배너 기간, 이벤트 종료는 모두 서버 시각.
5. **관용적 실패.** 네트워크 실패한 제출은 클라이언트 재시도 큐에 남고, 서버는 멱등키로 중복을 막는다.

---

## 2. Firestore 스키마

```
users/{uid}
  profile          { nickname, createdAt, lastLoginAt, platform, appVersion }
  growth           { bondLevel, focusLevel, campDefenseLevel }
  currency         { gold, recruitTicket, collectFragment, exchangePoint }
  progress         { tutorialStep, clearedStages: {STG_1_1: {stars, bestClearSec}},
                     chapterUnlocked, journalUnlocked: [sceneId] }
  settings         { bgmVolume, sfxVolume, battleSpeed, locale, lowSpecMode }
  dataVersionSeen  "1.0.7"

users/{uid}/characters/{characterId}
  { obtainedAt, affinity, skinId, equipmentId, dupCount }

users/{uid}/equipments/{instanceId}
  { equipmentId, enhanceLevel, equippedTo: characterId|null, obtainedAt }

users/{uid}/items/{itemId}
  { amount, updatedAt }                       // 조각, 이벤트 토큰 등

users/{uid}/formations/{presetIndex}          // 0..2
  { slots: [ {characterId, equipmentInstanceId} × 10 ], updatedAt }

users/{uid}/dailyCounters/{yyyy-MM-dd}
  { dungeonRuns: {SUN: 2, MOON: 1, FIELD: 0}, totalDungeonRuns: 3,
    missionProgress: {...}, missionClaimed: [...], expireAt }

users/{uid}/weeklyCounters/{yyyy-Www}
  { puzzleCleared: bool, deepForestClaimedFloor: 12, expireAt }

users/{uid}/battles/{battleId}                // 진행 중 / 최근 전투
  { stageId, mode, seed, dataVersion, formationHash,
    issuedAt, expireAt, state: "issued"|"submitted"|"abandoned"|"expired",
    result: {...}|null }

users/{uid}/transactions/{txId}
  { idempotencyKey, kind, reason, deltas: [{item, amount}],
    orderId|battleId|null, createdAt, appliedBy: "gachaPull"|"submitBattle"|... }

users/{uid}/mail/{mailId}
  { titleKey, bodyKey, attachments: [...], claimedAt|null, expireAt }

users/{uid}/purchases/{orderId}
  { productId, platform, verifiedAt, granted: bool, receiptHash }

-- 서버 전용 / 공용 읽기 --

gameData/current
  { dataVersion, minAppVersion, storagePathPrefix, publishedAt }

config/rates/{dataVersion}                    // 확률 스냅샷 (재현용)
  { banners: {...} }

banners/{bannerId}
  { kind, startAt, endAt, ratesRef, costs, exchangeTargets: [characterId] }

stagesMeta/{stageId}                          // 서버 검증용 최소 정보만
  { timeLimitSec, minClearSec, maxWaveEnemies, maxKillPrayer,
    enemyBaseHp, firstRewards, repeatRewards }

dungeonsMeta/{dungeonId}
  { type, difficulties: [...], dayBonus: {...}, dropTable: [...] }

notices/{noticeId}
  { titleKey, bodyKey, startAt, endAt, priority }

serverState/schedule
  { dailyResetHourUtc: 20, weeklyResetDayUtc: 0 }   // KST 05:00 = UTC 20:00 전일
```

### 2.1 인덱스

| 컬렉션 | 필드 |
|---|---|
| `users/{uid}/transactions` | `createdAt desc` |
| `users/{uid}/transactions` | `idempotencyKey asc` (unique 대용, 트랜잭션 내 조회) |
| `users/{uid}/battles` | `state asc, expireAt asc` |
| `users/{uid}/mail` | `claimedAt asc, expireAt asc` |
| `banners` | `startAt asc, endAt asc` |

---

## 3. 보안 규칙

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  function isOwner(uid) { return request.auth != null && request.auth.uid == uid; }

  match /databases/{db}/documents {

    // 자기 문서 읽기만 허용
    match /users/{uid} {
      allow read: if isOwner(uid);
      // settings 필드만 클라이언트 직접 수정 허용
      allow update: if isOwner(uid)
        && request.resource.data.diff(resource.data).affectedKeys()
             .hasOnly(['settings']);
      allow create, delete: if false;

      match /{sub=**} {
        allow read: if isOwner(uid);
        allow write: if false;          // ★ 모든 하위 쓰기는 Functions만
      }

      // 편성은 예외적으로 클라이언트 쓰기 허용 (전투 검증 때 서버가 다시 확인)
      match /formations/{presetIndex} {
        allow write: if isOwner(uid)
          && request.resource.data.slots.size() == 10;
      }
    }

    // 공용 읽기 데이터
    match /gameData/{doc}   { allow read: if true;  allow write: if false; }
    match /banners/{doc}    { allow read: if true;  allow write: if false; }
    match /notices/{doc}    { allow read: if true;  allow write: if false; }
    match /stagesMeta/{doc} { allow read: if true;  allow write: if false; }
    match /dungeonsMeta/{doc}{ allow read: if true; allow write: if false; }

    // 서버 전용
    match /config/{doc=**}      { allow read, write: if false; }
    match /serverState/{doc=**} { allow read, write: if false; }
  }
}
```

```javascript
// storage.rules — 데이터팩은 공개 읽기, 쓰기는 콘솔/CI만
service firebase.storage {
  match /b/{bucket}/o {
    match /datapack/{version}/{file=**} { allow read: if true; allow write: if false; }
  }
}
```

---

## 4. Cloud Functions API

모두 **Callable** (`onCall`). 리전은 `asia-northeast3` (서울).

```ts
// functions/src/index.ts
export * from './account/bootstrapAccount';
export * from './account/linkAccount';
export * from './battle/startBattle';
export * from './battle/submitBattle';
export * from './battle/abandonBattle';
export * from './battle/sweepStage';
export * from './growth/levelUp';
export * from './inventory/equipItem';
export * from './inventory/enhanceEquipment';
export * from './dungeon/startDungeon';
export * from './dungeon/sweepDungeon';
export * from './exchange/exchangeItems';
export * from './gacha/gachaPull';
export * from './gacha/exchangePickup';
export * from './mission/claimMission';
export * from './mail/claimMail';
export * from './purchase/verifyPurchase';
export * from './schedule/dailyReset';
export * from './schedule/weeklyReset';
export * from './schedule/expireBattles';
```

### 4.1 공통 요청/응답

```ts
interface BaseRequest {
  idempotencyKey: string;   // 클라이언트 생성 UUIDv4. 재시도 시 동일 값 유지
  appVersion: string;
  dataVersion: string;
}

interface BaseResponse<T> {
  ok: boolean;
  code?: ErrorCode;
  data?: T;
  /** 변경된 계정 상태 델타. 클라이언트가 이걸로 로컬 미러를 갱신 */
  patch?: AccountPatch;
}

type ErrorCode =
  | 'AUTH_REQUIRED' | 'APP_VERSION_TOO_OLD' | 'DATA_VERSION_MISMATCH'
  | 'NOT_ENOUGH_CURRENCY' | 'NOT_OWNED' | 'ALREADY_APPLIED'
  | 'BATTLE_NOT_FOUND' | 'BATTLE_EXPIRED' | 'BATTLE_ALREADY_SUBMITTED'
  | 'VALIDATION_FAILED' | 'DAILY_LIMIT_REACHED' | 'BANNER_CLOSED'
  | 'RATE_LIMITED' | 'MAINTENANCE' | 'INTERNAL';
```

### 4.2 멱등성 구현 (모든 쓰기 함수 공통)

```ts
async function withIdempotency<T>(
  uid: string, key: string, kind: string,
  work: (tx: Transaction) => Promise<{ result: T; deltas: Delta[] }>
): Promise<T> {
  const txRef = db.doc(`users/${uid}/transactions/${key}`);   // ★ 문서 ID = 멱등키
  return db.runTransaction(async (tx) => {
    const existing = await tx.get(txRef);
    if (existing.exists) {
      return existing.data()!.result as T;   // 이미 적용됨 → 같은 결과 반환
    }
    const { result, deltas } = await work(tx);
    tx.set(txRef, {
      idempotencyKey: key, kind, deltas, result,
      createdAt: FieldValue.serverTimestamp(),
    });
    return result;
  });
}
```

**멱등키를 트랜잭션 문서 ID로 쓰는 것**이 가장 단순하고 확실하다. 별도 락이 필요 없다.

### 4.3 `startBattle`

```ts
interface StartBattleReq extends BaseRequest {
  mode: 'STORY' | 'DUNGEON' | 'DEEP_FOREST' | 'PUZZLE' | 'TRIAL' | 'EVENT';
  stageId: string;
  presetIndex: number;         // 사용할 편성 프리셋
  difficulty?: number;         // 던전용
}

interface StartBattleRes {
  battleId: string;
  seed: number;                // 32bit
  dataVersion: string;
  serverTimeMs: number;
  expireAtMs: number;          // issuedAt + TTL
  formationSnapshot: FormationSnapshot;   // ★ 서버가 확정한 편성
}
```

처리:
```
1. appVersion / dataVersion 확인
2. 모드별 입장 자격 확인
   - STORY: 이전 스테이지 클리어 여부
   - DUNGEON: dailyCounters 잔여 횟수 (차감은 여기서 하지 않음 — submit에서 차감)
   - TRIAL: 픽업 기간 확인
3. presetIndex의 편성을 읽고 소유 검증
   - 각 characterId 를 실제로 보유하고 있는가
   - 각 equipmentInstanceId 가 그 캐릭터에 장착되어 있는가
   - 중복 캐릭터 없는가, 슬롯 수 제한 준수하는가
   - 스테이지 restrictions (requiredTags/bannedTags/maxSlots) 준수하는가
4. formationSnapshot 생성 (성장치·장비·태그 포함) → battles/{battleId} 에 저장
   → 클라이언트는 이 스냅샷으로 BattleConfig 를 조립한다 (서버·클라 불일치 방지)
5. seed = crypto.randomInt(2^31), TTL = timeLimitSec + 600초
```

> **핵심:** 편성 스냅샷을 서버가 만들어 내려준다. 클라이언트가 임의로 스탯을 올린 편성으로
> 시뮬을 돌려도 서버가 내려준 스냅샷과 다르면 `formationHash` 불일치로 반려된다.

### 4.4 `submitBattle`

```ts
interface SubmitBattleReq extends BaseRequest {
  battleId: string;
  outcome: 'ALLY_WIN' | 'ENEMY_WIN' | 'DRAW' | 'TIMEOUT';
  summary: {
    endTick: number;
    totalSummons: number;
    totalPrayerSpent: number;
    ultimateUsed: number;
    focusBoostStage: number;
    enemiesKilled: number;
    enemyBaseHpLeft: number;
    allyBaseHpLeft: number;
    maxFrontlineX: number;
    checksum: string;               // world.checksum() 최종값
  };
  inputLog: string;                 // base64(varint delta encoded)
  formationHash: string;
}

interface SubmitBattleRes {
  accepted: boolean;
  rewards: Reward[];
  firstClear: boolean;
  patch: AccountPatch;
}
```

#### 검증 순서

```
V0  battles/{battleId} 존재, state == "issued", now < expireAt
V1  formationHash == 서버 스냅샷 해시
V2  dataVersion 일치
V3  outcome == ALLY_WIN 인 경우에만 클리어 보상
V4  endTick / 30 >= stagesMeta.minClearSec            ← 너무 빠른 클리어 반려
V5  endTick / 30 <= stagesMeta.timeLimitSec + 2       ← 시간 초과 조작 반려
V6  기도력 수지 검사
      maxAvailable = startAmount
                   + ceil(regenPerSec * clearSec * maxWeatherBonus)
                   + stagesMeta.maxKillPrayer
      totalPrayerSpent <= maxAvailable
V7  소환 횟수 검사
      inputLog의 슬롯별 소환 시각 간격 >= 해당 슬롯 resummonCooldown
      totalSummons == inputLog의 SummonInput 수
V8  필살기 횟수
      ultimateUsed <= floor((clearSec - 30) / 60) + 1
V9  처치 수
      enemiesKilled <= stagesMeta.maxWaveEnemies
V10 편성 외 캐릭터 소환 로그 없음
V11 inputLog 디코딩 성공, tick 단조 증가, 모든 tick <= endTick
V12 sha256(inputLog + seed + formationHash) 로 만든 값이 summary.checksum과
    같은 방식으로 검증 가능한지 (클라 checksum 알고리즘을 서버에 동일 구현)
      ※ 완전 재실행이 아니므로 checksum은 '변조 흔적 탐지' 수준으로만 사용
V13 이상치 로깅: 통과했지만 상위 0.1% 값이면 flag 저장 (사후 분석용)
```

```
통과 → 트랜잭션:
  battles/{battleId}.state = "submitted", result 저장
  DUNGEON 모드면 dailyCounters 차감
  progress.clearedStages 갱신 (첫 클리어면 firstRewards, 아니면 repeatRewards)
  보상 지급 + transactions 원장 append
  응답에 patch 포함

실패 → state = "submitted", accepted=false, 보상 없음, 이유 로깅
      (클라이언트에는 VALIDATION_FAILED 만 반환. 어떤 검사에 걸렸는지 노출 금지)
```

#### V13 이상치 플래그

```ts
// 즉시 제재하지 않는다. 오탐이 사람을 쫓아낸다.
// 누적 flag가 임계를 넘으면 운영 대시보드에 올려 수동 검토.
await db.doc(`antiCheat/${uid}`).set({
  flags: FieldValue.increment(1),
  lastFlagAt: FieldValue.serverTimestamp(),
  samples: FieldValue.arrayUnion({ battleId, reason, at: Date.now() }),
}, { merge: true });
```

### 4.5 `sweepStage` / `sweepDungeon` (소탕)

```ts
interface SweepReq extends BaseRequest {
  target: { kind: 'DUNGEON'; dungeonId: string; difficulty: number }
        | { kind: 'STAGE'; stageId: string };
  times: number;               // 1..6
}
```

```
1. 클리어 자격 확인 (이미 그 난이도를 클리어한 적 있는가)
2. 일일 잔여 횟수 >= times
3. 차감과 지급을 하나의 트랜잭션으로 처리
4. 드랍은 서버에서 추첨 (dungeonsMeta.dropTable + 서버 RNG)
5. 원장 기록
```

**드랍 추첨은 반드시 서버.** 클라이언트가 드랍을 결정하면 리롤 조작이 가능하다.
실제 전투 플레이 시에도 보상 아이템 추첨은 `submitBattle`의 서버 측에서 한다.

### 4.6 `exchangeItems` (조각 10개 → 장비)

```ts
interface ExchangeReq extends BaseRequest {
  shopId: string;
  entryId: string;
  times: number;
}
```

```
1. exchange.json 서버 사본에서 entry 조회 (클라이언트 값 신뢰 금지)
2. limit / resetPeriod 확인 (일일·주간 한도)
3. cost 아이템 보유량 확인 → 차감
4. gain 지급
   - EQUIPMENT → equipments 서브컬렉션에 새 인스턴스 생성
   - ITEM / CURRENCY → items / currency 증감
   - CHARACTER → 보유 시 dupCount++ 및 조각 전환
5. 원장 기록
```

### 4.7 `gachaPull`

```ts
interface GachaPullReq extends BaseRequest {
  bannerId: string;
  count: 1 | 10;
}
interface GachaPullRes {
  results: { characterId: string; rarity: number; isNew: boolean;
             convertedFragments?: number }[];
  exchangePointAfter: number;
  ratesVersion: string;        // ★ 재현용
}
```

```
1. banners/{bannerId} 기간 확인 (서버 시각)
2. 비용 차감
3. config/rates/{dataVersion} 에서 확률 스냅샷 로드
4. count 회 독립 추첨 (서버 crypto RNG)
5. 신규/중복 판정 → 중복은 collectFragment 전환
6. 테마·콜라보 배너면 exchangePoint += count
7. transactions 에 ratesVersion 포함 기록  ← "그때 확률이 이랬다"를 증명 가능하게
```

### 4.8 `verifyPurchase`

```
1. 플랫폼별 영수증 서버 검증 (Google Play Developer API / App Store Server API)
2. orderId 로 purchases/{orderId} 확인 → 이미 granted면 즉시 성공 반환 (멱등)
3. 상품 정의(서버 사본)에 따라 지급
4. 취소·환불 웹훅(RTDN / App Store Server Notifications) 수신 → 상태 반영
   - 환불 시 지급물 회수는 정책에 따라. 최소한 상태는 기록해 둔다
5. 미지급 재처리: 스케줄 함수가 verified && !granted 인 주문을 재시도
```

### 4.9 스케줄 함수

| 함수 | 스케줄 | 역할 |
|---|---|---|
| `dailyReset` | 매일 UTC 20:00 (KST 05:00) | 일일 카운터 문서 만료 처리, 요일 보너스 갱신 |
| `weeklyReset` | 매주 일요일 UTC 20:00 | 주간 퍼즐·깊은 숲 보상 상태 초기화 |
| `expireBattles` | 10분마다 | TTL 지난 `state=="issued"` 전투를 `expired`로 |
| `retryUngrantedPurchases` | 30분마다 | 미지급 결제 재처리 |
| `aggregateMetrics` | 매시 | 스테이지별 승률·시도수 집계 → 운영 대시보드 |

> 일일 카운터는 문서 ID에 날짜를 넣어 **초기화를 "새 문서 생성"으로 처리**한다.
> 대량 업데이트가 필요 없고, TTL 정책으로 자동 삭제된다 (`expireAt` 필드 + Firestore TTL).

---

## 5. 데이터팩 배포 파이프라인

```
[기획 데이터 저장소 (git)]
  assets/data/v1/*.json
        │
        ├─ CI: tool/validate_data.dart 검증 (04_DATA_SCHEMA.md §14)
        │
        ├─ CI: sha256 계산 → manifest.json 생성
        │
        ├─ gsutil cp → gs://<bucket>/datapack/1.0.8/
        │
        └─ Firestore gameData/current 갱신
             { dataVersion: "1.0.8", minAppVersion: "1.0.0" }

[클라이언트]
  부트스트랩 시 gameData/current 조회
  로컬 dataVersion != 원격 → 다운로드 → sha256 검증 → Hive 저장
  실패 시 번들 데이터로 폴백
```

**롤백:** `gameData/current` 의 `dataVersion` 을 이전 값으로 되돌리면 끝.
클라이언트는 로컬에 이전 버전 캐시를 1개 유지하므로 즉시 복구된다.

**서버 검증과의 정합성:** `stagesMeta`, `config/rates` 는 데이터팩 배포와 **같은 CI 단계**에서
Firestore에 함께 반영한다. 따로 배포하면 클라·서버 버전이 어긋나 전투가 전부 반려된다.

---

## 6. 계정

### 6.1 흐름

```
첫 실행
  → signInAnonymously()
  → bootstrapAccount() 호출
      · users/{uid} 생성 (기본 5종 캐릭터, 시작 재화, 편성 프리셋 3개 초기화)
      · 멱등: 이미 있으면 아무것도 안 함

계정 연결 (Google / Apple)
  → linkWithCredential()
  → 이미 그 credential에 계정이 있으면 충돌
      → linkAccount() 함수로 "어느 계정을 유지할지" 선택 UI
      → 선택된 uid로 로그인, 다른 쪽은 병합하지 않고 유지 (데이터 손실 방지)

기기 변경
  → 연결된 계정으로 로그인 → 같은 uid → 서버 상태 그대로 로드
```

### 6.2 오프라인 정책

| 기능 | 오프라인 가능 |
|---|---|
| 프롤로그·튜토리얼 | O (진행도는 복귀 시 동기화) |
| 본편 전투 플레이 | X (`startBattle`이 battleId를 발급해야 함) |
| 편성 변경 | O (로컬 저장, 복귀 시 동기화) |
| 캐릭터·태그 조회 | O (로컬 미러) |
| 소환·구매·던전 | X |

> 전투를 오프라인 허용하려면 서버 검증을 포기해야 한다. 대신 **네트워크가 끊겨도
> 진행 중 전투는 끝까지 플레이하게 하고**, 결과 제출만 재시도 큐에 넣는다.
> (`pendingSubmits` Hive 박스 → 복귀 시 자동 제출. 멱등키로 중복 방지)

---

## 7. 지표 (Analytics)

```ts
// 이벤트 이름과 파라미터를 코드 상수로 고정한다
tutorial_step_completed  { step_id }
tutorial_completed       { duration_sec }
stage_start              { stage_id, bond_level, formation_hash }
stage_result             { stage_id, outcome, clear_sec, attempts, summons }
first_defeat             { stage_id, frontline_x, elapsed_sec }
formation_changed        { team_tags_json }        // ★ 태그 편중 분석
tag_tier_activated       { tag_id, tier_level, stage_id }
relation_activated       { rule_id, stage_id }
dungeon_run              { dungeon_id, difficulty, sweep }
exchange_used            { shop_id, entry_id }
gacha_pull               { banner_id, count, got_pickup }
exchange_point_reached   { banner_id, days_taken }
story_scene_exit         { scene_id, progress_pct }  // 이야기 이탈 지점
purchase_error           { product_id, code }
```

BigQuery export를 켜고, 다음 질문에 답할 수 있게 뷰를 만든다.

- 첫 패배가 어느 스테이지 어느 지점에서 발생하는가
- 어떤 태그 조합이 과도하게 편중되는가 (`formation_changed`의 `team_tags_json` 집계)
- 태그 티어 진입 전/후 승률 차이
- 관계 규칙이 실제로 쓰이는가 (`relation_activated` 발생률)
- 요일던전 난이도별 참여율과 조각 수급 속도
- 200포인트 교환 도달까지 실제 소요 일수 (기획 목표 3.33개월과 비교)

---

## 8. 운영 기능

| 기능 | 구현 |
|---|---|
| 점검 | Remote Config `maintenance: {enabled, messageKey, until}` → 앱 시작 시 확인 |
| 예약 게시 | `notices` 컬렉션 `startAt/endAt`, 클라이언트가 서버 시각으로 필터 |
| 판매 중지 | Remote Config `disabledProducts: [productId]` |
| 강제 업데이트 | `gameData/current.minAppVersion` 비교 → 스토어 유도 |
| 보상 우편 | 운영 도구가 `users/{uid}/mail` 에 문서 생성 (Functions 경유) |
| 문의 대응 | `transactions` 원장 조회 (거래 ID로 정확한 시점·확률버전 확인) |
| 데이터 롤백 | `gameData/current.dataVersion` 되돌리기 |
| A/B | Remote Config 조건부 파라미터 + Analytics 사용자 속성 |

---

## 9. 비용 관리 (Firebase)

Firestore는 읽기 횟수로 과금된다. 다음 규칙을 지킨다.

- 계정 상태는 **문서 1개(`users/{uid}`)에 몰아넣는다.** 서브컬렉션은 목록형만.
  → 앱 시작 시 읽기 1회 + 캐릭터 목록 1회로 끝난다.
- `snapshots()` 실시간 리스너는 `users/{uid}` 1개만. 나머지는 `get()`.
- 캐릭터 목록은 로컬 미러에 캐시하고 변경 시(획득/장착) 서버 응답의 `patch`로 갱신.
  전체 재조회하지 않는다.
- 공용 데이터(`banners`, `stagesMeta`)는 데이터팩에 포함해 Firestore 읽기를 없앤다.
  Firestore에는 **서버 검증용 최소 필드만** 둔다.
- 로그·지표는 Firestore가 아니라 Analytics/BigQuery로.

예상: DAU 10,000 기준 하루 읽기 약 10~15만회 → 무료 한도 근처. 쓰기가 비용의 대부분이므로
`transactions` 원장은 **월 단위 파티션 컬렉션**(`transactions_2026_09`)으로 나눠 두면
나중에 오래된 것을 일괄 삭제하기 쉽다.

---

## 10. 로컬 개발 환경

```bash
# 에뮬레이터 (Auth + Firestore + Functions + Storage)
firebase emulators:start --import=./seed --export-on-exit=./seed

# Functions 개발
cd functions && npm run build:watch

# 시드 데이터 주입
npm run seed:datapack       # gameData/current + stagesMeta + config/rates
npm run seed:testuser       # 테스트 계정 3종 (신규 / 중간 / 만렙)
```

```dart
// lib/app/bootstrap.dart
if (const bool.fromEnvironment('USE_EMULATOR')) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseFunctions.instanceFor(region: 'asia-northeast3')
      .useFunctionsEmulator('localhost', 5001);
}
```

```bash
flutter run --dart-define=USE_EMULATOR=true
```

**Functions 단위 테스트**는 `firebase-functions-test` + 에뮬레이터로 작성한다.
특히 `submitBattle`의 V0~V13 검증은 **각 항목마다 통과/반려 케이스 1쌍씩** 테스트를 남긴다.
