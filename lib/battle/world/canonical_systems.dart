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

/// 03_BATTLE_ENGINE.md §3의 실행 순서 그대로 — 아직 없는 시스템
/// (EffectExpireSystem/WeatherSystem, 각각 T-45 이전 스코프 밖)만 뺀,
/// 지금까지 구현된 전부를 쓰는 실전 배틀 조합.
///
/// `EventFlushSystem`(§3 #16)은 넣지 않는다 — 이 프로젝트에서 이벤트를
/// 비우는 주체는 "그 틱 안에서 자동으로"가 아니라 "그걸 소비하는
/// 쪽"(렌더 레이어의 `BattleWorld.drainEvents()`, 05_FRONTEND.md §4.2)이라,
/// 매 틱 자동으로 비우는 시스템을 두면 같은 틱 안에서 시스템→시스템으로
/// 동기 실행되는 구조상 `step()`이 끝나기도 전에 비워져 버려 외부에서
/// 절대로 이벤트를 관찰할 수 없게 된다.
List<BattleSystem> canonicalBattleSystems() => [
  InputSystem(),
  ResourceSystem(),
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
