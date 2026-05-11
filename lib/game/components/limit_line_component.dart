import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_constants.dart';

class LimitLineComponent extends PositionComponent {
  LimitLineComponent({required double y, required double width})
    : super(position: Vector2(0, y), size: Vector2(width, 1));

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = GameConstants.limitLineColor.withValues(alpha: GameConstants.limitLineAlpha)
      ..strokeWidth = GameConstants.limitLineStrokeWidth
      ..style = PaintingStyle.fill;

    canvas.drawLine(Offset(0, 0), Offset(size.x, 0), paint);
  }
}
