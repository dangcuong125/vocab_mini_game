import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../models/vocab_item.dart';
import '../game_constants.dart';
import '../game_state.dart';
import '../vocab_game.dart';

class FallingWord extends PositionComponent
    with TapCallbacks, HasGameReference<VocabGame> {
  final VocabItem vocabItem;
  final GameState gameState;
  final void Function(VocabItem) onMissed;
  final void Function(FallingWord) onTapped;

  static const double _speed = GameConstants.wordSpeed;

  late TextComponent _label;

  static final _normalPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      shadows: [Shadow(color: Color(0xAAFFFFFF), blurRadius: 8)],
    ),
  );

  FallingWord({
    required this.vocabItem,
    required this.gameState,
    required this.onMissed,
    required this.onTapped,
    required Vector2 initialPosition,
  }) : super(
          position: initialPosition,
          size: Vector2(GameConstants.wordWidth, GameConstants.wordHeight),
          anchor: Anchor.topCenter,
        );

  @override
  Future<void> onLoad() async {
    _label = TextComponent(
      text: vocabItem.word,
      textRenderer: _normalPaint,
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_label);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameState.isGameOver) return;
    position.y += _speed * dt;
    if (position.y >= game.boundaryY) {
      if (!gameState.disabledMeanings.contains(vocabItem.meaning)) {
        gameState.loseLife();
      }
      onMissed(vocabItem);
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameState.isGameOver) return;
    onTapped(this);
  }

}
