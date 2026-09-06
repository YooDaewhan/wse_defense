/**
 * assets/data/v1/exchange.json 서버 사본. 클라이언트 값을 신뢰하지 않고
 * 여기 값으로만 cost/gain/limit/resetPeriod을 확정한다(06_BACKEND.md §4.6).
 * starterCharacters.ts/dungeonData.ts와 같은 이유의 임시 상수 —
 * 이 파일은 assets/data/v1/exchange.json으로부터 스크립트로 생성됐다
 * (손으로 27개 항목을 옮겨적다 생기는 오타를 피하기 위함). 데이터가
 * 바뀌면 다시 생성해야 한다.
 */
export interface CostEntry {
  item: string;
  amount: number;
}

export type GainType = 'ITEM' | 'CURRENCY' | 'EQUIPMENT';

export interface GainDef {
  type: GainType;
  id: string;
  amount: number;
}

export type ResetPeriod = 'NONE' | 'DAILY' | 'WEEKLY' | 'EVENT';

export interface ExchangeEntry {
  id: string;
  cost: CostEntry[];
  gain: GainDef;
  limit: number;
  resetPeriod: ResetPeriod;
}

export interface Shop {
  id: string;
  entries: ExchangeEntry[];
}

export const UPGRADES: ExchangeEntry[] = [
  {
    "id": "UPG_SUN_T1_T2",
    "cost": [
      {
        "item": "ITM_SHARD_SUN_T1",
        "amount": 5
      }
    ],
    "gain": {
      "type": "ITEM",
      "id": "ITM_SHARD_SUN_T2",
      "amount": 1
    },
    "limit": 0,
    "resetPeriod": "NONE"
  },
  {
    "id": "UPG_SUN_T2_T3",
    "cost": [
      {
        "item": "ITM_SHARD_SUN_T2",
        "amount": 5
      }
    ],
    "gain": {
      "type": "ITEM",
      "id": "ITM_SHARD_SUN_T3",
      "amount": 1
    },
    "limit": 0,
    "resetPeriod": "NONE"
  },
  {
    "id": "UPG_MOON_T1_T2",
    "cost": [
      {
        "item": "ITM_SHARD_MOON_T1",
        "amount": 5
      }
    ],
    "gain": {
      "type": "ITEM",
      "id": "ITM_SHARD_MOON_T2",
      "amount": 1
    },
    "limit": 0,
    "resetPeriod": "NONE"
  },
  {
    "id": "UPG_MOON_T2_T3",
    "cost": [
      {
        "item": "ITM_SHARD_MOON_T2",
        "amount": 5
      }
    ],
    "gain": {
      "type": "ITEM",
      "id": "ITM_SHARD_MOON_T3",
      "amount": 1
    },
    "limit": 0,
    "resetPeriod": "NONE"
  },
  {
    "id": "UPG_FIELD_T1_T2",
    "cost": [
      {
        "item": "ITM_SHARD_FIELD_T1",
        "amount": 5
      }
    ],
    "gain": {
      "type": "ITEM",
      "id": "ITM_SHARD_FIELD_T2",
      "amount": 1
    },
    "limit": 0,
    "resetPeriod": "NONE"
  },
  {
    "id": "UPG_FIELD_T2_T3",
    "cost": [
      {
        "item": "ITM_SHARD_FIELD_T2",
        "amount": 5
      }
    ],
    "gain": {
      "type": "ITEM",
      "id": "ITM_SHARD_FIELD_T3",
      "amount": 1
    },
    "limit": 0,
    "resetPeriod": "NONE"
  }
];

export const SHOPS: Shop[] = [
  {
    "id": "SHOP_DUNGEON_SUN",
    "entries": [
      {
        "id": "EX_ANIMAL_MASK",
        "cost": [
          {
            "item": "ITM_SHARD_SUN_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_ANIMAL_MASK",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_EMBER_CHARM",
        "cost": [
          {
            "item": "ITM_SHARD_SUN_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_EMBER_CHARM",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_BRAVE_BADGE",
        "cost": [
          {
            "item": "ITM_SHARD_SUN_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_BRAVE_BADGE",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_SWIFT_BOOTS",
        "cost": [
          {
            "item": "ITM_SHARD_SUN_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_SWIFT_BOOTS",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_QUICK_HANDS",
        "cost": [
          {
            "item": "ITM_SHARD_SUN_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_QUICK_HANDS",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_CHEAP_WHISTLE",
        "cost": [
          {
            "item": "ITM_SHARD_SUN_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_CHEAP_WHISTLE",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_ECHO_DRUM",
        "cost": [
          {
            "item": "ITM_SHARD_SUN_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_ECHO_DRUM",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_SUN_GOLD_POUCH",
        "cost": [
          {
            "item": "ITM_SHARD_SUN_T1",
            "amount": 20
          }
        ],
        "gain": {
          "type": "CURRENCY",
          "id": "ITM_GOLD",
          "amount": 6000
        },
        "limit": 5,
        "resetPeriod": "WEEKLY"
      }
    ]
  },
  {
    "id": "SHOP_DUNGEON_MOON",
    "entries": [
      {
        "id": "EX_DEWDROP_BELL",
        "cost": [
          {
            "item": "ITM_SHARD_MOON_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_DEWDROP_BELL",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_HIDING_HOOD",
        "cost": [
          {
            "item": "ITM_SHARD_MOON_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_HIDING_HOOD",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_LONG_SCOPE",
        "cost": [
          {
            "item": "ITM_SHARD_MOON_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_LONG_SCOPE",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_WARM_BLANKET",
        "cost": [
          {
            "item": "ITM_SHARD_MOON_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_WARM_BLANKET",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_SLEEP_CHARM",
        "cost": [
          {
            "item": "ITM_SHARD_MOON_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_SLEEP_CHARM",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_MOON_GOLD_POUCH",
        "cost": [
          {
            "item": "ITM_SHARD_MOON_T1",
            "amount": 20
          }
        ],
        "gain": {
          "type": "CURRENCY",
          "id": "ITM_GOLD",
          "amount": 6000
        },
        "limit": 5,
        "resetPeriod": "WEEKLY"
      }
    ]
  },
  {
    "id": "SHOP_DUNGEON_FIELD",
    "entries": [
      {
        "id": "EX_LEAF_CLOAK",
        "cost": [
          {
            "item": "ITM_SHARD_FIELD_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_LEAF_CLOAK",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_ACORN_SHIELD",
        "cost": [
          {
            "item": "ITM_SHARD_FIELD_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_ACORN_SHIELD",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_SHARP_TWIG",
        "cost": [
          {
            "item": "ITM_SHARD_FIELD_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_SHARP_TWIG",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_HEAVY_ANCHOR",
        "cost": [
          {
            "item": "ITM_SHARD_FIELD_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_HEAVY_ANCHOR",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_STONE_SKIN",
        "cost": [
          {
            "item": "ITM_SHARD_FIELD_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_STONE_SKIN",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_LUCKY_CLOVER",
        "cost": [
          {
            "item": "ITM_SHARD_FIELD_T3",
            "amount": 10
          }
        ],
        "gain": {
          "type": "EQUIPMENT",
          "id": "EQP_LUCKY_CLOVER",
          "amount": 1
        },
        "limit": 0,
        "resetPeriod": "NONE"
      },
      {
        "id": "EX_FIELD_GOLD_POUCH",
        "cost": [
          {
            "item": "ITM_SHARD_FIELD_T1",
            "amount": 20
          }
        ],
        "gain": {
          "type": "CURRENCY",
          "id": "ITM_GOLD",
          "amount": 6000
        },
        "limit": 5,
        "resetPeriod": "WEEKLY"
      }
    ]
  },
  {
    "id": "SHOP_EVENT_DEMO",
    "entries": [
      {
        "id": "EX_EVENT_TOKEN_GOLD",
        "cost": [
          {
            "item": "ITM_EVENT_TOKEN",
            "amount": 10
          }
        ],
        "gain": {
          "type": "CURRENCY",
          "id": "ITM_GOLD",
          "amount": 500
        },
        "limit": 5,
        "resetPeriod": "EVENT"
      }
    ]
  }
];

export const ENTRIES_BY_ID: Record<string, ExchangeEntry> = Object.fromEntries(
  [...UPGRADES, ...SHOPS.flatMap((s) => s.entries)].map((e) => [e.id, e]),
);
