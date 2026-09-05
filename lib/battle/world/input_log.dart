import 'dart:convert';
import 'dart:typed_data';

import 'battle_input.dart';

/// 03_BATTLE_ENGINE.md §14. 전투 1회의 재생 가능한 전체 기록.
///
/// 리플레이 = `BattleWorld(config, seed)` 새로 만들고 [inputs]를 tick
/// 오름차순으로 다시 enqueue하는 것 — 이 클래스 자체는 순수 데이터라
/// 시뮬레이션 로직을 갖지 않는다.
class InputLog {
  const InputLog({
    required this.seed,
    required this.dataVersion,
    required this.stageId,
    required this.inputs, // tick 오름차순
    required this.formationHash,
  });

  final int seed;
  final String dataVersion;
  final String stageId;
  final List<BattleInput> inputs;
  final String formationHash;

  /// 서버 제출용 압축 인코딩 (varint delta). tick은 오름차순이 전제라
  /// 항상 음이 아닌 델타만 나온다 — seed만 zigzag(음수 가능)를 쓴다.
  Uint8List encode() {
    final b = BytesBuilder();
    _writeVarint(b, _zigzag(seed));
    _writeString(b, dataVersion);
    _writeString(b, stageId);
    _writeString(b, formationHash);
    _writeVarint(b, inputs.length);

    var prevTick = 0;
    for (final input in inputs) {
      _writeVarint(b, input.tick - prevTick);
      prevTick = input.tick;
      switch (input) {
        case SummonInput(:final slotIndex):
          b.addByte(0);
          _writeVarint(b, slotIndex);
        case UltimateInput():
          b.addByte(1);
        case FocusBoostInput(:final stage):
          b.addByte(2);
          _writeVarint(b, stage);
        case PageSwitchInput(:final page):
          b.addByte(3);
          _writeVarint(b, page);
      }
    }
    return b.toBytes();
  }

  /// [encode]의 역.
  static InputLog decode(Uint8List bytes) {
    final r = _ByteReader(bytes);
    final seed = _unzigzag(r.readVarint());
    final dataVersion = r.readString();
    final stageId = r.readString();
    final formationHash = r.readString();
    final count = r.readVarint();

    var tick = 0;
    final inputs = <BattleInput>[];
    for (var i = 0; i < count; i++) {
      tick += r.readVarint();
      final type = r.readByte();
      inputs.add(
        switch (type) {
          0 => SummonInput(tick, r.readVarint()),
          1 => UltimateInput(tick),
          2 => FocusBoostInput(tick, r.readVarint()),
          3 => PageSwitchInput(tick, r.readVarint()),
          _ => throw FormatException('알 수 없는 BattleInput 타입: $type'),
        },
      );
    }
    return InputLog(
      seed: seed,
      dataVersion: dataVersion,
      stageId: stageId,
      inputs: inputs,
      formationHash: formationHash,
    );
  }
}

int _zigzag(int v) => v >= 0 ? v * 2 : -v * 2 - 1;
int _unzigzag(int v) => v.isEven ? v ~/ 2 : -(v + 1) ~/ 2;

void _writeVarint(BytesBuilder b, int value) {
  var v = value;
  while (true) {
    final byte = v & 0x7f;
    v >>= 7;
    if (v == 0) {
      b.addByte(byte);
      return;
    }
    b.addByte(byte | 0x80);
  }
}

void _writeString(BytesBuilder b, String s) {
  final bytes = utf8.encode(s);
  _writeVarint(b, bytes.length);
  b.add(bytes);
}

class _ByteReader {
  _ByteReader(this._bytes);
  final Uint8List _bytes;
  int _pos = 0;

  int readByte() => _bytes[_pos++];

  int readVarint() {
    var result = 0;
    var shift = 0;
    while (true) {
      final byte = _bytes[_pos++];
      result |= (byte & 0x7f) << shift;
      if (byte & 0x80 == 0) return result;
      shift += 7;
    }
  }

  String readString() {
    final len = readVarint();
    final s = utf8.decode(_bytes.sublist(_pos, _pos + len));
    _pos += len;
    return s;
  }
}
