import 'package:freezed_annotation/freezed_annotation.dart';

part 'wave_def.freezed.dart';
part 'wave_def.g.dart';

/// 04_DATA_SCHEMA.md §8 `stages/*.json`의 `waves[]` 항목.
@freezed
abstract class WaveDef with _$WaveDef {
  const factory WaveDef({
    required String enemyId,
    required int startSec,
    required int intervalSec,
    @Default(-1) int count, // -1 == stopSec까지 무한
    required int stopSec,
    required int spawnX,
  }) = _WaveDef;

  factory WaveDef.fromJson(Map<String, Object?> json) =>
      _$WaveDefFromJson(json);
}
