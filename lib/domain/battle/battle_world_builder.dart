import '../../battle/defs/datapack.dart';
import '../../battle/defs/stage_def.dart';
import '../../battle/defs/weather_config.dart';
import '../../battle/world/battle_config.dart';
import '../../battle/world/battle_world.dart';
import '../../battle/world/canonical_systems.dart';
import '../../data/tag/tag_data_loader.dart';
import '../account/account_state.dart';
import '../growth/growth_battle_stats.dart';
import '../growth/growth_config.dart';

/// 10_WIRING_PLAN.md T-60: `startBattle` 응답 + 로컬 정적 데이터(AppScope)
/// 로 실제로 플레이할 [BattleWorld]를 세운다. 서버가 확정해 돌려준
/// [formationSlots](StartBattleRes.formationSnapshot.slots)만 신뢰하고,
/// 성장치는 growth_battle_stats.dart의 계단 함수로 근사한다(§ 파일 주석
/// 참고 -- 매끄러운 보간 아님).
BattleWorld buildBattleWorldFromStart({
  required StageDef stage,
  required Datapack datapack,
  required int seed,
  required List<Map<String, dynamic>> formationSlots,
  TagBundle? tagBundle,
  GrowthConfig? growthConfig,
  WeatherConfig? weatherConfig,
  AccountState account = const AccountState(gold: 0, ownedCharacterIds: {}),
}) {
  final formation = [
    for (final slot in formationSlots)
      if (slot['characterId'] != null) datapack.characterById(slot['characterId'] as String),
  ].nonNulls.toList();

  final focus = growthConfig == null ? null : focusStatsForLevel(growthConfig, account.focusLevel);
  final camp = growthConfig == null ? null : campStatsForLevel(growthConfig, account.campLevel);

  return BattleWorld(
    config: BattleConfig(
      stage: stage,
      allyBaseHp: camp?.hp ?? 10000,
      formation: formation,
      focusBaseRegen: focus?.regenPerSec ?? 18,
      focusBaseCap: focus?.cap ?? 1000,
      startingPrayerPower: focus?.startAmount ?? 200,
      tagRegistry: tagBundle?.registry,
      tagEffects: tagBundle?.effects ?? const [],
      relationRules: tagBundle?.relations ?? const [],
      weatherConfig: weatherConfig ?? const WeatherConfig(),
    ),
    rngSeed: seed,
    datapack: datapack,
    systems: canonicalBattleSystems(),
  )..phase = BattlePhase.running;
}
