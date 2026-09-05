import '../constants.dart';
import '../entity/battle_entity.dart';
import '../world/battle_world.dart';

/// 03_BATTLE_ENGINE.md §6.2 강제 넉백 트리거. DamageSystem(피해에 실려 오는
/// causesForcedKb)과 PushHandler(T-17, 피해 없이 단독으로 미는 효과)가 같이
/// 쓴다 — 로직을 두 곳에 복제하지 않으려고 여기 하나로 뽑아뒀다.
void triggerForcedKnockback(BattleWorld w, BattleEntity target, int distance) {
  if (target.hp <= 0) return; // 사망 상태면 넉백 없음
  if (target.knockbackTicksLeft > 0) return; // 넉백 중 추가 적중 -> 무시
  if (w.tick < target.forcedKbImmuneUntilTick) return; // 재적용 차단(30틱)

  final actualDistance = target.def.isBoss ? distance ~/ 2 : distance;
  if (actualDistance <= 0) return;

  target.knockbackTicksLeft = naturalKbTicks;
  target.knockbackVelocity =
      -target.facingSign * actualDistance * posScale ~/ naturalKbTicks;
  target.knockbackIsForced = true;
}
