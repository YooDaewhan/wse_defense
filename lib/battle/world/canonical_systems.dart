import '../system/attack_system.dart';
import '../system/battle_system.dart';
import '../system/damage_system.dart';
import '../system/death_system.dart';
import '../system/input_system.dart';
import '../system/knockback_system.dart';
import '../system/movement_system.dart';
import '../system/relation_system.dart';
import '../system/resource_system.dart';
import '../system/spawn_system.dart';
import '../system/status_system.dart';
import '../system/tag_resolve_system.dart';
import '../system/target_system.dart';
import '../system/victory_system.dart';
import '../system/weather_system.dart';

/// 03_BATTLE_ENGINE.md §3의 실행 순서 그대로 — 지금까지 구현된 전부를 쓰는
/// 실전 배틀 조합. `WeatherSystem`(T-45)은 ResourceSystem 바로 뒤에 둔다 —
/// 그래야 "회복 총량 상한 2%/초"의 예산 리셋+날씨 회복 지급이 StatusSystem
/// (HealHandler의 토닥임)보다 먼저 그 틱의 예산을 확정해서, 두 회복이
/// 진짜 하나의 예산을 나눠 쓴다(반대 순서면 나중에 도는 쪽이 리셋으로
/// 앞선 소비 기록을 지워버려 상한이 새 버린다). "활약" 샘플링(60틱마다
/// 게이지 갱신)이 그 대가로 직전 틱까지의 활약만 보는 건 결과에 영향이
/// 없는 무해한 1틱 지연이다.
///
/// `includeWeather: false`로 빼면 T-45 이전(M1)과 완전히 같은 시스템
/// 목록이 된다 — 09_MILESTONES.md T-45 완료조건("시스템 리스트에서 빼면
/// M1 동작과 완전히 동일")을 이 함수 자체가 보장한다.
///
/// `EventFlushSystem`(§3 #16)은 넣지 않는다 — 이 프로젝트에서 이벤트를
/// 비우는 주체는 "그 틱 안에서 자동으로"가 아니라 "그걸 소비하는
/// 쪽"(렌더 레이어의 `BattleWorld.drainEvents()`, 05_FRONTEND.md §4.2)이라,
/// 매 틱 자동으로 비우는 시스템을 두면 같은 틱 안에서 시스템→시스템으로
/// 동기 실행되는 구조상 `step()`이 끝나기도 전에 비워져 버려 외부에서
/// 절대로 이벤트를 관찰할 수 없게 된다.
List<BattleSystem> canonicalBattleSystems({bool includeWeather = true}) => [
  InputSystem(),
  ResourceSystem(),
  if (includeWeather) WeatherSystem(),
  SpawnSystem(),
  TagResolveSystem(),
  RelationSystem(),
  const StatusSystem(),
  KnockbackSystem(),
  TargetSystem(),
  MovementSystem(),
  AttackSystem(),
  DamageSystem(),
  DeathSystem(),
  VictorySystem(),
];
