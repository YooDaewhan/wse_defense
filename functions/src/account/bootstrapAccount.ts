import { CallableRequest, onCall } from 'firebase-functions/v2/https';
import { admin, db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { STARTER_CHARACTER_IDS } from '../common/starterCharacters';
import { bumpMissionProgress } from '../mission/missionProgress';

export interface BootstrapAccountReq {
  appVersion: string;
  dataVersion: string;
}

const FORMATION_PRESET_COUNT = 3;
const FORMATION_SLOT_COUNT = 10;

function emptyFormationSlots() {
  return Array.from({ length: FORMATION_SLOT_COUNT }, () => ({
    characterId: null,
    equipmentInstanceId: null,
  }));
}

/** 06_BACKEND.md §6.1: users/{uid} 최초 생성 + 스타터 5종 + 편성 프리셋 3개.
 * 이미 계정 문서가 있으면 새로 만들지 않고 lastLoginAt만 갱신한다 --
 * 이 호출을 세션 시작("접속") 신호로 삼아 T-54 MSN_LOGIN 미션 진행도를
 * 올린다(07_DUNGEON_EXCHANGE.md §9). */
export async function bootstrapAccountHandler(request: CallableRequest<BootstrapAccountReq>) {
  const uid = requireAuth(request);
  const userRef = db.doc(`users/${uid}`);

  const result = await db.runTransaction(async (tx) => {
    const existing = await tx.get(userRef);
    if (existing.exists) {
      tx.update(userRef, { 'profile.lastLoginAt': admin.firestore.FieldValue.serverTimestamp() });
      return { ok: true, data: existing.data() };
    }

    const now = admin.firestore.FieldValue.serverTimestamp();
    const account = {
      profile: {
        nickname: '',
        createdAt: now,
        lastLoginAt: now,
        platform: 'unknown',
        appVersion: request.data.appVersion,
      },
      growth: { bondLevel: 1, focusLevel: 1, campDefenseLevel: 1 },
      currency: { gold: 0, recruitTicket: 0, collectFragment: 0, exchangePoint: 0 },
      progress: { tutorialStep: null, clearedStages: {}, chapterUnlocked: 1, journalUnlocked: [] },
      settings: { bgmVolume: 1, sfxVolume: 1, battleSpeed: 1, locale: 'ko', lowSpecMode: false },
      dataVersionSeen: request.data.dataVersion,
    };
    tx.set(userRef, account);

    for (const characterId of STARTER_CHARACTER_IDS) {
      tx.set(db.doc(`users/${uid}/characters/${characterId}`), {
        obtainedAt: now,
        affinity: 0,
        skinId: null,
        equipmentId: null,
        dupCount: 0,
      });
    }

    for (let presetIndex = 0; presetIndex < FORMATION_PRESET_COUNT; presetIndex++) {
      tx.set(db.doc(`users/${uid}/formations/${presetIndex}`), {
        slots: emptyFormationSlots(),
        updatedAt: now,
      });
    }

    return { ok: true, data: account };
  });

  await bumpMissionProgress(uid, 'LOGIN');
  return result;
}

export const bootstrapAccount = onCall(bootstrapAccountHandler);
