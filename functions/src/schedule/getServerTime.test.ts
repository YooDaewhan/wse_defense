import { getServerTimeHandler } from './getServerTime';

test('returns the current server time in milliseconds', () => {
  const before = Date.now();
  const res = getServerTimeHandler({} as never);
  const after = Date.now();

  expect(res.nowMs).toBeGreaterThanOrEqual(before);
  expect(res.nowMs).toBeLessThanOrEqual(after);
});
