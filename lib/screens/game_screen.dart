import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../data/vocab_data.dart';
import '../game/audio_manager.dart';
import '../game/game_state.dart';
import '../game/vocab_game.dart';
import '../models/vocab_item.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  late VocabGame _game;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    AudioManager().dispose();
    super.dispose();
  }

  void _startNewGame() {
    _gameState = GameState();
    _game = VocabGame(gameState: _gameState, vocabItems: sampleVocab);
  }

  void _restart() {
    setState(() {
      _startNewGame();
    });
  }

  void _togglePause() {
    _gameState.togglePause();
    if (_gameState.isPaused) {
      _game.pauseEngine();
      AudioManager().stopBgm();
    } else {
      _game.resumeEngine();
      AudioManager().startBgm();
    }
  }

  void _toggleSfx() {
    _gameState.toggleSfx();
    AudioManager().sfxEnabled = _gameState.isSfxOn;
  }

  void _toggleBgm() {
    _gameState.toggleBgm();
    // Only update the enabled flag; don't start BGM while paused.
    // startBgm() is called on resume and checks bgmEnabled automatically.
    AudioManager().bgmEnabled = _gameState.isBgmOn;
    if (!_gameState.isBgmOn) AudioManager().stopBgm();
  }

  bool get _isGameOver =>
      _gameState.score == sampleVocab.length || _gameState.isGameOver;
  bool get _isWin => _gameState.score == sampleVocab.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1462C8),
      body: ListenableBuilder(
        listenable: _gameState,
        builder: (context, _) {
          return Stack(
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: GameWidget(game: _game)),
                    Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.2)),
                    _buildActionButtons(),
                    _buildAnswersPanel(),
                  ],
                ),
              ),
              if (_gameState.isPaused && !_isGameOver)
                Positioned.fill(child: _buildPauseOverlay()),
              if (_isGameOver)
                Positioned.fill(child: _buildGameOverOverlay()),
            ],
          );
        },
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF1462C8),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Score badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0D2A52),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/Others/star.png', width: 20, height: 20),
                const SizedBox(width: 6),
                Text(
                  '${_gameState.score}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Level + hearts (centered)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final alive = i < _gameState.lives;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Opacity(
                        opacity: alive ? 1.0 : 0.3,
                        child: Image.asset(
                          'assets/PlayScreen/heart.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          // Pause / Resume button
          GestureDetector(
            onTap: _togglePause,
            child: _gameState.isPaused
                ? const Icon(Icons.play_circle_filled,
                    color: Colors.white, size: 34)
                : Image.asset('assets/PlayScreen/pause.png',
                    width: 32, height: 32),
          ),
        ],
      ),
    );
  }

  // ─── Action buttons (power-ups) ────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Container(
      color: const Color(0xFF1462C8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _actionButton('assets/PlayScreen/slow.png'),
            _actionButton('assets/PlayScreen/x2_score.png'),
            _gunWidget(),
            _actionButton('assets/PlayScreen/tips.png'),
            _actionButton('assets/PlayScreen/freeze.png'),
          ],
        ),
      ),
    );
  }

  Widget _gunWidget() {
    return SizedBox(
      width: 90,
      height: 90,
      child: Center(
        child: AnimatedRotation(
          turns: _gameState.gunAngle / (2 * pi),
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Image.asset('assets/PlayScreen/gun.png', width: 80, height: 80),
                if (_gameState.muzzleFlash)
                  Positioned(
                    top: -30,
                    left: -20,
                    right: -20,
                    child: Image.asset(
                      'assets/PlayScreen/shooting_circle.png',
                      height: 80,
                      fit: BoxFit.fill,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(String asset) {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: 62,
        height: 62,
        child: Stack(
          children: [
            Image.asset(
              'assets/PlayScreen/action_button_bg.png',
              width: 62,
              height: 62,
              fit: BoxFit.fill,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(asset),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Answers panel ─────────────────────────────────────────────────────────

  Widget _buildAnswersPanel() {
    return Container(
      color: const Color(0xFF1462C8),
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      child: SafeArea(
        top: false,
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.1,
          children: sampleVocab.map(_buildMeaningChip).toList(),
        ),
      ),
    );
  }

  Widget _buildMeaningChip(VocabItem item) {
    final isSelected = _gameState.selectedMeaning == item.meaning;
    final isDisabled = _gameState.disabledMeanings.contains(item.meaning);

    return GestureDetector(
      onTap: isDisabled ? null : () => _gameState.selectMeaning(item.meaning),
      child: Opacity(
        opacity: isDisabled ? 0.35 : 1.0,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                isSelected
                    ? 'assets/PlayScreen/touch_answer.png'
                    : 'assets/PlayScreen/answers.png',
                fit: BoxFit.fill,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  item.meaning,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF7A3500)
                        : const Color(0xFF1A3A6B),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Pause overlay ─────────────────────────────────────────────────────────

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black.withAlpha(170),
      child: Center(
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x44000000), blurRadius: 20, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFDDEEFF),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Text(
                  'THIẾT LẬP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0D2A52),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              // Setting rows
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                child: Column(
                  children: [
                    _buildSettingRow(
                        'Âm thanh', _gameState.isSfxOn, _toggleSfx),
                    const SizedBox(height: 18),
                    _buildSettingRow(
                        'Nhạc nền', _gameState.isBgmOn, _toggleBgm),
                  ],
                ),
              ),
              // Icon buttons (back to list + restart)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconButton(
                      Image.asset('assets/PlayScreen/return_list.png'),
                      () {
                        AudioManager().stopBgm();
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 28),
                    _buildIconButton(
                      const Icon(Icons.replay_rounded,
                          color: Colors.white, size: 28),
                      () {
                        _gameState.togglePause();
                        _game.resumeEngine();
                        _restart();
                      },
                    ),
                  ],
                ),
              ),
              // Continue button
              GestureDetector(
                onTap: _togglePause,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3A9FFF),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'TIẾP TỤC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, bool isOn, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0D2A52),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 88,
            height: 36,
            decoration: BoxDecoration(
              color:
                  isOn ? const Color(0xFF3A9FFF) : const Color(0xFF7B3030),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: isOn ? 10 : null,
                  right: isOn ? null : 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Text(
                      isOn ? 'ON' : 'OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  right: isOn ? 3 : null,
                  left: isOn ? null : 3,
                  top: 3,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(Widget child, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF3A9FFF),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(10),
        child: child,
      ),
    );
  }

  // ─── Game Over overlay ─────────────────────────────────────────────────────

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withAlpha(170),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A3A6B), Color(0xFF0D1F3C)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.cyanAccent.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isWin)
                Image.asset('assets/Others/star.png', width: 72, height: 72),
              const SizedBox(height: 8),
              const Text(
                'KẾT THÚC',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/Others/star.png', width: 28, height: 28),
                  const SizedBox(width: 6),
                  Text(
                    '${_gameState.score} / ${sampleVocab.length}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: _restart,
                child: Image.asset(
                  'assets/Others/game_button.png',
                  width: 180,
                  height: 72,
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
