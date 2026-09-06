import { createHash, randomInt } from 'crypto';
import { CallableRequest, HttpsError, onCall } from 'firebase-functions/v2/https';
import { db } from '../common/admin';
import { requireAuth } from '../common/auth';
import { DAILY_RUN_LIMIT } from '../dungeon/dungeonData';
import { gameDateKey } from '../schedule/gameDay';
import { FormationSnapshot, StageMeta, StartBattleReq, StartBattleRes } from './types';

interface RawFormationSlot {
  characterId: string | null;
  equipmentInstanceId: string | null;
}

/** 06_BACKEND.md §4.3 처리 3~4단계: 소유 검증 + 스냅샷 생성.
 * 스탯(성장치·장비 보정)은 T-39 성장 API 이후로 미룬다 — 여기서는
 * 소유권 검증에 필요한 캐릭터/장비 ID만 스냅샷에 담는다(그게 곧 V1
 * formationHash 위·변조 방지의 실제 근거다). */
async function loadFormationSnapshot(uid: string, presetIndex: number): Promise<FormationSnapshot> {
  const formationDoc = await db.doc(`users/${uid}/formations/${presetIndex}`).get();
  if (!formationDoc.exists) throw new HttpsError('failed-precondition', 'VALIDATION_FAILED');

  const slots = (formationDoc.data()?.slots ?? []) as RawFormationSlot[];
  const seenCharacters = new Set<string>();

  for (const slot of slots) {
    if (!slot.characterId) continue;
    if (seenCharacters.has(slot.characterId)) throw new HttpsError('failed-precondition', 'VALIDATION_FAILED');
    seenCharacters.add(slot.characterId);

    const characterDoc = await db.doc(`users/${uid}/characters/${slot.characterId}`).get();
    if (!characterDoc.exists) throw new HttpsError('failed-precondition', 'NOT_OWNED');

    if (slot.equipmentInstanceId) {
      const equipmentDoc = await db.doc(`users/${uid}/equipments/${slot.equipmentInstanceId}`).get();
      if (!equipmentDoc.exists || equipmentDoc.data()?.equippedTo !== slot.characterId) {
        throw new HttpsError('failed-precondition', 'NOT_OWNED');
      }
    }
  }

  const formationHash = createHash('sha256').update(JSON.stringify(slots)).digest('hex');
  return { presetIndex, slots, formationHash };
}

export async function startBattleHandler(request: CallableRequest<StartBattleReq>): Promise<StartBattleRes> {
  const uid = requireAuth(request);
  const { stageId, presetIndex, mode, dataVersion } = request.data;

  const gameDataDoc = await db.doc('gameData/current').get();
  if (gameDataDoc.exists && gameDataDoc.data()?.dataVersion !== dataVersion) {
    throw new HttpsError('failed-precondition', 'DATA_VERSION_MISMATCH');
  }

  const metaDoc = await db.doc(`stagesMeta/${stageId}`).get();
  if (!metaDoc.exists) throw new HttpsError('not-found', 'BATTLE_NOT_FOUND');
  const meta = metaDoc.data() as StageMeta;

  // 06_BACKEND.md §4.3 "DUNGEON: dailyCounters 잔여 횟수(차감은 submit에서)".
  if (mode === 'DUNGEON') {
    const counterDoc = await db.doc(`users/${uid}/dailyCounters/${gameDateKey(new Date())}`).get();
    const totalDungeonRuns = (counterDoc.data()?.totalDungeonRuns as number) ?? 0;
    if (totalDungeonRuns >= DAILY_RUN_LIMIT) {
      throw new HttpsError('resource-exhausted', 'DAILY_LIMIT_REACHED');
    }
  }

  const formationSnapshot = await loadFormationSnapshot(uid, presetIndex);

  const seed = randomInt(2 ** 31);
  const issuedAt = Date.now();
  const expireAt = issuedAt + (meta.timeLimitSec + 600) * 1000;

  const battleRef = db.collection(`users/${uid}/battles`).doc();
  await battleRef.set({
    stageId,
    mode,
    seed,
    dataVersion,
    formationHash: formationSnapshot.formationHash,
    formationSnapshot,
    issuedAt,
    expireAt,
    state: 'issued',
    result: null,
  });

  return {
    battleId: battleRef.id,
    seed,
    dataVersion,
    serverTimeMs: issuedAt,
    expireAtMs: expireAt,
    formationSnapshot,
  };
}

export const startBattle = onCall(startBattleHandler);
