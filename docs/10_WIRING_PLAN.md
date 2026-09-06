# 10. 배선 계획 (T-56 ~ T-63)

> `09_MILESTONES.md`의 T-01~T-55는 전부 끝났다. 하지만 그 티켓들은
> **"서버 함수"와 "화면 위젯"을 각각 따로** 만들었고, 둘을 잇는 티켓이
> 없었다. 이 문서는 그 빈틈을 메우는 티켓 목록이다.
>
> 티켓 형식과 사용법은 `09_MILESTONES.md`와 동일하다.

---

## 현황 조사 (2026-09-06 기준)

### 다 만들어져 있는 것

| 영역 | 상태 |
|---|---|
| 전투 코어 `lib/battle/` | 완성 (T-02~T-21) |
| Cloud Functions | 16종 완성 + 단위 테스트 |
| 데이터 로더 | 8종 완성 — datapack, tag, dungeon, exchange, equipment, banner, growth, weather, story |
| 로컬 저장소 | 5종 완성 — settings, formation, tutorial, journal, pendingSubmits |
| 화면 위젯 | splash, story_player, adventure_map, stage_brief, battle(+HUD), battle_result, formation, dungeon, exchange, summon, trial, tutorial_overlay |

### 비어 있는 것

**(a) 화면이 아예 없음**

- 빈 폴더: `presentation/screens/camp/`, `character_detail/`, `journal/`, `settings/`
- 폴더조차 없음: inventory, shop, mail, deepforest, friends

**(b) 화면은 있는데 라우터가 `PlaceholderScreen`을 걸어둠**

- `/formation` — `formation_screen.dart`가 멀쩡히 존재
- `/tutorial` — `tutorial_overlay.dart` + `tutorial_controller.dart`가 존재

**(c) 만든 걸 아무도 안 부름 — 이것이 근본 원인**

`lib/` 안(`lib/data/` 자기 자신 제외)에서의 실제 사용처 개수:

```
DungeonDataLoader 0   ExchangeDataLoader 0   EquipmentDataLoader 0
BannerDataLoader  0   GrowthConfigLoader 0   WeatherConfigLoader 0
StoryLoader       0   TagDataLoader      0
FormationRepository 0 TutorialRepository 0   SettingsRepository 0
BattleSubmitQueue 0   ServerTimeSource   0
```

`initHiveForApp()`도 어디서도 호출되지 않는다 — 로컬 저장이 통째로 죽어 있다.
앱에서 실제로 서버를 부르는 곳은 `server_time_source.dart` 한 군데뿐이다.

가장 상징적인 곳이 `splash_screen.dart`다. 데이터팩을 진행률까지 보여주며
로딩한 다음 **그 결과를 버리고** `/camp`로 간다. 받아둘 곳이 없기 때문이다.
그래서 이후 모든 라우트가 `router.dart`의 `_demo*()` 폴백으로 떨어진다.

**진단: `lib/application/`(`providers/`, `usecase/`)과 `lib/data/repository/`가
빈 디렉터리다. 조립하는 층이 통째로 없다.**

---

## T-56 AppScope — 조립 지점

- **목표:** 부팅 시 한 번 채워지고 앱 전체가 읽는 상태 컨테이너 하나를 만든다.
- **산출물:** `lib/application/app_scope.dart`, `main.dart` 수정
- **설계 제약:**
  - 상태관리 패키지를 새로 넣지 않는다. `ChangeNotifier` + `InheritedNotifier`면 충분하다.
    필요한 건 "부팅 때 한 번 채우고 가끔 갱신되는 객체 하나"가 전부다.
  - 로더별 리포지토리 클래스를 새로 만들지 않는다. 로더는 이미 있다. 담을 곳만 없다.
- **담을 것:** 로더 8종의 결과(datapack, tagBundle, dungeonConfig, exchangeConfig,
  equipmentById, bannerCatalog, growthConfig, weatherConfig, story), `AccountState`,
  로컬 리포지토리 5종
- **완료 조건:**
  - `main.dart`에서 `initHiveForApp()` 호출됨
  - 스플래시가 로딩 결과를 `AppScope`에 넣고, 진행률이 로더 8종 전체를 반영
  - `router.dart`의 `_demoBattleWorld` / `_demoChapterStages` / `_demoDungeonConfig` /
    `_demoExchangeConfig` / `_demoBannerCatalog` / `_NoopJournalStore` **6개가 삭제됨**
  - `flutter analyze` 경고 0

> 이 티켓은 추가보다 **삭제가 많아야** 정상이다. 새로 쓰는 코드가 라우터에서
> 지우는 코드보다 많다면 과하게 만들고 있는 것이다.

---

## T-57 이미 있는 화면 라우터에 연결

- **목표:** `PlaceholderScreen`으로 가려진 완성 화면 2개를 노출한다.
- **산출물:** `router.dart` 수정
- **완료 조건:**
  - `/formation` → 실제 `FormationScreen` (datapack / tagBundle / FormationRepository는 T-56에서 주입)
  - `/tutorial` → 실제 튜토리얼 흐름 (`TutorialController` + `TutorialOverlay`)
  - 편성 프리셋 저장 후 앱 재시작 시 유지됨 (Hive 살아 있는지 검증)

---

## T-58 캠프 화면

- **목표:** 허브 화면 신규 작성. 지금 `PlaceholderScreen('캠프')`인 곳.
- **산출물:** `lib/presentation/screens/camp/camp_screen.dart`
- **완료 조건:**
  - 재화(금화, 기도력 관련 표시) + 동행/집중력/캠프 레벨을 `AccountState`에서 읽어 표시
  - 모험 / 편성 / 소환 / 요일던전 / 교환소 / 보관함 / 우편 / 여행수첩 / 설정 진입 동선
  - 화면 자체에 로직 없음 — 읽고 `context.push`만 한다

---

## T-59 콜러블 클라이언트

- **목표:** Cloud Functions 16종을 부르는 얇은 래퍼를 **한 파일**에 만든다.
- **산출물:** `lib/data/remote/api.dart`
- **설계 제약:** 함수마다 리포지토리 클래스를 만들지 않는다. 함수 하나당 Dart 함수 하나.
- **완료 조건:**
  - 리전은 `asia-northeast3` 고정 (`06_BACKEND.md §5`)
  - 에러를 `FirebaseFunctionsException` 그대로 던지지 말고 화면이 쓸 수 있는 형태로 정리
  - 에뮬레이터 붙은 상태에서 `getServerTime` 왕복 성공

---

## T-60 전투 배선

- **목표:** 출격 → `startBattle` → 전투 → `submitBattle` → 결과 루프를 실제 서버로 잇는다.
- **완료 조건:**
  - 출격 브리핑에서 `startBattle` 호출 → 받은 시드/편성으로 `BattleWorld` 생성
  - 전투 종료 시 입력 로그를 `submitBattle`로 전송, 보상이 `AccountState`에 반영
  - 네트워크 실패 시 `PendingSubmitsRepository`에 적재 후 재시도 (`BattleSubmitQueue` 연결)
  - 같은 전투를 두 번 제출해도 보상 중복 없음 (서버 멱등성 + 클라이언트 확인)

---

## T-61 성장·소환·교환 배선

- **목표:** 라우터의 빈 콜백을 실제 호출로 교체한다.
- **대상:** `onPull`(gachaPull), `onExchange`/`onUpgrade`(exchangeItems),
  `onStartTrial`(체험전), 성장(levelUp / equipItem / enhanceEquipment)
- **완료 조건:**
  - 소환 10연 → 실제 캐릭터 획득 → 보유 목록·재화 즉시 갱신
  - 교환 포인트 200 선택 교환(`exchangePickup`) 동작
  - 재화 부족·조건 미달 시 서버 거부 사유가 화면에 뜸
  - `router.dart`에 `() {}` 형태의 빈 콜백이 **하나도 남아 있지 않음**

---

## T-62 던전·반복 콘텐츠 배선

- **목표:** `onDifficultyTap`(요일던전 입장), `sweepDungeon`, `claimDeepForestRewards`,
  `claimMission`, `claimMail` 연결.
- **완료 조건:**
  - 요일 제한·일일 입장 횟수가 서버 게임데이(`getServerTime` / `gameDay`) 기준으로 판정
  - 소탕 보상과 직접 플레이 보상이 동일 규칙
  - 깊은 숲 최고 층 기록 유지, 주간 보상 상태만 초기화

---

## T-63 남은 화면

- **목표:** 아직 `PlaceholderScreen`인 라우트를 실제 화면으로.
- **대상:** `/deepforest`, `/inventory`, `/shop`, `/mail`, `/journal`, `/friends`,
  `/settings`, 캐릭터 상세
- **완료 조건:** `PlaceholderScreen`을 쓰는 라우트가 0개, `placeholder_screen.dart` 삭제

---

## 권장 순서

```
T-56  ─┬─ T-57 ─┬─ T-58        여기까지: 캠프→편성→모험이 실제 데이터로 돈다
       │        │
       └─ T-59 ─┴─ T-60 ─ T-61 ─ T-62      여기까지: 서버 붙은 게임 루프 완성
                                    │
                                    └─ T-63   여기까지: 빈 화면 없음
```

T-56 없이는 나머지 전부가 막힌다. 반대로 T-56~T-58만 끝나도
"캠프에서 편성하고 모험 나가서 싸운다"를 실제 데이터로 확인할 수 있다.

---

## 개발 환경 메모

에뮬레이터 실행에 필요한 것 (`06_BACKEND.md §10` 보충):

- **JDK 21 이상** — firebase-tools 15부터 Java 20 이하를 거부한다.
  이 PC 기준 `C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot`.
  안드로이드 Gradle이 JDK 17을 쓰고 있으므로 `JAVA_HOME`을 영구로 21에 박지 말고
  에뮬레이터 터미널에서만 세션 변수로 준다.
- `firebase` 전역 설치 불필요 — `functions/node_modules/.bin/firebase`에 있다.
- TypeScript 수정 후에는 `npm --prefix functions run build`를 다시 돌려야 반영된다.

```powershell
# 터미널 1
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-21.0.12.101-hotspot"
.\functions\node_modules\.bin\firebase.cmd emulators:start --project demo-wse-defense

# 터미널 2
flutter run -d chrome --dart-define=USE_EMULATOR=true
```

에뮬레이터 UI: http://127.0.0.1:4000

> 참고: 모든 Callable의 리전을 `asia-northeast3`로 맞추는
> `setGlobalOptions`가 `functions/src/index.ts`에 있다. 이게 없으면 함수가
> us-central1에 등록되어 클라이언트 호출이 전부 404가 된다.
