import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Monster extends SpriteComponent with HasGameRef<FlameGame> {
  @override
  Future<void> onLoad() async {
    // 🔥 몬스터 이미지
    sprite = await Sprite.load('mushroom.png');

    // 크기
    size = Vector2(128, 128);

    // 기준점
    anchor = Anchor.center;

    // 🔥 중앙 (onLoad 시점 기준)
    position = gameRef.size / 2;

    // 🔥 배경 위로
    priority = 1;

    // 🔥 디버그용 (안 보일 경우라도 빨간 사각형은 떠야 함)
    paint = Paint()..color = const Color(0xFFFFFFFF);
  }

  void moveToCenter(Vector2 gameSize) {
    position = gameSize / 2;
  }
}
