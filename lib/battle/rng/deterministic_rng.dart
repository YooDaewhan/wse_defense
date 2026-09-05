import '../constants.dart';

/// 용도별 독립 스트림. 새 확률 판정을 추가할 때 여기에만 항목을 추가한다.
enum RngStream { skillProc, critical, targetTie, spawnJitter, lootPreview }

/// xorshift128 (Marsaglia). 32비트 워드만 사용해 dart2js(53bit 정수)에서도
/// VM과 동일한 결과를 낸다. 같은 seed → 항상 같은 수열.
class DeterministicRng {
  DeterministicRng(int seed) : _seed = seed {
    _seedState(seed, 0);
  }

  DeterministicRng._child(int seed, int salt) : _seed = seed {
    _seedState(seed, salt);
  }

  final int _seed;
  late int _x, _y, _z, _w;
  final List<DeterministicRng?> _streams = List<DeterministicRng?>.filled(
    RngStream.values.length,
    null,
  );

  void _seedState(int seed, int salt) {
    _x = _mix32(seed, salt * 4 + 1);
    _y = _mix32(seed, salt * 4 + 2);
    _z = _mix32(seed, salt * 4 + 3);
    _w = _mix32(seed, salt * 4 + 4);
    if (_x == 0 && _y == 0 && _z == 0 && _w == 0) {
      _w = 1; // xorshift 상태는 전부 0이면 안 됨
    }
  }

  static int _mix32(int seed, int salt) {
    int z = (seed ^ (salt * 0x9E3779B1)) & 0xFFFFFFFF;
    z = ((z ^ (z >> 16)) * 0x85EBCA6B) & 0xFFFFFFFF;
    z = ((z ^ (z >> 13)) * 0xC2B2AE35) & 0xFFFFFFFF;
    z = (z ^ (z >> 16)) & 0xFFFFFFFF;
    return z;
  }

  int _nextUint32() {
    int t = (_x ^ ((_x << 11) & 0xFFFFFFFF)) & 0xFFFFFFFF;
    t ^= t >> 8;
    _x = _y;
    _y = _z;
    _z = _w;
    _w = (_w ^ (_w >> 19) ^ t) & 0xFFFFFFFF;
    return _w;
  }

  /// [0, maxExclusive) 균등 정수.
  int nextInt(int maxExclusive) {
    assert(maxExclusive > 0);
    return _nextUint32() % maxExclusive;
  }

  /// p(pctScale 기준 밀리퍼센트)의 확률로 true.
  bool roll(int p) => nextInt(pctScale) < p;

  /// 용도별 독립 스트림. 최초 호출 시 파생 생성 후 캐싱되어, 이후 같은
  /// 스트림에서 이어서 뽑는다. 다른 스트림을 뽑아도 이 스트림 수열은 불변.
  DeterministicRng stream(RngStream s) {
    return _streams[s.index] ??= DeterministicRng._child(_seed, s.index + 1);
  }

  /// 03_BATTLE_ENGINE.md §14 직렬화(T-20)용. 아직 뽑지 않은 스트림은
  /// 내보내지 않는다 — 복원 시 최초 사용 시점에 그대로 다시 지연 생성된다.
  Map<String, Object?> exportState() => {
    'x': _x,
    'y': _y,
    'z': _z,
    'w': _w,
    'streams': {
      for (var i = 0; i < _streams.length; i++)
        if (_streams[i] != null) '$i': _streams[i]!.exportState(),
    },
  };

  /// [exportState]의 역. 같은 seed로 만든 인스턴스에 대해서만 호출한다.
  void restoreState(Map<String, Object?> data) {
    _x = data['x'] as int;
    _y = data['y'] as int;
    _z = data['z'] as int;
    _w = data['w'] as int;
    final streams = data['streams'] as Map<String, Object?>;
    for (final entry in streams.entries) {
      final idx = int.parse(entry.key);
      final child = _streams[idx] ??= DeterministicRng._child(_seed, idx + 1);
      child.restoreState(entry.value as Map<String, Object?>);
    }
  }
}
