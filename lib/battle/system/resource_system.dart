import '../constants.dart';
import '../world/battle_world.dart';
import 'battle_system.dart';

/// 03_BATTLE_ENGINE.md §8: 기도력 자동 회복, 필살기 게이지 충전.
///
/// 틱 단위 정수 누적: 나머지를 `prayerPowerFrac`에 보관해 오차 0 (§3.1).
/// `weatherRegenPct`는 WeatherSystem(T-45) 전까지 100%(pctScale) 고정이라
/// 곱해도 값이 바뀌지 않지만, 나중에 그 시스템이 붙을 자리를 그대로 둔다.
///
/// 편성 슬롯의 재소환 쿨다운도 여기서 같이 흘려보낸다 — trySummon(T-12
/// summon.dart)이 쓰는 값과 같은 "매 틱 감소하는 자원"이라 자연스러운 묶음.
class ResourceSystem implements BattleSystem {
  @override
  void execute(BattleWorld w) {
    final perSec = w.config.focusBaseRegen + w.config.focusBoostBonus[w.focusBoostStage];
    final weathered = perSec * w.weatherRegenPct ~/ pctScale;

    w.prayerPowerFrac += weathered;
    final gain = w.prayerPowerFrac ~/ ticksPerSec;
    w.prayerPowerFrac -= gain * ticksPerSec;

    var next = w.prayerPower + gain;
    if (next < 0) next = 0;
    if (next > w.currentPrayerCap) next = w.currentPrayerCap; // 상한 초과분은 버려짐
    w.prayerPower = next;

    if (w.ultimateStock < ultMaxStock) {
      w.ultimateGauge += ultGaugePerTick; // 60초 = 1800틱에 만충
      if (w.ultimateGauge >= ultGaugeMax) {
        w.ultimateGauge -= ultGaugeMax;
        w.ultimateStock++;
      }
    }

    for (final slot in w.formation) {
      if (slot.cooldownLeft > 0) slot.cooldownLeft--;
    }
  }
}
