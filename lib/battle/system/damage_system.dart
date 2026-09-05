import '../constants.dart';
import '../entity/battle_entity.dart';
import '../event/battle_event.dart';
import '../skill/skill_trigger_runner.dart';
import '../stat/stat_key.dart';
import '../world/battle_world.dart';
import 'battle_system.dart';
import 'knockback_trigger.dart';
import 'pending_damage.dart';

/// 03_BATTLE_ENGINE.md §6.1: K = hpSegments. 자연 넉백은 최대 K-1회.
/// 임계값은 maxHp * i / K (i = K-1 .. 1). alreadyConsumed는 회복으로 hp가
/// 올라가도 되돌리지 않는다 — 반복 무적/재넉백 방지.
int thresholdsCrossed(int maxHp, int k, int newHp, int alreadyConsumed) {
  var crossed = 0;
  for (var i = k - 1; i >= 1; i--) {
    final th = maxHp * i ~/ k;
    if (newHp <= th) crossed++;
  }
  var net = crossed - alreadyConsumed;
  if (net < 0) net = 0;
  final maxNet = k - 1 - alreadyConsumed;
  if (net > maxNet) net = maxNet;
  return net;
}

/// 03_BATTLE_ENGINE.md §7 피해 계산식.
///
/// 1)/2) 조건부 주는/받는 피해(속성 상성 등)는 TagEffectResolver의 `vs`
/// 조건부 모디파이어(T-15)가 채운다. 아직 없어 0으로 둔다. '뚫기'(pierce)도
/// PIERCE_MARK(T-17, M2)가 생기기 전까진 항상 미적용.
int computeDamage(BattleWorld w, BattleEntity atk, BattleEntity tgt, int baseAtk) {
  var dmg = baseAtk;

  const dealtPct = 0; // T-15: atk.stats의 DMG_DEALT_VS 조건부 모디파이어
  dmg = dmg * (pctScale + dealtPct) ~/ pctScale;

  const takenPct = 0; // T-15: tgt.stats의 DMG_TAKEN_FROM 조건부 모디파이어
  dmg = dmg * (pctScale + takenPct) ~/ pctScale;

  // 3) 대상의 피해 감소(def, 밀리퍼센트). 최대 90% 감소.
  final reduce = tgt.stats.get(StatKey.def).clamp(0, 90000);
  dmg = dmg * (pctScale - reduce) ~/ pctScale;

  // 4) 최소 피해 보장
  return dmg < 1 ? 1 : dmg;
}

/// 03_BATTLE_ENGINE.md §6: 동일 틱 다중 피해를 대상별로 합산한 뒤 확정한다.
/// "먼저 처리된 공격이 무적을 만들어 나중 공격을 지우지 않는다" —
/// 각 PendingDamage를 도착 순서대로 즉시 적용하지 않고, 대상별로 전부 합산한
/// 다음 딱 한 번 hp에 반영하므로 큐에 쌓인 순서와 무관하게 결과가 같다.
class DamageSystem implements BattleSystem {
  @override
  void execute(BattleWorld w) {
    if (w.pendingDamage.isEmpty) return;

    final queue = List<PendingDamage>.from(w.pendingDamage);
    queue.sort((a, b) {
      final byTarget = a.targetId.compareTo(b.targetId);
      return byTarget != 0 ? byTarget : a.sourceId.compareTo(b.sourceId);
    });

    var i = 0;
    while (i < queue.length) {
      final targetId = queue[i].targetId;
      var sum = 0;
      var forced = false;
      var forcedDistance = 0;
      var j = i;
      while (j < queue.length && queue[j].targetId == targetId) {
        final d = queue[j];
        if (d.kind == DamageKind.direct) sum += d.amount;
        if (d.causesForcedKb && !forced) {
          forced = true;
          forcedDistance = d.forcedKbDistance;
        }
        j++;
      }
      i = j;

      final target = w.entities.byId(targetId);
      if (target == null) continue;

      var remaining = sum;
      if (target.shieldHp > 0) {
        final absorbed = target.shieldHp < remaining ? target.shieldHp : remaining;
        target.shieldHp -= absorbed;
        remaining -= absorbed;
      }
      final hpBefore = target.hp;
      target.hp -= remaining;
      if (remaining > 0) {
        w.events.add(DamageDealtEvent(w.tick, targetId, remaining));
      }
      SkillTriggerRunner.onHpChanged(w, target, hpBefore, target.hp);

      if (target.hp <= 0) continue; // 사망이 넉백보다 우선 (§6 4단계)
      _triggerKnockbackIfNeeded(w, target, forced, forcedDistance);
    }

    w.pendingDamage.clear();
  }

  /// §6 5~6단계: HP 임계 통과 검사, 강제 넉백 적용 여부 판정 (§6.1~6.2).
  void _triggerKnockbackIfNeeded(
    BattleWorld w,
    BattleEntity target,
    bool forced,
    int forcedDistance,
  ) {
    if (forced) {
      triggerForcedKnockback(w, target, forcedDistance);
      return;
    }

    final k = target.stats.get(StatKey.hpSegments);
    if (k <= 1) return; // 구간이 사망뿐이면 자연 넉백 없음
    final maxHp = target.stats.get(StatKey.maxHp);
    final crossed = thresholdsCrossed(
      maxHp,
      k,
      target.hp,
      target.consumedHpThresholds,
    );
    if (crossed <= 0) return;

    target.consumedHpThresholds += crossed; // 여러 임계를 넘어도 소비는 전부, 애니메이션은 1회
    if (target.knockbackTicksLeft > 0) return; // 넉백 중 추가 임계 통과 -> 무시
    _startKnockback(target, naturalKbDistance, isForced: false);
  }

  void _startKnockback(BattleEntity target, int distance, {required bool isForced}) {
    if (distance <= 0) return;
    target.knockbackTicksLeft = naturalKbTicks;
    target.knockbackVelocity =
        -target.facingSign * distance * posScale ~/ naturalKbTicks;
    target.knockbackIsForced = isForced;
    // action 전환은 KnockbackSystem(다음 실행 순서)이 담당한다.
  }
}
