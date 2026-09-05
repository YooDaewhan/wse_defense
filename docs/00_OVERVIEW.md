# 00. 프로젝트 개요와 문서 맵

> 프로젝트 코드네임: **forest_summon** (숲속 소환 디펜스)
> 대상 플랫폼: Android / iOS (Flutter)
> 게임 엔진: Flutter + Flame
> 백엔드: Firebase 중심
> 전투 권위: **클라이언트 결정론 시뮬 + 서버 경량 검증**

이 문서 세트는 기획서(`game_design_final.md`)를 구현 가능한 형태로 번역한 기술 스펙이다.
바이브 코딩 시 각 문서를 개별 컨텍스트로 던져서 쓰는 것을 전제로 작성했다.

---

## 1. 문서 맵

| 파일 | 내용 | 주 사용 시점 |
|---|---|---|
| `00_OVERVIEW.md` | 전체 개요, 기술 결정, 용어 사전 | 항상 |
| `01_ARCHITECTURE.md` | 레이어 구조, 폴더 트리, 의존 규칙, 결정론 규칙 | 프로젝트 초기 셋업 |
| `02_TAG_SYSTEM.md` | **태그 시스템 전체 스펙** (종족·속성·특성, 레벨 스택, 위치 관계) | 태그/버프/장비 구현 |
| `03_BATTLE_ENGINE.md` | 전투 코어 엔진 (틱, 시스템 순서, 엔티티, 스탯 파이프라인) | 전투 구현 |
| `04_DATA_SCHEMA.md` | 모든 JSON 데이터 스키마 + 예시 데이터 | 데이터 작업 전반 |
| `05_FRONTEND.md` | Flutter/Flame 앱 구조, 화면, 렌더 브릿지 | 앱 UI/렌더 구현 |
| `06_BACKEND.md` | Firestore 스키마, Cloud Functions API, 보안 규칙, 검증 | 서버 구현 |
| `07_DUNGEON_EXCHANGE.md` | 요일던전 5난이도 + 조각 10개 교환 시스템 | 반복 콘텐츠 구현 |
| `08_ASSET_PRODUCTION.md` | **제작해야 할 에셋 전체 목록** (애니메이션/배경/UI/VFX/SFX) | 아트 발주·제작 |
| `09_MILESTONES.md` | 구현 순서를 프롬프트 단위 티켓으로 분해 | 개발 진행 관리 |

---

## 2. 기술 스택 결정

### 2.1 클라이언트

| 영역 | 선택 | 이유 |
|---|---|---|
| 프레임워크 | Flutter 3.x (Dart 3.x) | 단일 코드베이스, Flame 생태계 |
| 게임 렌더 | Flame 1.x | 스프라이트 애니메이션, 카메라, 컴포넌트 트리 |
| 전투 로직 | **순수 Dart** (Flame/Flutter 의존 0) | 서버 재실행·유닛테스트·헤드리스 밸런스 시뮬 |
| 상태관리 | Riverpod 2.x (`riverpod_generator`) | 화면/도메인 분리, 테스트 용이 |
| 라우팅 | go_router | 딥링크(공지·우편) 대응 |
| 로컬 저장 | Hive (또는 Isar) | 편성 프리셋, 캐시, 데이터팩 |
| 직렬화 | `freezed` + `json_serializable` | 불변 데이터 모델 |
| 오디오 | flame_audio (내부적으로 audioplayers) | BGM/SFX |
| 로컬라이즈 | `flutter_localizations` + ARB | ko 우선, en 확장 대비 |

### 2.2 백엔드

| 영역 | 선택 |
|---|---|
| 인증 | Firebase Auth (익명 시작 → 계정 연결) |
| DB | Cloud Firestore |
| 서버 로직 | Cloud Functions for Firebase (Node 20, TypeScript) |
| 밸런스/데이터 배포 | Cloud Storage(데이터팩 JSON) + Firestore `gameData` 메타 |
| 원격 스위치 | Firebase Remote Config |
| 결제 검증 | Cloud Functions + Google Play / App Store 서버 검증 |
| 지표 | Firebase Analytics + BigQuery export |
| 크래시 | Crashlytics |
| 푸시 | FCM |
| 스케줄 | Cloud Scheduler → Pub/Sub → Functions (일일/주간 초기화) |

### 2.3 전투 권위 모델 (확정)

```
[클라이언트]
  전투 시작 → startBattle() 호출 → 서버가 battleId + rngSeed + dataVersion 발급
  30틱 고정 시뮬 실행. 모든 플레이어 입력을 InputLog에 기록
  전투 종료 → submitBattle(battleId, inputLog, summary, checksum)

[서버 (경량 검증)]
  1. battleId 유효성 / TTL / 1회성
  2. 제출 편성이 실제 계정 보유 캐릭터·장비와 일치하는지
  3. dataVersion 일치
  4. 통계적 이상치 검사 (아래 항목)
  5. 통과 시 보상 지급 (transaction + idempotencyKey)
```

**경량 검증 항목** (상세 규칙은 `06_BACKEND.md` §5)

- 클리어 시간 하한: 스테이지별 `minClearSec` 미만이면 반려
- 총 소환 비용 ≤ (기도력 시작량 + 회복량×시간 + 처치보상 상한)
- 소환 횟수 ≤ 시간/최소쿨타임 합
- 필살기 사용 횟수 ≤ floor((시간 - 초기충전시간)/60) + 1
- 처치한 적 수 ≤ 스테이지 웨이브 정의 총합
- 편성에 없는 캐릭터 소환 로그 → 반려
- inputLog 해시가 summary.checksum과 일치

> 서버 완전 재실행(리플레이)은 **M3 이후 확장 항목**으로 남긴다.
> 이를 위해 전투 코어를 순수 Dart로 격리해 두고, 필요 시 `dart compile exe`로
> Cloud Run 컨테이너에 올려 동일 엔진으로 재실행할 수 있게 설계한다.

---

## 3. 기획서 대비 추가·변경 사항

이 문서 세트에서 기획서에 **새로 추가**하거나 **정합성을 위해 조정**한 부분.

| 항목 | 기획서 | 이 스펙 |
|---|---|---|
| 기질/특징 | 해·달·들 + 특징 7종 (고정 개념) | **범용 태그 시스템으로 일반화**. 기질·특징·종족·속성·특성이 모두 같은 `Tag` 타입. `02_TAG_SYSTEM.md` |
| 태그 레벨 | 없음 (보유/미보유) | **레벨 개념 도입.** `통통함Lv1 → Lv2` 스택. 유닛 스코프 / 팀 스코프 분리 |
| 장비 | 고정 옵션 12종 | 고정 옵션 + **태그 부여(grantTags)** 기능 추가. 예: 동물탈 → `RACE_ANIMAL +1` |
| 위치 관계 | 없음 | **관계 태그 규칙** 도입 (겁쟁이/용감). 소환 순서·위치가 전술이 되게 함 |
| 소풍 | 3종 × 3난이도 (→5 확장) | **요일던전 3종 × 5난이도로 확정.** 조각 10개 교환소 추가. `07_DUNGEON_EXCHANGE.md` |
| 무기 | "장비" 표현 | 장비 = 무기/방구/장식 3슬롯이 아니라 **친구별 1슬롯 유지**. 단 장비가 태그를 줄 수 있음 |

기획서의 전투 수치(6-8, 6-9), 날씨 공식(6-7), 넉백 규칙(6-4)은 **그대로 유지**하며,
이 문서 세트에서는 그것을 태그/모디파이어 파이프라인 위에 재구성하는 방법만 정의한다.

---

## 4. 용어 사전 (코드 네이밍 통일)

| 한국어 | 코드 식별자 | 비고 |
|---|---|---|
| 틱 | `tick` | 30 tick/s 고정 |
| 논리 좌표 | `logicalX` | 전장 길이 2400 |
| 기도력 | `prayerPower` | 전투 자원 |
| 집중력 레벨 | `focusLevel` | 계정 성장 |
| 전투 중 집중 강화 | `focusBoostStage` | 0/1/2 |
| 캠프 방어 | `campDefenseLevel` | 모닥불 HP |
| 모닥불 | `campfire` | 아군 기지 |
| 적 둥지 | `nest` | 적 기지 |
| 동행 레벨 | `bondLevel` | 계정 공통 전투 레벨 |
| 친밀도 | `affinity` | |
| 기질 (해/달/들) | `TEMPER_SUN` / `TEMPER_MOON` / `TEMPER_FIELD` | 태그 |
| 특징 | `TRAIT_*` | 태그 |
| 종족 | `RACE_*` | 태그 |
| 속성 | `ELEM_*` | 태그 |
| 날씨 게이지 | `weatherGauge` | −100~100 |
| 날씨 상태 | `WeatherState.clear/dusk/night` | 맑음/노을/밤 |
| 넉백 | `knockback` | 자연=`natural`, 강제=`forced` |
| HP 구간 수 K | `hpSegments` | 사망 포함 |
| 공격 주기 P | `attackPeriodTicks` | |
| 발동 A | `attackWindupTicks` | |
| 후딜 R | `attackRecoverTicks` | |
| 재소환 대기 | `resummonCooldownTicks` | |
| 간절한 기도 (필살기) | `ultimate` | |
| 소풍 → 요일던전 | `dailyDungeon` | |
| 조각 | `shard` | 던전 드랍 소재 |
| 깊은 숲 | `deepForest` | 무한 층 콘텐츠 |
| 여행 수첩 | `journal` | |
| 체험전 | `trialBattle` | |

**파일/폴더 네이밍:** snake_case. **클래스:** UpperCamelCase. **데이터 ID:** `SCREAMING_SNAKE_CASE` (예: `CHR_ACORN`, `TAG_RACE_ANIMAL`, `STG_1_10`).

---

## 5. 개발 순서 요약

```
Phase 0  프로젝트 셋업 + 순수 Dart 전투 코어 스켈레톤 + 헤드리스 테스트
Phase 1  태그/모디파이어 파이프라인 + 기본 5종 + 단일/범위 공격 + 넉백
Phase 2  Flame 렌더 브릿지 + 전투 화면 + 소환 UI + 승패
Phase 3  프롤로그·튜토리얼·캠프 메인 + 편성 화면 + 로컬 저장
Phase 4  Firebase 연동 (인증/계정/진행도) + 스테이지 1장 10개
Phase 5  요일던전 5난이도 + 조각 교환소 + 장비(태그 부여 포함)
Phase 6  날씨 게이지 + 효과 라이브러리 확장 + 관계 태그(겁쟁이/용감)
Phase 7  소환(가챠) + 재화 + 서버 검증 + 결제
Phase 8  깊은 숲 / 주간 퍼즐 / 이벤트 템플릿
```

상세 티켓은 `09_MILESTONES.md`.
