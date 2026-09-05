# 05. 프론트엔드 (Flutter + Flame)

---

## 1. 의존성

```yaml
# pubspec.yaml
environment:
  sdk: ">=3.5.0 <4.0.0"

dependencies:
  flutter: { sdk: flutter }
  flutter_localizations: { sdk: flutter }

  # 게임
  flame: ^1.18.0
  flame_audio: ^2.10.0

  # 상태관리 / 라우팅
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.0.0

  # 모델
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  collection: ^1.18.0

  # 저장
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.0

  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  cloud_functions: ^5.0.0
  firebase_storage: ^12.0.0
  firebase_remote_config: ^5.0.0
  firebase_analytics: ^11.0.0
  firebase_crashlytics: ^4.0.0
  firebase_messaging: ^15.0.0

  # 결제
  in_app_purchase: ^3.2.0

  # 기타
  crypto: ^3.0.3
  intl: ^0.19.0

dev_dependencies:
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  custom_lint: ^0.6.0
  riverpod_lint: ^2.3.0
  flutter_test: { sdk: flutter }
```

---

## 2. 화면 목록과 라우트

| 라우트 | 화면 | 주요 구성 |
|---|---|---|
| `/` | Splash | 부트스트랩 진행률, 데이터팩 다운로드 |
| `/prologue` | 프롤로그 | 컷 연출, 스킵/다시보기 |
| `/tutorial` | 튜토리얼 | 전투 + 단계별 가이드 오버레이 |
| `/camp` | **메인 캠프** | 소녀·동료·모닥불, 하단 탭 진입 |
| `/adventure` | 모험 지도 | 장·스테이지 노드, 진행도, 보상 미리보기 |
| `/adventure/:stageId/brief` | 출격 브리핑 | 적 특징·보스 조건·기믹·**팀 태그 미리보기** |
| `/formation` | 편성 | 10칸(5+5), 프리셋 3, 필터, **팀 태그 패널** |
| `/battle` | 전투 | Flame 캔버스 + HUD 오버레이 |
| `/battle/result` | 결과 | 보상, 통계, 패배 힌트 |
| `/friends` | 친구 목록 | 보유 캐릭터 그리드 |
| `/friends/:id` | 친구 상세 | 능력치·**태그 칩**·스킬·장비·이야기·스킨·음성 |
| `/dungeon` | 요일던전 | 3종 × 5난이도, 요일 보너스, 잔여 횟수 |
| `/exchange` | 교환소 | 조각 → 장비/아이템 (10개 교환) |
| `/deepforest` | 깊은 숲 | 층 진행, 주간 보상 |
| `/summon` | 소환 | 배너, 확률, 10연, 교환 포인트 |
| `/summon/trial/:id` | 체험전 | 미보유 픽업 시험 사용 |
| `/journal` | 여행 수첩 | 해금 이야기·회상·지역 기록 |
| `/inventory` | 보관함 | 장비, 조각, 재화 |
| `/shop` | 상점 | 상품, 패키지 |
| `/mail` | 우편 | 보상 수령 |
| `/settings` | 설정 | 계정 연결, 음량, 언어, 데이터 초기화 |

### 2.1 캠프(메인) 하단 탭

```
[모험]  [편성]  [캠프]  [던전]  [소환]
                 ↑ 홈
```

우측 상단: 재화 표시(골드, 모집티켓, 조각). 좌측 상단: 프로필·동행레벨.
캠프 화면 안에 배치: 소풍/이벤트 배너, 일일 미션, 우편, 여행 수첩 진입.

---

## 3. 상태관리 구조 (Riverpod)

```dart
// application/providers/

/// 앱 전역 — 부트스트랩 완료된 데이터팩
@Riverpod(keepAlive: true)
Future<Datapack> datapack(DatapackRef ref) => ...;

/// 계정 상태 (Firestore 스트림 + 로컬 미러)
@Riverpod(keepAlive: true)
Stream<AccountState> account(AccountRef ref) => ...;

/// 편성 (로컬 우선, 변경 시 디바운스 후 서버 동기화)
@riverpod
class FormationController extends _$FormationController {
  @override FormationState build() => ...;
  void setSlot(int index, String? characterId);
  void setEquipment(int index, String? equipmentId);
  void applyPreset(int presetIndex);
  void savePreset(int presetIndex);

  /// ★ 편성이 바뀔 때마다 팀 태그 레벨을 즉시 재계산해 UI에 노출
  TeamTagPreview get teamTagPreview;
}

/// 전투 세션 — 화면 수명 동안만
@riverpod
class BattleSessionController extends _$BattleSessionController {
  @override BattleSessionState build() => BattleSessionState.idle();
  Future<void> start(String stageId);
  void summon(int slot);
  void castUltimate();
  void buyFocusBoost(int stage);
  void setSpeed(int multiplier);
  void pause();
  Future<BattleSubmitResult> finish();
}
```

### 3.1 팀 태그 프리뷰 (편성 화면 핵심 UX)

```dart
class TeamTagPreview {
  /// tagId → 팀 레벨
  final Map<String, int> formationLevels;
  /// 현재 활성화된 티어 효과 목록 (설명 문자열 포함)
  final List<ActiveTierInfo> activeTiers;
  /// "동물 1개만 더하면 Lv6 티어" 같은 다음 목표
  final List<NextTierHint> nextTierHints;
  /// 이 편성에서 발동 가능한 관계 규칙 예고
  final List<RelationHint> relationHints;
}
```

편성 화면 하단에 접히는 패널로 표시:

```
┌─ 팀 태그 ────────────────────────────────┐
│ 🐾동물 Lv4  🍄식물 Lv2  🔥불 Lv1  ☀해 2 🌙달 2 🌿들 1 │
│                                          │
│ ✔ 동물 Lv3 — 동물 계열 공격력 +2%, 방어력 +2% │
│ ○ 동물 Lv6 — 공/방 +5% (동물 2 더 필요)       │
│                                          │
│ ⚠ 겁쟁이(버섯)가 용감(곰) 뒤에 오면 느려집니다  │
└──────────────────────────────────────────┘
```

`nextTierHints`가 있으면 "몇 개 더 필요"를 항상 보여준다. 이게 파밍 동기다.

---

## 4. Flame 레이어

### 4.1 컴포넌트 트리

```
BattleGame (FlameGame, HasCollisionDetection 미사용 — 충돌은 시뮬이 담당)
├─ CameraComponent (fixedResolution: 1280×720 논리)
│  └─ World
│     ├─ BackgroundLayer (parallax, depth 0)   sky
│     ├─ BackgroundLayer (parallax, depth 1)   far trees
│     ├─ BackgroundLayer (parallax, depth 2)   mid trees
│     ├─ GroundLayer (depth 3)                 tiled ground
│     ├─ BaseComponent (campfire, 왼쪽)
│     ├─ BaseComponent (nest, 오른쪽)
│     ├─ UnitLayer (PositionComponent, 자식 = UnitComponent들)
│     │  └─ UnitComponent × N  (priority = x 기준 정렬로 앞뒤 겹침 처리)
│     ├─ ProjectileLayer
│     ├─ VfxLayer
│     └─ DamageTextLayer
└─ HudRoot (Flutter 위젯 오버레이로 처리 — Flame 위젯이 아님)
```

> **HUD는 Flutter 위젯으로 만든다.** 소환 버튼, 기도력 게이지, 편성 페이지 전환,
> 필살기 버튼, 배속 토글은 모두 Flutter. Flame 위에 `Stack`으로 얹는다.
> 이유: 접근성, 텍스트 렌더 품질, 애니메이션 위젯 재사용, 레이아웃 대응.

```dart
// presentation/screens/battle/battle_screen.dart
Stack(children: [
  GameWidget(game: battleGame),
  BattleHud(),          // 기도력, 소환 슬롯 5칸 + 페이지 탭, 필살기, 배속, 일시정지
  if (paused) PauseOverlay(),
  if (tutorialStep != null) TutorialOverlay(step: tutorialStep),
])
```

### 4.2 sim → view 브릿지

```dart
// game/battle_view_model.dart

class BattleViewModel {
  /// 매 프레임 호출. world를 읽어 렌더 상태를 갱신한다. world를 변경하지 않는다.
  void sync(BattleWorld w, double alpha) {
    // 1) 엔티티 diff
    for (final e in w.entities.ordered) {
      var vc = _components[e.id];
      if (vc == null) { vc = _createComponent(e); _components[e.id] = vc; }
      vc.applyState(e, alpha);
    }
    // 2) 사라진 엔티티 (사망 애니메이션 끝난 후 제거)
    _reapDead();
    // 3) 이벤트 소비 → VFX/SFX/데미지텍스트
    for (final ev in w.events.drain()) { _handleEvent(ev); }
  }
}
```

### 4.3 위치 보간

시뮬은 30Hz, 화면은 60Hz. 보간 없이 그리면 계단처럼 보인다.

```dart
class UnitComponent extends PositionComponent {
  int _prevSimX = 0;
  int _currSimX = 0;

  void applyState(BattleEntity e, double alpha) {
    if (e.x != _currSimX) { _prevSimX = _currSimX; _currSimX = e.x; }
    final double lx = _prevSimX + (_currSimX - _prevSimX) * alpha;
    position.x = lx / POS_SCALE * pixelsPerLogicalUnit;
    priority = (position.x * 10).toInt();   // 앞에 있는 유닛이 위로
    _syncClip(e);
  }
}
```

- 넉백 중에는 보간을 유지하되 `curve` 없이 선형. 시뮬이 이미 등속으로 밀고 있다.
- 사망 시 시뮬에서는 즉시 제거되지만, 컴포넌트는 `death` 클립이 끝날 때까지 남긴다
  (`_reapDead()`가 클립 종료를 확인).

### 4.4 논리 좌표 → 픽셀

```dart
const double LOGICAL_FIELD_LENGTH = 2400;
const double VIEW_WIDTH = 1280;          // fixedResolution 가로
const double VISIBLE_FIELD = 1600;       // 화면에 한 번에 보이는 전장 길이
const double pixelsPerLogicalUnit = VIEW_WIDTH / VISIBLE_FIELD;   // 0.8
```

카메라는 **전선(가장 앞선 아군과 가장 앞선 적의 중간)** 을 따라간다.

```dart
double _cameraTargetX(BattleWorld w) {
  final frontAlly = w.frontmostAllyX ?? 0;
  final frontEnemy = w.frontmostEnemyX ?? LOGICAL_FIELD_LENGTH * POS_SCALE;
  final mid = (frontAlly + frontEnemy) / 2;
  return mid.clamp(minCamX, maxCamX);
}
// 스프링 추적 (렌더 전용, 시뮬 무관)
camX += (_cameraTargetX(w) - camX) * 0.08;
```

플레이어가 드래그하면 수동 모드로 전환, 3초간 입력 없으면 자동 추적 복귀.

---

## 5. 애니메이션 타이밍 매핑 (★ 아트 발주와 직결)

전투 판정은 틱 기반이고 애니메이션은 프레임 기반이다. **판정 순간과 그림의 타격 순간이 어긋나면
"안 맞은 것 같은데 죽는" 느낌**이 난다. 다음 규칙으로 강제 정렬한다.

### 5.1 공격 클립 3분할

```
attack 클립을 3구간으로 나눠 제작한다.

[windup]  [impact]  [recover]
 3프레임    1프레임    4프레임        ← 예: 총 8프레임

재생 시:
  windup 구간을  A틱 (attackWindup) 에 맞춰 시간 스케일
  impact 프레임은 판정 틱에 정확히 표시
  recover 구간을 R틱 (attackPeriod - attackWindup) 에 맞춰 시간 스케일
```

```dart
class AttackClipPlayer {
  /// A=12틱(0.4초), windupFrames=3 → 프레임당 4틱
  void play({required int windupTicks, required int recoverTicks}) {
    windupFrameDurationMs = windupTicks * 1000 ~/ TICKS_PER_SEC ~/ windupFrames;
    recoverFrameDurationMs = recoverTicks * 1000 ~/ TICKS_PER_SEC ~/ recoverFrames;
  }
}
```

**아트 제작 요구사항:** `characters.json`의 `art.clips.attack`에
`windupFrames`, `impactFrame`, `recoverFrames`를 반드시 명시. 이 값이 없으면 로딩 검증 실패.

### 5.2 클립 → 상태 매핑

| `EntityAction` / 이벤트 | 재생 클립 | 우선순위 |
|---|---|---|
| `spawn` (등장 후 N프레임) | `spawn` | 최상위(중단 불가) |
| `dead` | `death` | 최상위(중단 불가) |
| `knockback` | `knockback` | 높음 |
| `stunned` | `stun` (없으면 `idle` 틴트) | 높음 |
| `attackWindup` / `attackRecover` | `attack` (3분할 재생) | 중 |
| `moving` | `move` | 낮음 |
| `idle` | `idle` | 최하 |
| `DamageDealtEvent` 수신 | `hit` **1회 오버레이** (0.1초, 클립 중단 없이 틴트+셰이크) | 오버레이 |

- 피격은 **클립을 바꾸지 않고** 흰색 틴트 + 3px 셰이크로 처리한다.
  공격 모션 중 피격되어 클립이 리셋되면 판정 타이밍이 깨진다.
  단 `hit` 전용 클립이 있는 캐릭터는 `idle`/`move` 중에만 재생한다.

### 5.3 방향

- 아군은 우향, 적은 좌향. 스프라이트는 **우향 1방향만 제작**하고 적은 `flipHorizontally()`.
- 텍스트/장식이 들어간 스프라이트만 별도 좌향 제작.

---

## 6. 태그 UI 컴포넌트

```dart
/// 태그 칩 — 카테고리 색 + 아이콘 + 이름 + 레벨 뱃지
class TagChip extends StatelessWidget {
  const TagChip({required this.tagId, required this.level, this.size = TagChipSize.md});
}
```

| 카테고리 | 색 |
|---|---|
| RACE | 갈색 `#C08A4A` |
| ELEMENT | 속성별 (불 `#E8734A`, 물 `#5AA9D6`, 나무 `#7FB069`, 바람 `#A8D8C8`, 흙 `#B99668`, 빛 `#F2D98D`, 어둠 `#7B6C8A`) |
| TEMPER | 해 `#F2C14E` / 달 `#8E9DCC` / 들 `#9DC183` |
| BUILD | 살구 `#EFB08C` |
| TRAIT | 크림 `#E6D7B8` |
| HABIT | 연두 `#C3D98B` |
| ROLE | 회색 `#B8B0A8` |

**레벨 표시:** 칩 우측에 `Lv2` 뱃지. Lv1은 뱃지 생략(노이즈 감소).
**출처 표시:** 장비/버프로 얻은 레벨은 뱃지에 작은 점(`•`)을 붙이고 롱프레스 시
"고유 1 + 장비 1 = Lv2" 내역을 보여준다.

### 6.1 전투 중 태그 표현

- 유닛 발밑에 **최대 2개**의 소형 아이콘만 (현재 활성 시너지 / 관계). 그 이상은 시야를 가린다.
- 유닛 탭 → 우측 슬라이드 패널에 전체 태그·모디파이어 내역 (일시정지 상태에서만).
- 관계 발동/해제 시 짧은 아이콘 팝 + 이동속도 화살표(↑/↓) 0.6초.

---

## 7. 전투 HUD 레이아웃

```
┌────────────────────────────────────────────────────────────┐
│ ⏸  ×1/×2      🌤 [────●────] 날씨      ⏱ 03:24            │  상단바
│                                                            │
│                    (Flame 캔버스)                          │
│                                                            │
│ 🔥모닥불 ████████░░ 24,800/28,000        🪹둥지 ██████░░ │  기지 HP
├────────────────────────────────────────────────────────────┤
│ 🙏 기도력  ████████████░░░░  1,240 / 1,600   [집중강화 2단계 250]│
├────────────────────────────────────────────────────────────┤
│ [1페이지][2페이지]                                          │
│ ┌────┐┌────┐┌────┐┌────┐┌────┐               ┌──────────┐ │
│ │도토리││물방울││버섯 ││ 새  ││ 곰  │               │ 간절한기도 │ │
│ │ 75 ││ 200││ 350││ 500││ 900│               │  ⚡ 1     │ │
│ │ ✓  ││ ✓  ││ ⏳3s││ ✗  ││ ✗  │               └──────────┘ │
│ └────┘└────┘└────┘└────┘└────┘                             │
└────────────────────────────────────────────────────────────┘
```

**소환 슬롯 상태 표시**
| 상태 | 표현 |
|---|---|
| 소환 가능 | 밝게, 비용 흰색 |
| 기도력 부족 | 비용 빨강, 슬롯 60% 어둡게, 남은 대기 초 표시 |
| 쿨타임 | 원형 쿨다운 오버레이 + 남은 초 |
| 상한 도달 | 슬롯 위 "가득" 배지 |
| 비용 > 상한 | 자물쇠 아이콘 + "집중 강화 필요" |

기도력 게이지는 **다음 소환 가능 시점을 눈금으로 표시**한다 (기획서 6-2의 대기시간 공식 활용).

---

## 8. 로컬 저장 (Hive)

| 박스 | 키 | 값 |
|---|---|---|
| `settings` | `bgmVolume`, `sfxVolume`, `battleSpeed`, `locale`, `skipStory` | primitive |
| `datapack` | `version`, `files/<path>` | 다운로드된 JSON 원문 |
| `accountMirror` | `state` | `AccountState` JSON (오프라인 표시용) |
| `formations` | `preset0..2`, `current` | 편성 JSON |
| `battleResume` | `session` | 진행 중 전투 `serialize()` 바이트 |
| `pendingSubmits` | `<battleId>` | 네트워크 실패로 제출 못한 결과 (재시도 큐) |
| `tutorial` | `completedSteps` | 진행도 |

### 8.1 전투 재접속 복구

```
앱이 백그라운드로 갈 때 (AppLifecycleState.paused)
  → world.serialize() 를 battleResume 박스에 저장
  → 전투 일시정지

앱 복귀
  → battleResume 이 있으면 "진행 중인 전투를 이어서 할까요?" 다이얼로그
  → 이어하기: deserialize 후 재개
  → 포기: 서버에 abandonBattle(battleId) 호출, 보상 없음

서버 정책: battleId TTL 초과 시 만료 처리 (06_BACKEND.md §4.4)
```

---

## 9. 프롤로그 / 튜토리얼 구현

### 9.1 프롤로그 (`/prologue`)

기획서 §4: 교회 창의 빛 → 소녀가 눈을 뜸 → 문밖을 봄 → 일어나 걸어 나감 → 화창한 숲.

```dart
class PrologueScreen extends ConsumerStatefulWidget { }
```

- `story/prologue.json` 의 `beats` 를 순차 재생 (BG/LINE/SFX/FADE/CAMERA).
- 스킵 버튼 항상 노출. 스킵해도 `journal` 에 등록되어 다시 볼 수 있다.
- 정적 일러 3~4장 + 간단한 카메라 이동(Ken Burns) + 파티클로 구현.
  **풀 애니메이션 컷신은 만들지 않는다** (제작비 대비 효과 낮음).

### 9.2 튜토리얼 (`/tutorial`)

기획서 §4 표의 7단계를 `TutorialStep` 데이터로 정의.

```dart
class TutorialStep {
  final String id;
  final TutorialGate gate;        // 언제 다음으로 넘어가는가
  final String textKey;
  final HighlightTarget? highlight; // 어떤 UI를 강조하고 나머지를 잠글까
  final bool pauseSim;              // 시뮬을 멈춰서 읽을 시간을 줄까
}
```

```jsonc
[
  { "id":"T1", "textKey":"tut.1", "highlight":"PRAYER_GAUGE",
    "gate":{"kind":"PRAYER_AT_LEAST","value":75}, "pauseSim":true },
  { "id":"T2", "textKey":"tut.2", "highlight":"SLOT_0",
    "gate":{"kind":"SUMMONED","characterId":"CHR_ACORN"}, "pauseSim":false },
  { "id":"T3", "textKey":"tut.3", "highlight":"SLOT_1",
    "gate":{"kind":"SUMMONED","characterId":"CHR_DROPLET"} },
  { "id":"T4", "textKey":"tut.4", "highlight":"SLOT_0",
    "gate":{"kind":"FRONTLINE_BELOW","x":700} },
  { "id":"T5", "textKey":"tut.5", "highlight":"ULTIMATE",
    "gate":{"kind":"ULTIMATE_USED"}, "pauseSim":true },
  { "id":"T6", "textKey":"tut.6", "highlight":"NEST",
    "gate":{"kind":"NEST_DESTROYED"} },
  { "id":"T7", "textKey":"tut.7", "gate":{"kind":"REWARD_CLAIMED"} }
]
```

- 튜토리얼 전투는 **별도 스테이지 데이터** (`STG_TUTORIAL`). 일반 스테이지 수치와 분리.
- 목표 시간 60~90초.
- 진행도는 `tutorial` 박스 + 서버 `progress.tutorialStep` 양쪽에 저장 (기기 변경 대응).

---

## 10. 접근성·품질

- **최소 터치 타깃 48×48dp.** 소환 슬롯은 화면 하단 30% 안, 엄지 도달 범위.
- 세로/가로 대응: 전투는 **가로 고정**(`SystemChrome.setPreferredOrientations`),
  나머지 화면은 세로 우선. 진입/이탈 시 전환 애니메이션.
- 노치/세이프에어리어: `SafeArea` + `MediaQuery.viewPadding` 반영.
- 텍스트 크기 배율 대응: HUD 숫자는 고정, 대사·설명은 `MediaQuery.textScaler` 반영.
- 색약 대응: 태그·속성을 색만으로 구분하지 않고 **아이콘 형태**를 다르게.
- 저사양 모드: 파티클 밀도 50%, 그림자 off, 배경 레이어 3→2, 데미지 텍스트 축약.
  `SettingsScreen`에서 수동 전환 + 첫 실행 시 기기 등급 자동 추정.

---

## 11. 성능 체크리스트 (Flame)

- [ ] 모든 스프라이트를 **아틀라스(TexturePacker/한 장 PNG)** 로 묶어 드로우콜 최소화
- [ ] `SpriteAnimation`은 캐릭터 단위로 **1회 로드 후 공유** (`AnimationBank`)
- [ ] `UnitComponent`는 풀링. 사망 후 재사용
- [ ] 데미지 텍스트는 최대 20개 풀, 초과 시 오래된 것 재사용
- [ ] `priority` 재정렬은 매 프레임이 아니라 **x 변화가 있을 때만**
- [ ] 파티클은 `ParticleSystemComponent` 대신 사전 렌더된 스프라이트 시트 사용
- [ ] `world.events` 는 프레임당 1회만 drain
- [ ] 배경 파랄랙스는 `SpriteComponent` 3~4장 반복 타일링 (개별 나무 컴포넌트 금지)
- [ ] DevTools 타임라인에서 `update` ≤ 3ms, `raster` ≤ 8ms 확인
