import '../constants.dart';
import '../entity/battle_entity.dart';
import '../stat/stat_key.dart';
import '../world/battle_world.dart';
import 'battle_system.dart';
import 'pending_damage.dart';

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
      var j = i;
      while (j < queue.length && queue[j].targetId == targetId) {
        if (queue[j].kind == DamageKind.direct) sum += queue[j].amount;
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
      target.hp -= remaining;
      // HP 임계 통과 검사·강제 넉백 판정(§6.1~6.2)은 T-11 KnockbackSystem의 몫.
    }

    w.pendingDamage.clear();
  }
}
