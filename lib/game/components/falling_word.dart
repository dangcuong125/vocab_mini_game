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
  static const Color _normalColor = GameConstants.wordNormalColor;
  static const Color _wrongColor = GameConstants.wordWrongColor;
  static const Color _textColor = GameConstants.wordTextColor;

  final Paint _bgPaint = Paint()..color = _normalColor;
  bool _flashing = false;

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
    add(
      TextComponent(
        text: vocabItem.word,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: _textColor,
            fontSize: GameConstants.wordFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        size.toRect(),
        const Radius.circular(GameConstants.wordBorderRadius),
      ),
      _bgPaint,
    );
    super.render(canvas);
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

  void showWrongEffect() {
    if (_flashing || isRemoved) return;
    _flashing = true;
    _bgPaint.color = _wrongColor;
    Future.delayed(
      const Duration(milliseconds: GameConstants.wordWrongFlashMs),
      () {
        if (!isRemoved) {
          _bgPaint.color = _normalColor;
          _flashing = false;
        }
      },
    );
  }
}
