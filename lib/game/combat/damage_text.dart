import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DamageText extends TextComponent {
  double lifeTime = 0.8;
  double elapsed = 0;

  DamageText({required Vector2 position, required int damage})
    : super(
        text: '-$damage',
        position: position,
        anchor: Anchor.center,
        priority: 1000,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
            shadows: [
              Shadow(blurRadius: 4, color: Colors.black, offset: Offset(2, 2)),
            ],
          ),
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);

    elapsed += dt;

    // 화면 기준 위로 이동
    position.y -= 40 * dt;

    final opacity = (1 - elapsed / lifeTime).clamp(0.0, 1.0);
    textRenderer = TextPaint(
      style: (textRenderer as TextPaint).style.copyWith(
        color: Colors.redAccent.withOpacity(opacity),
      ),
    );

    if (elapsed >= lifeTime) {
      removeFromParent();
    }
  }
}
