import 'package:flame/components.dart';

class AnswerEffect extends SpriteAnimationComponent {
  AnswerEffect({
    required Vector2 position,
    required SpriteAnimation animation,
    double size = 140,
  }) : super(
          animation: animation,
          size: Vector2.all(size),
          anchor: Anchor.center,
          position: position,
          priority: 10,
        );

  @override
  Future<void> onLoad() async {
    animationTicker!.onComplete = removeFromParent;
  }
}
