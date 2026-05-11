import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'bullet_component.dart';
import '../game_constants.dart';
import '../vocab_game.dart';

class GunComponent extends PositionComponent with HasGameReference<VocabGame> {
  final _bodyPaint = Paint()..color = GameConstants.gunBodyColor;
  final _barrelPaint = Paint()..color = GameConstants.gunBarrelColor;

  GunComponent({required Vector2 position})
    : super(
        position: position,
        size: Vector2(GameConstants.gunWidth, GameConstants.gunHeight),
        anchor: Anchor.bottomCenter,
      );

  void aimAt(Vector2 worldTarget) {
    final delta = worldTarget - absoluteCenter;
    angle = atan2(delta.x, -delta.y);
  }

  void shoot({required Vector2 worldTarget, required VoidCallback onHit}) {
    final dir = (worldTarget - absoluteCenter).normalized();
    final start = absoluteCenter + dir * GameConstants.gunBulletStartOffset;
    game.add(BulletComponent(start: start, target: worldTarget, onHit: onHit));
  }

  @override
  void render(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y / 2;

    canvas.drawCircle(Offset(cx, cy), GameConstants.gunBodyRadius, _bodyPaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy - GameConstants.gunBarrelOffsetY),
          width: GameConstants.gunBarrelWidth,
          height: GameConstants.gunBarrelHeight,
        ),
        const Radius.circular(GameConstants.gunBarrelRadius),
      ),
      _barrelPaint,
    );
  }
}
