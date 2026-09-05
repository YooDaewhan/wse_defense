import 'anim_clip_def.dart';

/// 08_ASSET_PRODUCTION.md §2.1: 캐릭터 1명이 갖는 클립 7종(필수) + 선택 클립.
class CharacterAnimSet {
  const CharacterAnimSet(this.clips);

  final Map<String, AnimClipDef> clips;

  /// 없는 클립이면 null — 호출부가 대체 클립/플레이스홀더로 폴백한다
  /// (08_ASSET_PRODUCTION.md §2.3, 크래시 금지).
  AnimClipDef? clip(String name) => clips[name];
}
