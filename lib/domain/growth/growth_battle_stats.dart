import 'growth_config.dart';

/// 10_WIRING_PLAN.md T-60: 계정의 집중력/캠프 레벨로 전투에 쓸 실제 수치
/// (기도력 회복·상한·시작량, 모닥불 체력)를 고른다.
///
/// ponytail: growth.json의 keyframe은 몇 개 레벨에만 값이 있고(예: Lv1,
/// Lv10) 그 사이는 정의돼 있지 않다 -- 매끄러운 보간(곡선) 대신, 그 레벨
/// 이하에서 가장 가까운 keyframe 값을 그대로 쓰는 계단 함수로 근사한다.
/// 레벨 사이 체감이 문제가 되면 그때 keyframe 사이 linear interpolation
/// 으로 바꾼다.
FocusKeyframe focusStatsForLevel(GrowthConfig config, int level) =>
    _nearestAtOrBelow(config.focusKeyframes, level, (k) => k.level);

CampKeyframe campStatsForLevel(GrowthConfig config, int level) =>
    _nearestAtOrBelow(config.campKeyframes, level, (k) => k.level);

T _nearestAtOrBelow<T>(List<T> keyframes, int level, int Function(T) levelOf) {
  T? best;
  for (final k in keyframes) {
    if (levelOf(k) <= level && (best == null || levelOf(k) > levelOf(best))) best = k;
  }
  return best ?? keyframes.first;
}
