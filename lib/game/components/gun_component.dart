import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'bullet_component.dart';
import '../vocab_game.dart';

class GunComponent extends PositionComponent with HasGameReference<VocabGame> {
  final Sprite _gunSprite;
  final Sprite _circleSprite;

  GunComponent({
    required Vector2 position,
    required Sprite gunSprite,
    required Sprite circleSprite,
  })  : _gunSprite = gunSprite,
        _circleSprite = circleSprite,
        super(
          position: position,
          size: Vector2(80, 80),
          anchor: Anchor.bottomCenter,
        );

  @override
  Future<void> onLoad() async {
    // Glowing circle under the gun base
    add(SpriteComponent(
      sprite: _circleSprite,
      size: Vector2(130, 44),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y * 0.88),
      priority: 0,
    ));
    // Gun turret on top
    add(SpriteComponent(
      sprite: _gunSprite,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      priority: 1,
    ));
  }

  void aimAt(Vector2 worldTarget) {
    final delta = worldTarget - absoluteCenter;
    angle = atan2(delta.x, -delta.y);
  }

  void shoot({required Vector2 worldTarget, required VoidCallback onHit}) {
    final dir = (worldTarget - absoluteCenter).normalized();
    final start = absoluteCenter + dir * 40;
    game.add(BulletComponent(
      start: start,
      target: worldTarget,
      onHit: onHit,
      animation: game.bulletAnimation,
    ));
  }
}
