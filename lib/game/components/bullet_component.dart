import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_constants.dart';

class BulletComponent extends PositionComponent {
  static const double _speed = GameConstants.bulletSpeed;

  final VoidCallback onHit;
  final Vector2 _velocity;
  final double _maxDistance;
  double _traveled = 0;

  BulletComponent({
    required Vector2 start,
    required Vector2 target,
    required this.onHit,
  })  : _velocity = (target - start).normalized() * _speed,
        _maxDistance = start.distanceTo(target),
        super(position: start.clone(), size: Vector2(GameConstants.bulletWidth, GameConstants.bulletHeight), anchor: Anchor.center) {
    final dir = target - start;
    angle = atan2(dir.x, -dir.y);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(GameConstants.bulletRadius)),
      Paint()..color = GameConstants.bulletColor,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final step = _velocity * dt;
    position += step;
    _traveled += step.length;
    if (_traveled >= _maxDistance || position.y < GameConstants.bulletOffscreenThreshold) {
      onHit();
      removeFromParent();
    }
  }
}
