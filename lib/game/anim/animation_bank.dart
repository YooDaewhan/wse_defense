import 'character_anim_set.dart';

/// 05_FRONTEND.md §4.1 / §11 성능 체크리스트: `SpriteAnimation`은 캐릭터
/// 단위로 1회 로드 후 공유한다.
///
/// 실제 아틀라스/스프라이트 로더는 아직 없다(P0~P1 원칙 — 09_MILESTONES.md:
/// "아트가 없어서 막히는 일이 없어야 한다"). 그래서 이 클래스는 클립 "정의"
/// (프레임 수·fps·3분할 정보)만 등록/조회하고, 실제 이미지는 다루지 않는다.
/// 등록되지 않은 defId는 [of]가 null을 반환하며, 이는 크래시가 아니라
/// "플레이스홀더로 그리라"는 정상적인 신호다.
class AnimationBank {
  final Map<String, CharacterAnimSet> _sets = {};

  void register(String defId, CharacterAnimSet set) => _sets[defId] = set;

  CharacterAnimSet? of(String defId) => _sets[defId];

  /// 테스트 격리용.
  void clear() => _sets.clear();
}
