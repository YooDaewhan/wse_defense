import { db } from '../common/admin';
import { startBattleHandler } from './startBattle';
import { StartBattleReq } from './types';
import { fakeAuthedRequest, seedOwnedFormation, seedStageMeta, TEST_DATA_VERSION, TEST_STAGE_ID } from './testSupport';

function req(overrides: Partial<StartBattleReq> = {}): StartBattleReq {
  return {
    idempotencyKey: 'unused-for-start',
    appVersion: '1.0.0',
    dataVersion: TEST_DATA_VERSION,
    mode: 'STORY',
    stageId: TEST_STAGE_ID,
    presetIndex: 0,
    ...overrides,
  };
}

test('starts a battle for an owned formation and returns a matching formationSnapshot', async () => {
  await seedStageMeta();
  const uid = 'start-user-1';
  await seedOwnedFormation(uid);

  const res = await startBattleHandler(fakeAuthedRequest(uid, req()));

  expect(res.battleId).toBeTruthy();
  expect(res.formationSnapshot.slots[0].characterId).toBe('CHR_ACORN');
  expect(res.formationSnapshot.slots[1].characterId).toBe('CHR_DROPLET');
  expect(res.expireAtMs).toBeGreaterThan(res.serverTimeMs);

  const battleDoc = await db.doc(`users/${uid}/battles/${res.battleId}`).get();
  expect(battleDoc.data()?.state).toBe('issued');
  expect(battleDoc.data()?.formationHash).toBe(res.formationSnapshot.formationHash);
});

test('rejects a formation containing a character the account does not own', async () => {
  await seedStageMeta();
  const uid = 'start-user-2';
  await db.doc(`users/${uid}`).set({ progress: { clearedStages: {} } }, { merge: true });
  await db.doc(`users/${uid}/characters/CHR_ACORN`).set({ dupCount: 0 });
  const slots = Array.from({ length: 10 }, () => ({ characterId: null as string | null, equipmentInstanceId: null }));
  slots[0] = { characterId: 'CHR_ACORN', equipmentInstanceId: null };
  slots[1] = { characterId: 'CHR_BEAR', equipmentInstanceId: null }; // 미보유
  await db.doc(`users/${uid}/formations/0`).set({ slots, updatedAt: Date.now() });

  await expect(startBattleHandler(fakeAuthedRequest(uid, req()))).rejects.toThrow();
});

test('rejects a duplicated character across slots', async () => {
  await seedStageMeta();
  const uid = 'start-user-3';
  await db.doc(`users/${uid}`).set({ progress: { clearedStages: {} } }, { merge: true });
  await db.doc(`users/${uid}/characters/CHR_ACORN`).set({ dupCount: 0 });
  const slots = Array.from({ length: 10 }, () => ({ characterId: null as string | null, equipmentInstanceId: null }));
  slots[0] = { characterId: 'CHR_ACORN', equipmentInstanceId: null };
  slots[1] = { characterId: 'CHR_ACORN', equipmentInstanceId: null };
  await db.doc(`users/${uid}/formations/0`).set({ slots, updatedAt: Date.now() });

  await expect(startBattleHandler(fakeAuthedRequest(uid, req()))).rejects.toThrow();
});

test('rejects when dataVersion does not match gameData/current', async () => {
  await seedStageMeta();
  await db.doc('gameData/current').set({ dataVersion: TEST_DATA_VERSION, minAppVersion: '1.0.0' });
  const uid = 'start-user-4';
  await seedOwnedFormation(uid);

  await expect(startBattleHandler(fakeAuthedRequest(uid, req({ dataVersion: 'stale-version' })))).rejects.toThrow();
});
