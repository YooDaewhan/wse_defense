/**
 * assets/data/v1/banners.json 서버 사본 — starterCharacters.ts/
 * dungeonData.ts와 같은 이유의 임시 상수. 드랍 확률처럼 게임플레이에
 * 영향을 주는 숫자라 서버에만 있는 이 값을 신뢰한다.
 */
export interface CostEntry {
  item: string;
  amount: number;
}

export interface BannerCost {
  single: CostEntry;
  ten: CostEntry;
}

export interface RateEntry {
  rarity: number;
  pickup?: boolean;
  totalPct: number;
  pool: string[];
}

export interface DuplicateConversion {
  rarity3: number;
  rarity2: number;
  rarity1: number;
  item: string;
}

export interface BannerMeta {
  id: string;
  kind: string;
  startAtUtc: string | null;
  endAtUtc: string | null;
  cost: BannerCost;
  givesExchangePoint: boolean;
  rates: RateEntry[];
  duplicateConversion: DuplicateConversion;
  exchangeTargets: string[];
}

export const BANNERS: BannerMeta[] = [
  {
    "id": "BNR_STANDARD",
    "kind": "STANDARD",
    "startAtUtc": null,
    "endAtUtc": null,
    "cost": {
      "single": {
        "item": "ITM_RECRUIT_TICKET",
        "amount": 1
      },
      "ten": {
        "item": "ITM_RECRUIT_TICKET",
        "amount": 10
      }
    },
    "givesExchangePoint": false,
    "rates": [
      {
        "rarity": 3,
        "pickup": true,
        "totalPct": 1500,
        "pool": [
          "CHR_BEAR"
        ]
      },
      {
        "rarity": 3,
        "pickup": false,
        "totalPct": 1500,
        "pool": [
          "CHR_BIRD"
        ]
      },
      {
        "rarity": 2,
        "totalPct": 17000,
        "pool": [
          "CHR_MUSHROOM",
          "CHR_DROPLET"
        ]
      },
      {
        "rarity": 1,
        "totalPct": 80000,
        "pool": [
          "CHR_ACORN"
        ]
      }
    ],
    "duplicateConversion": {
      "rarity3": 30,
      "rarity2": 10,
      "rarity1": 3,
      "item": "ITM_COLLECT_FRAGMENT"
    },
    "exchangeTargets": []
  },
  {
    "id": "BNR_THEME_BEAR",
    "kind": "THEME",
    "startAtUtc": null,
    "endAtUtc": null,
    "cost": {
      "single": {
        "item": "ITM_RECRUIT_TICKET",
        "amount": 1
      },
      "ten": {
        "item": "ITM_RECRUIT_TICKET",
        "amount": 10
      }
    },
    "givesExchangePoint": true,
    "rates": [
      {
        "rarity": 3,
        "pickup": true,
        "totalPct": 3000,
        "pool": [
          "CHR_BEAR"
        ]
      },
      {
        "rarity": 2,
        "totalPct": 17000,
        "pool": [
          "CHR_MUSHROOM",
          "CHR_DROPLET"
        ]
      },
      {
        "rarity": 1,
        "totalPct": 80000,
        "pool": [
          "CHR_ACORN",
          "CHR_BIRD"
        ]
      }
    ],
    "duplicateConversion": {
      "rarity3": 30,
      "rarity2": 10,
      "rarity1": 3,
      "item": "ITM_COLLECT_FRAGMENT"
    },
    "exchangeTargets": [
      "CHR_BEAR"
    ]
  }
];

export const BANNERS_BY_ID: Record<string, BannerMeta> = Object.fromEntries(BANNERS.map((b) => [b.id, b]));

export interface GachaExchangeRule {
  pointPerPull: number;
  requiredPoints: number;
  carryOver: boolean;
}

export const GACHA_EXCHANGE: GachaExchangeRule = {
  "pointPerPull": 1,
  "requiredPoints": 200,
  "carryOver": true
};

/** T-48에서 실제 확률표 버전 관리 인프라가 아직 없어(T-40류 동기화
 * 대상) 서버 배포 시점의 고정 문자열을 쓴다 — 원장(transactions)에
 * 남겨서 '그때 확률이 이랬다'를 나중에 증명할 근거로만 쓰인다. */
export const GACHA_RATES_VERSION = 'v1';
