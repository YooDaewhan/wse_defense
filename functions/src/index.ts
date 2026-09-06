import { setGlobalOptions } from 'firebase-functions/v2';

// 06_BACKEND.md §5: 모든 Callable은 asia-northeast3(서울).
setGlobalOptions({ region: 'asia-northeast3' });

export * from './account/bootstrapAccount';
export * from './battle/startBattle';
export * from './battle/submitBattle';
export * from './battle/saveFormation';
export * from './growth/levelUp';
export * from './inventory/equipItem';
export * from './inventory/enhanceEquipment';
export * from './schedule/getServerTime';
export * from './dungeon/sweepDungeon';
export * from './dungeon/claimDeepForestRewards';
export * from './exchange/exchangeItems';
export * from './gacha/gachaPull';
export * from './gacha/exchangePickup';
export * from './purchase/verifyPurchase';
export * from './purchase/retryUngrantedPurchases';
export * from './mission/claimMission';
export * from './mail/claimMail';
