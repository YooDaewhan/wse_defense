import '../../battle/constants.dart';
import '../../battle/tag/tag_query.dart';
import '../../battle/world/battle_world.dart';

/// 05_FRONTEND.md §9.2 `TutorialStep.gate` 판정에 필요한 관측 가능한 상태.
/// `everUsedUltimate`/`rewardClaimed`는 `BattleWorld`만으로는 알 수 없는
/// (필살기 재고는 다시 차오르고, 보상 수령은 전투 밖 UI 이벤트라) 별도
/// 플래그 — 호출부(TutorialController를 굴리는 화면)가 관리한다.
class TutorialContext {
  const TutorialContext({required this.world, this.everUsedUltimate = false, this.rewardClaimed = false});

  final BattleWorld world;
  final bool everUsedUltimate;
  final bool rewardClaimed;
}

sealed class TutorialGate {
  const TutorialGate();
  bool isSatisfied(TutorialContext ctx);
}

class PrayerAtLeastGate extends TutorialGate {
  const PrayerAtLeastGate(this.value);
  final int value;
  @override
  bool isSatisfied(TutorialContext ctx) => ctx.world.prayerPower >= value;
}

class SummonedGate extends TutorialGate {
  const SummonedGate(this.characterId);
  final String characterId;
  @override
  bool isSatisfied(TutorialContext ctx) =>
      ctx.world.entities.ordered.any((e) => e.side == Side.ally && e.def.id == characterId);
}

/// "전선이 x 아래로 밀렸다" = 적 기지까지 남은 거리(적 기지 위치 - 가장
/// 앞선 아군 위치)가 [x](논리 단위) 밑으로 줄었다 — 아군이 전진하고
/// 있다는 신호. 아군이 하나도 없으면(아직 소환 전) 남은 거리는 전장
/// 길이 전체다.
class FrontlineBelowGate extends TutorialGate {
  const FrontlineBelowGate(this.x);
  final int x;

  @override
  bool isSatisfied(TutorialContext ctx) {
    final w = ctx.world;
    int? frontAlly;
    for (final e in w.entities.ordered) {
      if (e.side != Side.ally || !e.isAlive) continue;
      if (frontAlly == null || e.x > frontAlly) frontAlly = e.x;
    }
    frontAlly ??= w.allyBase.x;
    final remaining = w.enemyBase.x - frontAlly;
    return remaining <= x * posScale;
  }
}

class UltimateUsedGate extends TutorialGate {
  const UltimateUsedGate();
  @override
  bool isSatisfied(TutorialContext ctx) => ctx.everUsedUltimate;
}

class NestDestroyedGate extends TutorialGate {
  const NestDestroyedGate();
  @override
  bool isSatisfied(TutorialContext ctx) => ctx.world.outcome == BattleOutcome.allyWin;
}

class RewardClaimedGate extends TutorialGate {
  const RewardClaimedGate();
  @override
  bool isSatisfied(TutorialContext ctx) => ctx.rewardClaimed;
}
