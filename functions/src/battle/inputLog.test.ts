import { decodeInputLog, encodeInputLog } from './inputLog';

test('round-trips through encode/decode', () => {
  const log = {
    seed: -12345,
    dataVersion: '1.0.7',
    stageId: 'STG_1_1',
    formationHash: 'abc123',
    inputs: [
      { type: 'SUMMON' as const, tick: 0, slotIndex: 0 },
      { type: 'SUMMON' as const, tick: 120, slotIndex: 1 },
      { type: 'ULTIMATE' as const, tick: 900 },
      { type: 'FOCUS_BOOST' as const, tick: 1000, stage: 2 },
      { type: 'PAGE_SWITCH' as const, tick: 1500, page: 1 },
    ],
  };
  const encoded = encodeInputLog(log).toString('base64');
  expect(decodeInputLog(encoded, 2000)).toEqual(log);
});

/**
 * lib/battle/world/input_log.dart의 실제 `InputLog.encode()` 출력(같은
 * seed/필드/입력들로 생성)을 하드코딩한 값 — Dart 클라이언트가 실제로
 * 만드는 바이트를 이 TS 디코더가 그대로 읽을 수 있는지(포맷 호환) 증명한다.
 */
test('decodes a real fixture produced by the Dart client encoder', () => {
  const dartEncodedBase64 = '8cABBTEuMC43B1NUR18xXzEGYWJjMTIzBQAAAHgAAYwGAWQCAvQDAwE=';
  const decoded = decodeInputLog(dartEncodedBase64, 2000);
  expect(decoded).toEqual({
    seed: -12345,
    dataVersion: '1.0.7',
    stageId: 'STG_1_1',
    formationHash: 'abc123',
    inputs: [
      { type: 'SUMMON', tick: 0, slotIndex: 0 },
      { type: 'SUMMON', tick: 120, slotIndex: 1 },
      { type: 'ULTIMATE', tick: 900 },
      { type: 'FOCUS_BOOST', tick: 1000, stage: 2 },
      { type: 'PAGE_SWITCH', tick: 1500, page: 1 },
    ],
  });
});

test('V11: rejects a tick beyond endTick', () => {
  const encoded = encodeInputLog({
    seed: 1,
    dataVersion: '1.0.7',
    stageId: 'STG_1_1',
    formationHash: 'h',
    inputs: [{ type: 'ULTIMATE', tick: 5000 }],
  }).toString('base64');
  expect(() => decodeInputLog(encoded, 4000)).toThrow();
});

test('V11: rejects truncated/corrupt bytes', () => {
  const corrupt = Buffer.from([0xff, 0xff]).toString('base64');
  expect(() => decodeInputLog(corrupt, 4000)).toThrow();
});
