import '../defs/stage_def.dart';
import '../defs/wave_def.dart';

/// 04_DATA_SCHEMA.md §8 `WaveDef`의 전투 중 런타임 상태. 정적 정의(`def`)는
/// 불변, `spawnedCount`만 변한다.
class WaveRuntimeState {
  WaveRuntimeState(this.def);
  final WaveDef def;
  int spawnedCount = 0;
}

/// 03_BATTLE_ENGINE.md §12.
enum BossTriggerState { pending, warning, spawned }

/// `state`/`warningTicksLeft`가 곧 직렬화 대상(§20) — 다단히트·일격사·
/// 저장복구 전부 이 두 값만으로 "이미 등장했는가"를 판단하므로 중복 스폰이
/// 없다.
class BossTriggerRuntime {
  BossTriggerRuntime(this.def);
  final BossTriggerDef def;
  BossTriggerState state = BossTriggerState.pending;
  int warningTicksLeft = 0;
}
