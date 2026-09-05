import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';

/// 05_FRONTEND.md §4.1 `DamageTextLayer` 항목 하나. 아트/폰트 연출은 아직
/// 없어(P0~P1 원칙) 숫자만 위로 살짝 떠오르며 표시한다. 만료되면(ttl<=0)
/// 그리지 않을 뿐 컴포넌트를 제거하지 않는다 — `ObjectPool`이 재사용한다.
class DamageTextComponent extends TextComponent {
  DamageTextComponent()
    : super(
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(color: Color(0xFFFFEE58), fontWeight: FontWeight.bold, fontSize: 14),
        ),
      );

  static const double _lifetimeSec = 0.6;
  static const double _riseSpeed = 30; // px/초

  double _ttl = 0;

  void showAmount(int amount, Vector2 worldPosition) {
    text = '$amount';
    position = worldPosition.clone();
    _ttl = _lifetimeSec;
  }

  bool get isExpired => _ttl <= 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (_ttl > 0) {
      _ttl -= dt;
      position.y -= _riseSpeed * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    if (isExpired) return; // 만료 중엔 안 그리고 재사용을 기다린다
    super.render(canvas);
  }
}
