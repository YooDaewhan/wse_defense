/**
 * lib/battle/world/input_log.dart 의 varint-delta 인코딩을 그대로 포팅한 것.
 * V11(inputLog 디코딩 성공, tick 단조 증가) 검증과 V7/V9/V10이 로그 내용을
 * 들여다볼 수 있어야 해서 서버에도 같은 디코더가 필요하다.
 */
export type BattleInput =
  | { type: 'SUMMON'; tick: number; slotIndex: number }
  | { type: 'ULTIMATE'; tick: number }
  | { type: 'FOCUS_BOOST'; tick: number; stage: number }
  | { type: 'PAGE_SWITCH'; tick: number; page: number };

export interface DecodedInputLog {
  seed: number;
  dataVersion: string;
  stageId: string;
  formationHash: string;
  inputs: BattleInput[];
}

function zigzag(v: number): number {
  return v >= 0 ? v * 2 : -v * 2 - 1;
}

function unzigzag(v: number): number {
  return v % 2 === 0 ? v / 2 : -(v + 1) / 2;
}

function writeVarint(bytes: number[], value: number): void {
  let v = value;
  while (true) {
    const byte = v & 0x7f;
    v = Math.floor(v / 128);
    if (v === 0) {
      bytes.push(byte);
      return;
    }
    bytes.push(byte | 0x80);
  }
}

function writeString(bytes: number[], s: string): void {
  const buf = Buffer.from(s, 'utf8');
  writeVarint(bytes, buf.length);
  for (const b of buf) bytes.push(b);
}

export function encodeInputLog(log: DecodedInputLog): Buffer {
  const bytes: number[] = [];
  writeVarint(bytes, zigzag(log.seed));
  writeString(bytes, log.dataVersion);
  writeString(bytes, log.stageId);
  writeString(bytes, log.formationHash);
  writeVarint(bytes, log.inputs.length);

  let prevTick = 0;
  for (const input of log.inputs) {
    writeVarint(bytes, input.tick - prevTick);
    prevTick = input.tick;
    switch (input.type) {
      case 'SUMMON':
        bytes.push(0);
        writeVarint(bytes, input.slotIndex);
        break;
      case 'ULTIMATE':
        bytes.push(1);
        break;
      case 'FOCUS_BOOST':
        bytes.push(2);
        writeVarint(bytes, input.stage);
        break;
      case 'PAGE_SWITCH':
        bytes.push(3);
        writeVarint(bytes, input.page);
        break;
    }
  }
  return Buffer.from(bytes);
}

class ByteReader {
  private pos = 0;
  constructor(private readonly bytes: Buffer) {}

  readByte(): number {
    if (this.pos >= this.bytes.length) throw new Error('inputLog: unexpected end of buffer');
    return this.bytes[this.pos++];
  }

  readVarint(): number {
    // 32비트 시프트(<<)는 2^31을 넘는 값(예: zigzag된 32bit seed)에서 부호
    // 비트로 깨지므로, 시프트 대신 배수 누적으로 안전 정수 범위까지 다룬다.
    let result = 0;
    let shift = 0;
    while (true) {
      const byte = this.readByte();
      result += (byte & 0x7f) * 2 ** shift;
      if ((byte & 0x80) === 0) return result;
      shift += 7;
    }
  }

  readString(): string {
    const len = this.readVarint();
    if (this.pos + len > this.bytes.length) throw new Error('inputLog: string length out of range');
    const s = this.bytes.subarray(this.pos, this.pos + len).toString('utf8');
    this.pos += len;
    return s;
  }

  get remaining(): number {
    return this.bytes.length - this.pos;
  }
}

/** V11: 디코딩 실패, tick 역행, endTick 초과는 전부 예외로 던진다. */
export function decodeInputLog(base64: string, endTick: number): DecodedInputLog {
  const buf = Buffer.from(base64, 'base64');
  const r = new ByteReader(buf);
  const seed = unzigzag(r.readVarint());
  const dataVersion = r.readString();
  const stageId = r.readString();
  const formationHash = r.readString();
  const count = r.readVarint();

  let tick = 0;
  const inputs: BattleInput[] = [];
  for (let i = 0; i < count; i++) {
    const delta = r.readVarint();
    if (delta < 0) throw new Error('inputLog: negative tick delta');
    tick += delta;
    if (tick > endTick) throw new Error(`inputLog: tick ${tick} exceeds endTick ${endTick}`);
    const type = r.readByte();
    switch (type) {
      case 0:
        inputs.push({ type: 'SUMMON', tick, slotIndex: r.readVarint() });
        break;
      case 1:
        inputs.push({ type: 'ULTIMATE', tick });
        break;
      case 2:
        inputs.push({ type: 'FOCUS_BOOST', tick, stage: r.readVarint() });
        break;
      case 3:
        inputs.push({ type: 'PAGE_SWITCH', tick, page: r.readVarint() });
        break;
      default:
        throw new Error(`inputLog: unknown BattleInput type ${type}`);
    }
  }
  if (r.remaining !== 0) throw new Error('inputLog: trailing bytes after decoding');

  return { seed, dataVersion, stageId, formationHash, inputs };
}
