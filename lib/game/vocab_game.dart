import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game_constants.dart';
import 'game_state.dart';
import '../models/vocab_item.dart';
import 'components/falling_word.dart';
import 'components/gun_component.dart';
import 'components/limit_line_component.dart';

class VocabGame extends FlameGame {
  final GameState gameState;
  final List<VocabItem> vocabItems;

  late List<VocabItem> _spawnQueue;
  late GunComponent _gun;
  late double boundaryY;
  double _spawnTimer = 0;
  static const double _spawnInterval = GameConstants.spawnInterval;
  static const int _maxActiveWords = GameConstants.maxActiveWords;
  final _random = Random();

  VocabGame({required this.gameState, required this.vocabItems});

  @override
  Color backgroundColor() => GameConstants.gameBackgroundColor;

  @override
  Future<void> onLoad() async {
    _spawnQueue = List.from(vocabItems)..shuffle(_random);
    boundaryY =
        size.y -
        GameConstants.gunOffsetFromBottom -
        GameConstants.gunHeight -
        GameConstants.limitLineAboveGun;
    _gun = GunComponent(
      position: Vector2(size.x / 2, size.y - GameConstants.gunOffsetFromBottom),
    );
    add(_gun);
    add(LimitLineComponent(y: boundaryY, width: size.x));
    _trySpawn();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameState.isGameOver) return;
    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _trySpawn();
    }
  }

  void _trySpawn() {
    final activeWords = children.whereType<FallingWord>().length;
    if (activeWords >= _maxActiveWords ||
        _spawnQueue.isEmpty ||
        gameState.isGameOver) {
      return;
    }

    final item = _spawnQueue.removeAt(0);
    final x =
        _random.nextDouble() * (size.x - GameConstants.wordWidth) +
        GameConstants.spawnMarginX;
    add(
      FallingWord(
        vocabItem: item,
        gameState: gameState,
        onMissed: _onWordMissed,
        onTapped: _onWordTapped,
        initialPosition: Vector2(x, GameConstants.spawnInitialY),
      ),
    );
  }

  void _onWordMissed(VocabItem item) {
    if (!gameState.disabledMeanings.contains(item.meaning)) {
      _spawnQueue.add(item);
    }
  }

  void _onWordTapped(FallingWord word) {
    if (gameState.isGameOver || word.isRemoved) return;
    if (gameState.selectedMeaning == null) return;

    final selected = gameState.selectedMeaning;
    final targetPos = word.absoluteCenter;

    _gun.aimAt(targetPos);
    _gun.shoot(
      worldTarget: targetPos,
      onHit: () {
        if (word.isRemoved) return;
        if (selected != null && selected == word.vocabItem.meaning) {
          gameState.onCorrectMatch(word.vocabItem.meaning);
          word.removeFromParent();
        } else {
          gameState.loseLife();
          word.showWrongEffect();
        }
      },
    );
  }
}
