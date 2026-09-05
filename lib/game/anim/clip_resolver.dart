import '../../battle/entity/battle_entity.dart';
import '../../battle/entity/entity_state.dart';
import '../../battle/stat/stat_key.dart';
import 'character_anim_set.dart';

/// 05_FRONTEND.md §5.2 클립 매핑 결과. `frameIndex`는 해당 클립 안에서
/// 몇 번째 프레임인지(3분할 attack 한정 의미 있음) — 다른 클립은 항상 0이고
/// 재생 자체는(반복 여부 등) 렌더 레이어가 `AnimClipDef`로 알아서 돌린다.
class ResolvedFrame {
  const ResolvedFrame({
    required this.clipName,
    this.frameIndex = 0,
    this.isImpact = false,
  });

  final String clipName;
  final int frameIndex;

  /// true인 틱은 정확히 판정이 일어난 그 틱 — 08_ASSET_PRODUCTION.md §2.2의
  /// impact 프레임을 이 틱 동안 보여줘야 한다는 뜻.
  final bool isImpact;
}

/// 갓 스폰된 뒤 `spawn` 클립을 보여줄 창(틱). 문서에 정확한 프레임 수가
/// 없어 08_ASSET_PRODUCTION.md §2.1의 `spawn`(5프레임/15fps ≈ 0.33초)에
/// 맞춰 30Hz 기준 10틱으로 잡는다.
const int spawnWindowTicks = 10;

/// 05_FRONTEND.md §5.2 상태 -> 클립 매핑 + §5.1 attack 3분할.
///
/// Flame/렌더 의존이 없는 순수 함수라 `BattleEntity` 픽스처만으로 완전히
/// 테스트할 수 있다. `animSet`이 null(아틀라스 없음)이어도 절대 던지지
/// 않고 항상 안전한 클립 이름을 돌려준다 — 실제 그림이 있는지는 호출부
/// (UnitComponent)가 다시 확인해 플레이스홀더로 폴백한다.
ResolvedFrame resolveClip(BattleEntity e, CharacterAnimSet? animSet, int currentTick) {
  // 최상위(중단 불가): 사망 > 스폰.
  if (e.action == EntityAction.dead) return const ResolvedFrame(clipName: 'death');
  if (currentTick - e.spawnTick < spawnWindowTicks) {
    return const ResolvedFrame(clipName: 'spawn');
  }

  // 높음.
  if (e.isKnockedBack) return const ResolvedFrame(clipName: 'knockback');
  if (e.action == EntityAction.stunned) return const ResolvedFrame(clipName: 'stun');

  // 중간: 공격(3분할).
  if (e.action == EntityAction.attackWindup || e.action == EntityAction.attackRecover) {
    return _resolveAttack(e, animSet);
  }

  // 낮음/최하.
  if (e.action == EntityAction.moving) return const ResolvedFrame(clipName: 'move');
  return const ResolvedFrame(clipName: 'idle');
}

ResolvedFrame _resolveAttack(BattleEntity e, CharacterAnimSet? animSet) {
  final clip = animSet?.clip('attack');
  if (clip == null || !clip.isAttackSplit) {
    return const ResolvedFrame(clipName: 'attack'); // 3분할 정보 없음 -> 통짜 재생
  }

  final windupTicks = e.stats.get(StatKey.attackWindup); // A
  final periodTicks = e.stats.get(StatKey.attackPeriod); // P
  final recoverTicks = periodTicks - windupTicks; // R — attackCooldown(가변)이 아니라 스탯에서 직접 계산

  if (e.action == EntityAction.attackWindup) {
    // actionTimer는 A에서 1까지만 관측된다(0이 되는 틱에 곧바로 판정+전환).
    final elapsed = windupTicks - e.actionTimer; // 0..A-1
    final idx = windupTicks <= 0
        ? 0
        : (elapsed * clip.windupFrames! ~/ windupTicks).clamp(0, clip.windupFrames! - 1);
    return ResolvedFrame(clipName: 'attack', frameIndex: idx);
  }

  // attackRecover: 진입 직후(actionTimer == recoverTicks, elapsed == 0)가 곧 판정 순간.
  final elapsed = recoverTicks - e.actionTimer;
  if (elapsed <= 0) {
    return const ResolvedFrame(clipName: 'attack', isImpact: true);
  }
  final idx = recoverTicks <= 1
      ? 0
      : ((elapsed - 1) * clip.recoverFrames! ~/ recoverTicks).clamp(0, clip.recoverFrames! - 1);
  return ResolvedFrame(clipName: 'attack', frameIndex: idx);
}
