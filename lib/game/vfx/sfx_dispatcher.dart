/// 05_FRONTEND.md §11: "동일 프레임 같은 SFX는 1회만 재생".
///
/// 실제 오디오 백엔드(flame_audio 등)는 붙이지 않았다 — 사운드 에셋이
/// 아직 없다(P0~P1 무아트/무사운드 원칙). 이 클래스는 "이번 프레임에
/// 실제로 재생해야 할 고유 사운드 id 집합"만 계산해 [play]에 넘긴다.
class SfxDispatcher {
  SfxDispatcher({required this.play});

  final void Function(String soundId) play;

  final Set<String> _playedThisFrame = {};

  /// 프레임 시작 시 호출 — 그 프레임의 중복 방지 집합을 비운다.
  void beginFrame() => _playedThisFrame.clear();

  /// 같은 프레임 안에서 여러 번 불려도 soundId당 [play]는 딱 한 번만 실행된다.
  void request(String soundId) {
    if (_playedThisFrame.add(soundId)) {
      play(soundId);
    }
  }
}
