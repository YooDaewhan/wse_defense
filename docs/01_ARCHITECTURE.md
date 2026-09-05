# 01. 아키텍처와 폴더 구조

## 1. 레이어 원칙

```
┌──────────────────────────────────────────────┐
│  presentation/   Flutter 위젯 화면 (UI)        │
│  game/           Flame 렌더 레이어             │  ← 여기서만 Flame/Flutter 사용
├──────────────────────────────────────────────┤
│  application/    유스케이스, Riverpod Provider │
├──────────────────────────────────────────────┤
│  domain/         계정·성장·편성 도메인 모델      │
├──────────────────────────────────────────────┤
│  battle/         ★ 전투 코어 (순수 Dart)        │  ← Flutter/Flame import 금지
├──────────────────────────────────────────────┤
│  data/           JSON 로더, Firestore, 로컬DB   │
└──────────────────────────────────────────────┘
```

### 절대 규칙 (린트로 강제)

1. `lib/battle/**` 는 `dart:core`, `dart:math`, `dart:typed_data`, `dart:convert` 만 import 한다.
   `package:flutter`, `package:flame`, `dart:ui`, `dart:io` **금지**.
2. `lib/battle/**` 는 `DateTime.now()`, `Random()` (시드 없는), `hashCode` 기반 정렬,
   `Set`/`Map` 순회 순서 의존을 **금지**한다. → 결정론 파괴 원인.
3. 렌더 레이어는 전투 상태를 **읽기만** 한다. 전투 상태 변경은 `BattleWorld.enqueueInput()` 으로만.
4. `presentation/` 은 `battle/` 을 직접 import 하지 않는다. `application/` 의 뷰모델을 통한다.

`analysis_options.yaml` 에 `import_lint` 또는 커스텀 `dart_code_metrics` 규칙으로 1번을 CI에서 검사.

---

## 2. 폴더 트리

```
forest_summon/
├─ pubspec.yaml
├─ analysis_options.yaml
├─ assets/
│  ├─ data/                     # 게임 데이터 JSON (버전별 데이터팩)
│  │  ├─ v1/
│  │  │  ├─ tags.json
│  │  │  ├─ tag_effects.json
│  │  │  ├─ tag_relations.json
│  │  │  ├─ characters.json
│  │  │  ├─ skills.json
│  │  │  ├─ enemies.json
│  │  │  ├─ equipments.json
│  │  │  ├─ stages/
│  │  │  │  ├─ chapter_1.json
│  │  │  │  └─ ...
│  │  │  ├─ dungeons.json
│  │  │  ├─ exchange.json
│  │  │  ├─ growth.json        # 집중력/캠프방어/동행레벨 테이블
│  │  │  └─ weather.json
│  ├─ images/                   # 08_ASSET_PRODUCTION.md 참조
│  ├─ audio/
│  └─ fonts/
│
├─ lib/
│  ├─ main.dart
│  ├─ app/
│  │  ├─ app.dart               # MaterialApp, 라우터, 테마
│  │  ├─ router.dart
│  │  ├─ theme.dart
│  │  └─ bootstrap.dart         # 초기화 순서 (Firebase → 데이터팩 → 저장소)
│  │
│  ├─ battle/                   # ★ 순수 Dart 전투 코어
│  │  ├─ battle.dart            # barrel export
│  │  ├─ world/
│  │  │  ├─ battle_world.dart
│  │  │  ├─ battle_config.dart
│  │  │  ├─ battle_result.dart
│  │  │  ├─ battle_input.dart
│  │  │  └─ battle_snapshot.dart
│  │  ├─ entity/
│  │  │  ├─ battle_entity.dart
│  │  │  ├─ entity_state.dart
│  │  │  ├─ base_entity.dart    # 모닥불/둥지
│  │  │  └─ entity_id.dart
│  │  ├─ stat/
│  │  │  ├─ stat_key.dart
│  │  │  ├─ stat_sheet.dart
│  │  │  ├─ modifier.dart
│  │  │  └─ modifier_source.dart
│  │  ├─ tag/                   # ★ 02_TAG_SYSTEM.md
│  │  │  ├─ tag_id.dart
│  │  │  ├─ tag_def.dart
│  │  │  ├─ tag_registry.dart
│  │  │  ├─ tag_stack.dart
│  │  │  ├─ tag_query.dart
│  │  │  ├─ tag_contribution.dart
│  │  │  ├─ tag_effect.dart
│  │  │  ├─ tag_effect_resolver.dart
│  │  │  ├─ tag_relation_rule.dart
│  │  │  └─ tag_relation_resolver.dart
│  │  ├─ effect/
│  │  │  ├─ effect.dart
│  │  │  ├─ effect_type.dart
│  │  │  ├─ effect_registry.dart
│  │  │  ├─ effect_instance.dart
│  │  │  └─ handlers/           # 멈칫/느릿/밀치기/토닥임/...
│  │  ├─ skill/
│  │  │  ├─ skill_def.dart
│  │  │  ├─ trigger.dart
│  │  │  ├─ trigger_registry.dart
│  │  │  └─ target_selector.dart
│  │  ├─ system/                # ★ 실행 순서 = 03_BATTLE_ENGINE.md §3
│  │  │  ├─ battle_system.dart  # 인터페이스
│  │  │  ├─ input_system.dart
│  │  │  ├─ spawn_system.dart
│  │  │  ├─ tag_resolve_system.dart
│  │  │  ├─ relation_system.dart
│  │  │  ├─ status_system.dart
│  │  │  ├─ target_system.dart
│  │  │  ├─ movement_system.dart
│  │  │  ├─ attack_system.dart
│  │  │  ├─ damage_system.dart
│  │  │  ├─ knockback_system.dart
│  │  │  ├─ death_system.dart
│  │  │  ├─ resource_system.dart
│  │  │  ├─ weather_system.dart
│  │  │  └─ victory_system.dart
│  │  ├─ rng/
│  │  │  └─ deterministic_rng.dart
│  │  ├─ event/
│  │  │  ├─ battle_event.dart
│  │  │  └─ event_bus.dart
│  │  └─ defs/                  # 전투가 읽는 정적 정의(불변)
│  │     ├─ unit_def.dart
│  │     ├─ stage_def.dart
│  │     └─ wave_def.dart
│  │
│  ├─ data/
│  │  ├─ datapack/
│  │  │  ├─ datapack_loader.dart
│  │  │  ├─ datapack.dart       # 모든 정의의 인메모리 인덱스
│  │  │  └─ datapack_version.dart
│  │  ├─ local/
│  │  │  ├─ local_store.dart    # Hive 박스 래퍼
│  │  │  └─ boxes.dart
│  │  ├─ remote/
│  │  │  ├─ firebase_auth_source.dart
│  │  │  ├─ firestore_account_source.dart
│  │  │  ├─ functions_api.dart  # callable 래퍼
│  │  │  └─ dto/
│  │  └─ repository/
│  │     ├─ account_repository.dart
│  │     ├─ battle_repository.dart
│  │     ├─ dungeon_repository.dart
│  │     └─ gacha_repository.dart
│  │
│  ├─ domain/
│  │  ├─ account/               # 보유 캐릭터, 레벨, 재화
│  │  ├─ formation/             # 10칸 편성, 프리셋 3개
│  │  ├─ growth/                # 동행/집중력/캠프방어 계산
│  │  ├─ inventory/             # 장비, 조각, 재화
│  │  └─ progress/              # 스테이지 진행, 일일 횟수
│  │
│  ├─ application/
│  │  ├─ providers/             # Riverpod
│  │  ├─ battle_session.dart    # 전투 1회의 수명주기 관리
│  │  └─ usecase/
│  │
│  ├─ game/                     # Flame 렌더
│  │  ├─ battle_game.dart
│  │  ├─ battle_view_model.dart # sim → view 어댑터
│  │  ├─ components/
│  │  │  ├─ unit_component.dart
│  │  │  ├─ base_component.dart
│  │  │  ├─ projectile_component.dart
│  │  │  ├─ vfx_component.dart
│  │  │  ├─ damage_text_component.dart
│  │  │  └─ background_layer.dart
│  │  ├─ render/
│  │  │  ├─ animation_bank.dart
│  │  │  ├─ anim_clip_def.dart
│  │  │  ├─ sprite_atlas_loader.dart
│  │  │  └─ interpolator.dart
│  │  └─ audio/
│  │     └─ battle_audio.dart
│  │
│  └─ presentation/
│     ├─ screens/
│     │  ├─ splash/
│     │  ├─ prologue/
│     │  ├─ tutorial/
│     │  ├─ camp/               # 메인화면
│     │  ├─ adventure/          # 모험 지도
│     │  ├─ formation/          # 편성
│     │  ├─ battle/             # 전투 (Flame + HUD 오버레이)
│     │  ├─ character_detail/
│     │  ├─ dungeon/            # 요일던전
│     │  ├─ exchange/           # 교환소
│     │  ├─ summon/             # 소환(가챠)
│     │  ├─ journal/            # 여행 수첩
│     │  └─ settings/
│     └─ widgets/
│        ├─ tag_chip.dart       # 태그 표시 공통 위젯
│        ├─ tag_level_panel.dart
│        └─ ...
│
├─ test/
│  ├─ battle/
│  │  ├─ determinism_test.dart  # 같은 시드 → 같은 결과
│  │  ├─ tag_resolve_test.dart
│  │  ├─ knockback_test.dart
│  │  └─ golden_replay/         # 리플레이 회귀 테스트 데이터
│  └─ ...
│
├─ tool/
│  ├─ headless_sim.dart         # CLI 밸런스 시뮬레이터
│  ├─ balance_sweep.dart        # 편성 조합 승률 스윕
│  └─ atlas_pack.dart           # 스프라이트 아틀라스 패킹 헬퍼
│
└─ functions/                   # Cloud Functions (TypeScript)
   ├─ src/
   │  ├─ index.ts
   │  ├─ battle/
   │  ├─ gacha/
   │  ├─ dungeon/
   │  ├─ purchase/
   │  ├─ schedule/
   │  └─ common/
   └─ package.json
```

---

## 3. 결정론(Determinism) 규칙

전투는 **같은 (초기상태, 입력로그, 시드, 데이터버전) → 항상 같은 결과** 여야 한다.
이것이 무너지면 서버 검증, 리플레이, 2배속, 재접속 복구가 전부 깨진다.

### 3.1 수치

- **모든 전투 수치는 정수(int)로 다룬다.** 소수는 고정소수점 사용.
- 비율 계산은 **밀리퍼센트(1/100000 단위, `PCT_SCALE = 100000`)** 정수로 누적한다.
  - 예: +15% → `15000`
- 좌표: 논리 단위 × 1000 고정소수점 (`POS_SCALE = 1000`). 전장 길이 2400 → 내부 `2_400_000`.
- 속도: 논리단위/초 → 틱당 이동 = `speed * POS_SCALE ~/ TICKS_PER_SEC`
- 나눗셈은 항상 `~/` (정수 나눗셈). 반올림이 필요하면 `(a * b + c ~/ 2) ~/ c` 형태로 명시.
- `double` 을 전투 코어에서 쓰지 않는다. (렌더 보간에서만 사용)

```dart
const int TICKS_PER_SEC = 30;
const int PCT_SCALE = 100000;   // 100% == 100000
const int POS_SCALE = 1000;     // 논리좌표 1.0 == 1000
```

### 3.2 순서

- 엔티티 순회는 항상 **`entityId` 오름차순**. `entityId`는 스폰 순서대로 단조 증가하는 int.
- Map/Set 순회 금지. 필요하면 정렬된 `List<int>` 키를 별도 유지.
- 동일 틱 내 여러 피해는 `03_BATTLE_ENGINE.md §6` 의 확정 순서를 따른다.
- 시스템 실행 순서는 `BattleWorld.systems` 리스트 순서로 고정. 임의 재정렬 금지.

### 3.3 RNG

```dart
/// xorshift128. 시드 재현 가능. 스트림 분리로 시스템 간 간섭 방지.
class DeterministicRng {
  DeterministicRng(int seed);
  /// 용도별 독립 스트림. 새 확률 판정 추가 시 여기에만 항목 추가.
  DeterministicRng stream(RngStream s);
  int nextInt(int maxExclusive);
  /// 밀리퍼센트 확률 판정. p는 PCT_SCALE 기준.
  bool roll(int p);
}

enum RngStream { skillProc, critical, targetTie, spawnJitter, lootPreview }
```

- **모든 확률 판정은 스트림을 지정해야 한다.** 스트림별로 독립 카운터를 유지해
  기능 추가가 다른 기능의 난수열을 밀지 않게 한다.
- 클라이언트 연출용 난수(파티클 등)는 전투 RNG를 절대 쓰지 않는다.

### 3.4 부동소수점 금지 확인 테스트

`test/battle/determinism_test.dart`:

```
같은 시드로 300초 전투를 2회 실행 → 매 틱 체크섬 동일
1배속/2배속 실행 결과 동일
Web(dart2js) / VM 실행 결과 동일  ← int 53bit 제약 주의: 곱셈 중간값이 2^53 넘지 않게
```

> **주의:** Flutter Web을 지원할 계획이 있으면 `int`가 JS number(53bit)가 된다.
> `PCT_SCALE(1e5) × HP(1e6)` 같은 곱은 1e11로 안전하지만, 3중 곱은 위험하다.
> 곱셈은 2단계마다 `~/ PCT_SCALE` 로 축소한다.

---

## 4. 데이터 흐름

```
앱 시작
 └ bootstrap()
    ├ Firebase 초기화
    ├ Auth (익명 로그인 or 복구)
    ├ gameData 메타 조회 → dataVersion 확인
    ├ DatapackLoader: 로컬 캐시 vs 원격 비교 → 필요 시 다운로드
    ├ Datapack 파싱 → TagRegistry / EffectRegistry / 각종 Def 인덱스 구축
    └ AccountRepository: Firestore에서 계정 상태 로드 → 로컬 미러

전투 시작
 └ BattleSession.start(stageId, formation)
    ├ functions.startBattle() → battleId, seed, serverTimeMs
    ├ BattleConfig 조립 (편성 UnitDef + 성장치 + 장비 + 팀 태그 사전계산)
    ├ BattleWorld(config, seed) 생성
    ├ BattleGame(Flame)이 world를 참조, 매 프레임 accumulator로 tick 진행
    ├ 사용자 입력 → world.enqueueInput(SummonInput/UltimateInput/FocusBoostInput)
    │              → InputLog에도 기록
    └ 종료 → BattleResult + InputLog → functions.submitBattle()
```
