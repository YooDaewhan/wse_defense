import { CallableRequest, HttpsError } from 'firebase-functions/v2/https';

/** 인증되지 않은 호출은 즉시 거부한다 — 06_BACKEND.md §1 원칙 1. */
export function requireAuth(request: CallableRequest<unknown>): string {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'AUTH_REQUIRED');
  return uid;
}
