/// 05_FRONTEND.md §5 / 08_ASSET_PRODUCTION.md §2. 클립 1개의 프레임 구성.
/// `attack`만 3분할(windupFrames/recoverFrames, §2.2)을 쓴다 — impact는
/// 그 사이의 정확히 1틱짜리 순간이라 별도 프레임 개수가 필요 없다.
class AnimClipDef {
  const AnimClipDef({
    required this.name,
    required this.frameCount,
    required this.fps,
    this.loop = false,
    this.windupFrames,
    this.recoverFrames,
  });

  final String name;
  final int frameCount;
  final int fps;
  final bool loop;

  /// attack 전용 3분할. 없으면(null) 3분할 없는 일반 클립으로 취급.
  final int? windupFrames;
  final int? recoverFrames;

  bool get isAttackSplit => windupFrames != null && recoverFrames != null;

  /// 비반복 클립 1회 재생 길이(초). loop 클립은 "죽음처럼 끝을 기다리는"
  /// 용도가 없어 호출부가 쓰지 않는다.
  double get durationSec => frameCount / fps;
}
