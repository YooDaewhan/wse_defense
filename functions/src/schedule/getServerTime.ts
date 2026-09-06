import { CallableRequest, onCall } from 'firebase-functions/v2/https';

export interface GetServerTimeRes {
  nowMs: number;
}

/** 07_DUNGEON_EXCHANGE.md 구현 체크리스트: "요일 계산은 서버 시각 기준
 * — 클라이언트 로컬 시각으로 요일 보너스를 판단하지 않는다." Firestore
 * 읽기 없이 그냥 서버 시각만 돌려준다(비용 없음) — 인증도 요구하지 않는다,
 * 시각 자체는 민감하지 않다. */
export function getServerTimeHandler(_request: CallableRequest<void>): GetServerTimeRes {
  return { nowMs: Date.now() };
}

export const getServerTime = onCall(getServerTimeHandler);
