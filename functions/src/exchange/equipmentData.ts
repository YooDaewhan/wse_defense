/**
 * assets/data/v1/equipments.json 서버 사본(강화 비용 계산에 필요한
 * 필드만) — starterCharacters.ts와 같은 이유의 임시 상수.
 */
export interface EquipmentMeta {
  id: string;
  shardFamily: string;
}

export const EQUIPMENT_BY_ID: Record<string, EquipmentMeta> = {
  EQP_ANIMAL_MASK: { id: 'EQP_ANIMAL_MASK', shardFamily: 'SUN' },
  EQP_LEAF_CLOAK: { id: 'EQP_LEAF_CLOAK', shardFamily: 'FIELD' },
  EQP_EMBER_CHARM: { id: 'EQP_EMBER_CHARM', shardFamily: 'SUN' },
  EQP_DEWDROP_BELL: { id: 'EQP_DEWDROP_BELL', shardFamily: 'MOON' },
  EQP_BRAVE_BADGE: { id: 'EQP_BRAVE_BADGE', shardFamily: 'SUN' },
  EQP_HIDING_HOOD: { id: 'EQP_HIDING_HOOD', shardFamily: 'MOON' },
  EQP_ACORN_SHIELD: { id: 'EQP_ACORN_SHIELD', shardFamily: 'FIELD' },
  EQP_SHARP_TWIG: { id: 'EQP_SHARP_TWIG', shardFamily: 'FIELD' },
  EQP_SWIFT_BOOTS: { id: 'EQP_SWIFT_BOOTS', shardFamily: 'SUN' },
  EQP_HEAVY_ANCHOR: { id: 'EQP_HEAVY_ANCHOR', shardFamily: 'FIELD' },
  EQP_LONG_SCOPE: { id: 'EQP_LONG_SCOPE', shardFamily: 'MOON' },
  EQP_QUICK_HANDS: { id: 'EQP_QUICK_HANDS', shardFamily: 'SUN' },
  EQP_WARM_BLANKET: { id: 'EQP_WARM_BLANKET', shardFamily: 'MOON' },
  EQP_SLEEP_CHARM: { id: 'EQP_SLEEP_CHARM', shardFamily: 'MOON' },
  EQP_STONE_SKIN: { id: 'EQP_STONE_SKIN', shardFamily: 'FIELD' },
  EQP_CHEAP_WHISTLE: { id: 'EQP_CHEAP_WHISTLE', shardFamily: 'SUN' },
  EQP_LUCKY_CLOVER: { id: 'EQP_LUCKY_CLOVER', shardFamily: 'FIELD' },
  EQP_ECHO_DRUM: { id: 'EQP_ECHO_DRUM', shardFamily: 'SUN' },
};
