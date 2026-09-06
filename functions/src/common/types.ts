/** 06_BACKEND.md §4.1 공통 요청/응답. */
export interface BaseRequest {
  idempotencyKey: string;
  appVersion: string;
  dataVersion: string;
}

export interface BaseResponse<T> {
  ok: boolean;
  code?: ErrorCode;
  data?: T;
  /** 변경된 계정 상태 델타. 클라이언트가 이걸로 로컬 미러를 갱신 */
  patch?: AccountPatch;
}

export type ErrorCode =
  | 'AUTH_REQUIRED'
  | 'APP_VERSION_TOO_OLD'
  | 'DATA_VERSION_MISMATCH'
  | 'NOT_ENOUGH_CURRENCY'
  | 'NOT_OWNED'
  | 'ALREADY_APPLIED'
  | 'BATTLE_NOT_FOUND'
  | 'BATTLE_EXPIRED'
  | 'BATTLE_ALREADY_SUBMITTED'
  | 'VALIDATION_FAILED'
  | 'DAILY_LIMIT_REACHED'
  | 'BANNER_CLOSED'
  | 'RATE_LIMITED'
  | 'MAINTENANCE'
  | 'INTERNAL';

export interface AccountPatch {
  currency?: Partial<{ gold: number; recruitTicket: number; collectFragment: number; exchangePoint: number }>;
  growth?: Partial<{ bondLevel: number; focusLevel: number; campDefenseLevel: number }>;
  progress?: Record<string, unknown>;
}

export interface Delta {
  item: string;
  amount: number;
}
