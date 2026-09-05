import '../world/battle_world.dart';

/// 03_BATTLE_ENGINE.md §3: 한 틱에 정확히 1회씩, `BattleWorld.systems` 순서
/// 그대로 실행된다. 순서 변경 금지 — 결정론의 근거.
abstract class BattleSystem {
  void execute(BattleWorld world);
}
