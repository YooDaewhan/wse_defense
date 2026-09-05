/// 04_DATA_SCHEMA.md §13 story/*.json의 beat 타입. 카메라 무빙(Ken Burns)·
/// 파티클 등 순수 연출 파라미터는 05_FRONTEND.md §9.1에서 "정적 일러 +
/// 카메라 이동 + 파티클"로 구현하라고만 되어 있고 스키마 필드가 없어(아트도
/// 없음, P0~P1) 다루지 않는다 — 필수 재생 순서/스킵/텍스트만 다룬다.
sealed class StoryBeat {
  const StoryBeat();

  factory StoryBeat.fromJson(Map<String, Object?> json) {
    return switch (json['type'] as String) {
      'BG' => BgBeat(key: json['key'] as String),
      'BGM' => BgmBeat(key: json['key'] as String),
      'SFX' => SfxBeat(key: json['key'] as String),
      'LINE' => LineBeat(
        speakerKey: json['speakerKey'] as String?,
        textKey: json['textKey'] as String,
        portraitKey: json['portraitKey'] as String?,
      ),
      'FADE' => FadeBeat(
        to: json['to'] as String,
        durationMs: json['durationMs'] as int? ?? 500,
      ),
      final other => throw FormatException('알 수 없는 beat 타입: $other'),
    };
  }
}

class BgBeat extends StoryBeat {
  const BgBeat({required this.key});
  final String key;
}

class BgmBeat extends StoryBeat {
  const BgmBeat({required this.key});
  final String key;
}

class SfxBeat extends StoryBeat {
  const SfxBeat({required this.key});
  final String key;
}

class LineBeat extends StoryBeat {
  const LineBeat({this.speakerKey, required this.textKey, this.portraitKey});
  final String? speakerKey;
  final String textKey;
  final String? portraitKey;
}

class FadeBeat extends StoryBeat {
  const FadeBeat({required this.to, required this.durationMs});
  final String to; // "BLACK" 등
  final int durationMs;
}
