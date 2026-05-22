import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'game_constants.dart';
import 'game_state.dart';
import '../models/vocab_item.dart';
import 'components/answer_effect.dart';
import 'components/bullet_component.dart';
import 'components/falling_word.dart';

class VocabGame extends FlameGame {
  final GameState gameState;
  final List<VocabItem> vocabItems;

  late List<VocabItem> _spawnQueue;
  late double boundaryY;

  late SpriteAnimation bulletAnimation;
  late List<Sprite> _correctFrames;
  late List<Sprite> _failFrames;

  double _spawnTimer = 0;
  static const double _spawnInterval = GameConstants.spawnInterval;
  static const int _maxActiveWords = GameConstants.maxActiveWords;
  final _random = Random();

  VocabGame({required this.gameState, required this.vocabItems});

  @override
  Color backgroundColor() => const Color(0xFF1462C8);

  @override
  Future<void> onLoad() async {
    images.prefix = 'assets/';

    final bgSprite = await loadSprite('PlayScreen/play_background.jpg');
    bulletAnimation = await _loadBulletAnimation();
    _correctFrames = await _loadCorrectFrames();
    _failFrames = await _loadFailFrames();

    add(SpriteComponent(
      sprite: bgSprite,
      size: size,
      priority: -10,
    ));

    _spawnQueue = List.from(vocabItems)..shuffle(_random);
    boundaryY = size.y - 15;

    AudioManager().startBgm();
    _trySpawn();
  }

  Future<SpriteAnimation> _loadBulletAnimation() async {
    final frames = await Future.wait(
      List.generate(
        7,
        (i) => loadSprite('PlayScreen/Star Bullet/shooting-export_${i + 1}.png'),
      ),
    );
    return SpriteAnimation.spriteList(frames, stepTime: 0.07);
  }

  Future<List<Sprite>> _loadCorrectFrames() async {
    return Future.wait(
      List.generate(26, (i) {
        final num = (i + 1).toString().padLeft(4, '0');
        return loadSprite(
            'PlayScreen/CorrectAnswer/Star explosion effect [f$num].png');
      }),
    );
  }

  Future<List<Sprite>> _loadFailFrames() {
    return Future.wait(
      List.generate(42, (i) {
        final num = i.toString().padLeft(4, '0');
        return loadSprite(
            'PlayScreen/FailAnswer/Fail answer effect [f$num].png');
      }),
    );
  }

  SpriteAnimation _makeCorrectAnimation() =>
      SpriteAnimation.spriteList(_correctFrames, stepTime: 0.05, loop: false);

  SpriteAnimation _makeFailAnimation() =>
      SpriteAnimation.spriteList(_failFrames, stepTime: 0.04, loop: false);


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
    final x = _random.nextDouble() * (size.x - GameConstants.wordWidth) +
        GameConstants.spawnMarginX;
    add(FallingWord(
      vocabItem: item,
      gameState: gameState,
      onMissed: _onWordMissed,
      onTapped: _onWordTapped,
      initialPosition: Vector2(x, GameConstants.spawnInitialY),
    ));
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
    final startPos = Vector2(size.x / 2, size.y - 5);

    final delta = targetPos - startPos;
    gameState.setGunAngle(atan2(delta.x, -delta.y));
    gameState.triggerMuzzleFlash();
    AudioManager().playShoot();

    add(BulletComponent(
      start: startPos,
      target: targetPos,
      animation: bulletAnimation,
      onHit: () {
        gameState.setGunAngle(0.0);
        if (word.isRemoved) return;
        if (selected != null && selected == word.vocabItem.meaning) {
          gameState.onCorrectMatch(word.vocabItem.meaning);
          word.removeFromParent();
          add(AnswerEffect(
            position: targetPos,
            animation: _makeCorrectAnimation(),
          ));
          AudioManager().playCorrect();
          if (gameState.score == vocabItems.length) {
            AudioManager().playWin();
          }
        } else {
          gameState.clearSelection();
          add(AnswerEffect(
            position: targetPos,
            animation: _makeFailAnimation(),
            size: 180,
          ));
          AudioManager().playWrong();
        }
      },
    ));
  }
}
