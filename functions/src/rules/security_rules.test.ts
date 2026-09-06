import { readFileSync } from 'fs';
import * as path from 'path';
import {
  RulesTestEnvironment,
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';

/** 09_MILESTONES.md T-36 완료조건: "보안 규칙 테스트: 다른 uid 문서 읽기/쓰기
 * 전부 거부". 06_BACKEND.md §3 firestore.rules 원본을 그대로 로드해서 검증한다. */

let testEnv: RulesTestEnvironment;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-wse-defense',
    firestore: {
      rules: readFileSync(path.resolve(__dirname, '../../../firestore.rules'), 'utf8'),
      host: 'localhost',
      port: 8080,
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

async function seedOwnerDoc() {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await ctx.firestore().doc('users/uidA').set({ profile: { nickname: 'A' } });
    await ctx.firestore().doc('users/uidA/characters/CHR_ACORN').set({ dupCount: 0 });
  });
}

test('a user cannot read another uid\'s account document', async () => {
  await seedOwnerDoc();
  const asB = testEnv.authenticatedContext('uidB').firestore();
  await assertFails(asB.doc('users/uidA').get());
});

test('a user cannot read another uid\'s subcollection document', async () => {
  await seedOwnerDoc();
  const asB = testEnv.authenticatedContext('uidB').firestore();
  await assertFails(asB.doc('users/uidA/characters/CHR_ACORN').get());
});

test('a user cannot write another uid\'s account document', async () => {
  const asB = testEnv.authenticatedContext('uidB').firestore();
  await assertFails(asB.doc('users/uidA').set({ profile: { nickname: 'hacked' } }));
});

test('a user cannot write another uid\'s subcollection document', async () => {
  const asB = testEnv.authenticatedContext('uidB').firestore();
  await assertFails(asB.doc('users/uidA/characters/CHR_ACORN').set({ dupCount: 99 }));
});

test('a signed-out client cannot read or write any uid\'s document', async () => {
  const anon = testEnv.unauthenticatedContext().firestore();
  await assertFails(anon.doc('users/uidA').get());
  await assertFails(anon.doc('users/uidA').set({ profile: {} }));
});

test('a user CAN read their own account document', async () => {
  await seedOwnerDoc();
  const asA = testEnv.authenticatedContext('uidA').firestore();
  await assertSucceeds(asA.doc('users/uidA').get());
});

test('a user cannot create their own account document directly (writes go through Functions)', async () => {
  const asA = testEnv.authenticatedContext('uidA').firestore();
  await assertFails(asA.doc('users/uidA').set({ profile: { nickname: 'self' } }));
});

test('a user CAN update only the settings field on their own document', async () => {
  await seedOwnerDoc();
  const asA = testEnv.authenticatedContext('uidA').firestore();
  await assertSucceeds(asA.doc('users/uidA').update({ settings: { bgmVolume: 0.5 } }));
});

test('a user cannot update non-settings fields on their own document', async () => {
  await seedOwnerDoc();
  const asA = testEnv.authenticatedContext('uidA').firestore();
  await assertFails(asA.doc('users/uidA').update({ 'growth.bondLevel': 99 }));
});

test('formations write is allowed for the owner with exactly 10 slots', async () => {
  const asA = testEnv.authenticatedContext('uidA').firestore();
  const slots = Array.from({ length: 10 }, () => ({ characterId: null, equipmentInstanceId: null }));
  await assertSucceeds(asA.doc('users/uidA/formations/0').set({ slots, updatedAt: 0 }));
});

test('formations write is rejected when slot count is wrong', async () => {
  const asA = testEnv.authenticatedContext('uidA').firestore();
  await assertFails(asA.doc('users/uidA/formations/0').set({ slots: [], updatedAt: 0 }));
});

test('public read-only collections are readable by anyone but not writable by clients', async () => {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await ctx.firestore().doc('stagesMeta/STG_1_1').set({ timeLimitSec: 300 });
  });
  const asA = testEnv.authenticatedContext('uidA').firestore();
  await assertSucceeds(asA.doc('stagesMeta/STG_1_1').get());
  await assertFails(asA.doc('stagesMeta/STG_1_1').set({ timeLimitSec: 1 }));
});
