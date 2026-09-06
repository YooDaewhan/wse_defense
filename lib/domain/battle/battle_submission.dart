import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../battle/tag/tag_query.dart';
import '../../battle/world/battle_input.dart';
import '../../battle/world/battle_world.dart';

// 10_WIRING_PLAN.md T-60: 실제로 플레이한 BattleWorld + 그동안 기록해 둔
// 입력으로 submitBattle 요청 바디(06_BACKEND.md §4.4 BattleSummary)를
// 조립하는 순수 함수들. world는 InputQueue/InputSystem을 거치지 않고
// 직접 호출(trySummon/castUltimate)로 진행되므로, 입력 기록 자체는 그
// 호출 시점에 호출부(BattleScreen)가 별도로 쌓아 둔 BattleInput 목록을
// 그대로 받는다.

String battleOutcomeCode(BattleOutcome outcome) => switch (outcome) {
  BattleOutcome.allyWin => 'ALLY_WIN',
  BattleOutcome.enemyWin => 'ENEMY_WIN',
  BattleOutcome.draw => 'DRAW',
  BattleOutcome.timeout => 'TIMEOUT',
};

/// 사망한 엔티티는 store에서 지워지지 않고 `action == dead`로 남는다(§8
/// DeathSystem)라 전투 종료 시점에 한 번만 훑어도 정확하다.
int countEnemiesKilled(BattleWorld world) =>
    world.entities.ordered.where((e) => e.side == Side.enemy && !e.isAlive).length;

/// 편성 전체에서 가장 앞선(적 기지 쪽) 아군의 x좌표. 아군이 하나도 없으면
/// 아군 기지 위치.
int frontAllyX(BattleWorld world) {
  int? frontAlly;
  for (final e in world.entities.ordered) {
    if (e.side != Side.ally || !e.isAlive) continue;
    if (frontAlly == null || e.x > frontAlly) frontAlly = e.x;
  }
  return frontAlly ?? world.allyBase.x;
}

/// [maxFrontlineX]는 매 프레임 `frontAllyX`를 갱신하며 호출부가 계속
/// 들고 있던 "진짜" 최댓값을 넘겨야 한다 -- 종료 시점에 한 번만 보면
/// 후퇴했을 때 실제보다 낮게 잡힌다.
Map<String, dynamic> buildBattleSummary({
  required BattleWorld world,
  required List<BattleInput> recordedInputs,
  required int maxFrontlineX,
}) {
  var totalSummons = 0;
  var ultimateUsed = 0;
  var totalPrayerSpent = 0;
  for (final input in recordedInputs) {
    if (input is SummonInput) {
      totalSummons++;
      totalPrayerSpent += world.formation[input.slotIndex].def.base.summonCost;
    } else if (input is UltimateInput) {
      ultimateUsed++;
    }
  }

  return {
    'endTick': world.tick,
    'totalSummons': totalSummons,
    'totalPrayerSpent': totalPrayerSpent,
    'ultimateUsed': ultimateUsed,
    'focusBoostStage': world.focusBoostStage,
    'enemiesKilled': countEnemiesKilled(world),
    'enemyBaseHpLeft': world.enemyBase.hp,
    'allyBaseHpLeft': world.allyBase.hp,
    'maxFrontlineX': maxFrontlineX,
  };
}

/// 06_BACKEND.md §4.4 V12 -- 서버가 `sha256(inputLogBase64:seed:formationHash)`
/// 로 재계산해 비교하므로 정확히 같은 문자열을 해시해야 한다
/// (functions/src/battle/validators.ts computeV12Checksum과 반드시 일치).
String computeBattleChecksum({required String inputLogBase64, required int seed, required String formationHash}) =>
    sha256.convert(utf8.encode('$inputLogBase64:$seed:$formationHash')).toString();
