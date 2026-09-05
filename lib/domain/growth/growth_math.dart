import 'growth_config.dart';

/// 04_DATA_SCHEMA.md §9 "보간 구현" — 문서에 나온 그대로.
int lerpInt(int l0, int v0, int l1, int v1, int level) {
  if (level <= l0) return v0;
  if (level >= l1) return v1;
  return v0 + (v1 - v0) * (level - l0) ~/ (l1 - l0);
}

/// keyframe이 3개 이상이어도(1, 10, 20처럼) [level]을 감싸는 구간 하나만
/// 골라 그 구간 안에서만 선형보간한다 — 구간 밖은 양 끝 값으로 clamp.
int _interpolate(List<(int level, int value)> points, int level) {
  if (level <= points.first.$1) return points.first.$2;
  if (level >= points.last.$1) return points.last.$2;
  for (var i = 0; i < points.length - 1; i++) {
    final a = points[i];
    final b = points[i + 1];
    if (level >= a.$1 && level <= b.$1) {
      return lerpInt(a.$1, a.$2, b.$1, b.$2, level);
    }
  }
  return points.last.$2; // 도달 불가(정렬된 keyframe 전제) — 방어적 기본값
}

class FocusStats {
  const FocusStats({required this.regenPerSec, required this.cap, required this.startAmount});
  final int regenPerSec;
  final int cap;
  final int startAmount;
}

FocusStats focusStatsAtLevel(List<FocusKeyframe> keyframes, int level) => FocusStats(
  regenPerSec: _interpolate([for (final k in keyframes) (k.level, k.regenPerSec)], level),
  cap: _interpolate([for (final k in keyframes) (k.level, k.cap)], level),
  startAmount: _interpolate([for (final k in keyframes) (k.level, k.startAmount)], level),
);

int campHpAtLevel(List<CampKeyframe> keyframes, int level) =>
    _interpolate([for (final k in keyframes) (k.level, k.hp)], level);
