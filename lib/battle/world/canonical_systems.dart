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
/// (EffectExpireSystem/WeatherSystem/EventFlushSystem, 각각 T-45 이전
/// 스코프 밖)만 뺀, 지금까지 구현된 전부를 쓰는 실전 배틀 조합.
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
