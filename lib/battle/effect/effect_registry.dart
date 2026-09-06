import 'effect.dart';
import 'handlers/atk_down_handler.dart';
import 'handlers/grant_tag_handler.dart';
import 'handlers/heal_handler.dart';
import 'handlers/pierce_handler.dart';
import 'handlers/push_handler.dart';
import 'handlers/rally_handler.dart';
import 'handlers/shell_handler.dart';
import 'handlers/slow_handler.dart';
import 'handlers/stat_buff_handler.dart';
import 'handlers/stun_handler.dart';

/// 03_BATTLE_ENGINE.md §10.
class EffectRegistry {
  EffectRegistry._();

  static final Map<String, EffectHandler> _handlers = {};

  static void register(EffectHandler h) => _handlers[h.type] = h;
  static EffectHandler? of(String type) => _handlers[type];

  /// 테스트 격리용.
  static void reset() => _handlers.clear();
}

/// 등록부 — 새 효과 추가 시 여기 한 줄만 늘어난다. (REVIVE는 M3, 이 티켓
/// 스코프 밖.)
void registerAllEffects() {
  EffectRegistry.register(StunHandler()); // 멈칫
  EffectRegistry.register(SlowHandler()); // 느릿
  EffectRegistry.register(PushHandler()); // 밀치기
  EffectRegistry.register(HealHandler()); // 토닥임
  EffectRegistry.register(StatBuffHandler()); // 스탯 버프
  EffectRegistry.register(GrantTagHandler()); // ★ 태그 부여 효과
  EffectRegistry.register(AtkDownHandler()); // 기죽이기 (M2)
  EffectRegistry.register(RallyHandler()); // 기운내기 (M2)
  EffectRegistry.register(PierceHandler()); // 뚫기 (M2)
  EffectRegistry.register(ShellHandler()); // 껍질 (M2)
}
