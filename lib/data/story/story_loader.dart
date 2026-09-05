import 'dart:convert';

import '../../domain/story/story_beat.dart';
import '../datapack/datapack_loader.dart' show AssetReader;

/// `story/prologue.json` 같은 "beats 배열 하나짜리" 스토리 파일을 읽는다.
/// 04_DATA_SCHEMA.md §13의 일반 `scenes[]` 포맷과 달리, 05_FRONTEND.md
/// §9.1은 프롤로그를 "`beats`를 순차 재생"이라고만 해 별도 scene 래핑 없이
/// 최상위에 `beats` 배열을 두는 더 단순한 형태로 둔다.
Future<List<StoryBeat>> loadStoryBeats(AssetReader readJson, String relativePath) async {
  final raw = jsonDecode(await readJson(relativePath)) as Map<String, Object?>;
  return [
    for (final b in raw['beats'] as List<Object?>) StoryBeat.fromJson(b as Map<String, Object?>),
  ];
}
