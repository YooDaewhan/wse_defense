import '../../battle/defs/datapack.dart';
import '../../battle/defs/stage_def.dart';
import '../../battle/world/battle_config.dart';
import '../../battle/world/battle_world.dart';
import '../../battle/world/canonical_systems.dart';

/// 05_FRONTEND.md §9.2 튜토리얼 전용 스테이지. `tutorial_step.dart`의
/// 게이트(§8 예시의 "STG_TUTORIAL"은 실제로 존재하지 않아 이 프로젝트
/// 값으로 대체) 7단계가 60~90초 안에 끝나도록 맞춘 구성 --
/// `test/domain/tutorial/tutorial_flow_test.dart`가 그 진행을 이미 검증
/// 했다(단, 그 테스트는 최소 시스템 목록으로 돈다).
///
/// T6(NEST_DESTROYED)는 적 기지에 실제로 피해를 주는 경로가 아직 없어(§8
/// AttackSystem 스코프 밖 -- tutorial_step.dart 주석 참고) 실제 플레이로는
/// 도달 못 할 수 있다. 이건 이 라우트를 여기 연결하는 것과는 별개의,
/// 이미 있던 엔진 한계라 여기서 고치지 않는다.
const tutorialStageId = 'STG_TUTORIAL';

BattleWorld buildTutorialWorld(Datapack datapack) {
  final acorn = datapack.characterById('CHR_ACORN');
  final droplet = datapack.characterById('CHR_DROPLET');
  return BattleWorld(
    config: BattleConfig(
      stage: const StageDef(
        id: tutorialStageId,
        index: 0,
        fieldLength: 2400,
        allyBaseX: 0,
        enemyBaseX: 2400,
        enemyBaseHp: 5000,
        timeLimitSec: 120,
      ),
      allyBaseHp: 10000,
      formation: [?acorn, ?droplet],
      focusBaseRegen: 18,
      startingPrayerPower: 200,
    ),
    rngSeed: 1,
    datapack: datapack,
    systems: canonicalBattleSystems(),
  )..phase = BattlePhase.running;
}
