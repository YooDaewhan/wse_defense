import { CallableRequest, onCall } from 'firebase-functions/v2/https';
import { admin, db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { STARTER_CHARACTER_IDS } from '../common/starterCharacters';

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
 * 멱등: 이미 계정 문서가 있으면 그 상태를 그대로 반환하고 아무것도 쓰지 않는다. */
export async function bootstrapAccountHandler(request: CallableRequest<BootstrapAccountReq>) {
  const uid = requireAuth(request);
  const userRef = db.doc(`users/${uid}`);

  return db.runTransaction(async (tx) => {
    const existing = await tx.get(userRef);
    if (existing.exists) {
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
}

export const bootstrapAccount = onCall(bootstrapAccountHandler);
