/// 01_ARCHITECTURE.md §3.1 결정론 수치 규칙.
/// 전투 코어는 double을 쓰지 않고 이 스케일들로 고정소수점 정수 연산만 한다.
library;

const int ticksPerSec = 30;

/// 100% == pctScale (밀리퍼센트). 예: +15% → 15000.
const int pctScale = 100000;

/// 논리좌표 1.0 == posScale.
const int posScale = 1000;

/// value에 밀리퍼센트 pctMilli(§3.1 기준)를 적용한다. 예: applyPct(1000, 15000) == 150.
int applyPct(int value, int pctMilli) => value * pctMilli ~/ pctScale;

/// 논리 좌표(1.0 단위)를 내부 고정소수점 좌표로 변환한다.
int toFixedPos(int logicalUnits) => logicalUnits * posScale;

/// 초당 속도(논리단위/초)를 틱당 이동량(고정소수점)으로 변환한다.
int speedPerTick(int speedPerSecLogical) =>
    speedPerSecLogical * posScale ~/ ticksPerSec;

/// n/d를 반올림하여 정수 나눗셈한다 (d > 0). §3.1의 반올림 표기 형태.
int roundedDiv(int n, int d) => (n + d ~/ 2) ~/ d;

/// 03_BATTLE_ENGINE.md §6.2 넉백 상수.
const int naturalKbDistance = 90; // 논리 단위
const int naturalKbTicks = 12; // 0.4초
const int forcedKbImmuneTicks = 30; // 강제 넉백 재적용 방지 1초

/// 03_BATTLE_ENGINE.md §8 기도력·필살기 상수.
const int unitCap = 40; // 편당 최대 생존 유닛 수
const int ultGaugeMax = 1800; // 60초 x 30틱
const int ultGaugePerTick = 1;
const int ultMaxStock = 1;
