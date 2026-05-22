import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../game_constants.dart';

class BulletComponent extends PositionComponent {
  static const double _speed = GameConstants.bulletSpeed;

  final VoidCallback onHit;
  final Vector2 _velocity;
  final double _maxDistance;
  double _traveled = 0;
  final SpriteAnimation _animation;

  BulletComponent({
    required Vector2 start,
    required Vector2 target,
    required this.onHit,
    required SpriteAnimation animation,
  })  : _velocity = (target - start).normalized() * _speed,
        _maxDistance = start.distanceTo(target),
        _animation = animation,
        super(
          position: start.clone(),
          size: Vector2(54, 240),
          anchor: Anchor.topCenter,
        ) {
    final dir = target - start;
    angle = atan2(dir.x, -dir.y);
  }

  @override
  Future<void> onLoad() async {
    add(SpriteAnimationComponent(
      animation: _animation.clone(),
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final step = _velocity * dt;
    position += step;
    _traveled += step.length;
    if (_traveled >= _maxDistance ||
        position.y < GameConstants.bulletOffscreenThreshold) {
      onHit();
      removeFromParent();
    }
  }
}
