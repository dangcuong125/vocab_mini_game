import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../data/vocab_data.dart';
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

  void _startNewGame() {
    _gameState = GameState();
    _game = VocabGame(gameState: _gameState, vocabItems: sampleVocab);
  }

  void _restart() {
    setState(() {
      _startNewGame();
    });
  }

  bool get _isGameOver =>
      _gameState.score == sampleVocab.length || _gameState.isGameOver;

  bool get _isWin => _gameState.score == sampleVocab.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 81, 154, 232),
      body: ListenableBuilder(
        listenable: _gameState,
        builder: (context, _) {
          return Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(flex: 6, child: GameWidget(game: _game)),
                    _buildMeaningsPanel(),
                  ],
                ),
              ),
              if (_isGameOver) Positioned.fill(child: _buildGameOverOverlay()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withAlpha(180),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2838),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF4CAF50), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isWin ? '🎉 Hoàn thành!' : '💔 Kết thúc!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '${_gameState.score} điểm',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Chơi lại',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ListenableBuilder(
      listenable: _gameState,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${_gameState.score}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  ...List.generate(
                    3,
                    (i) => Icon(
                      i < _gameState.lives
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: i < _gameState.lives ? Colors.red : Colors.grey,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMeaningsPanel() {
    return ListenableBuilder(
      listenable: _gameState,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 81, 154, 232),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sampleVocab
                    .map((item) => _buildMeaningChip(item))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMeaningChip(VocabItem item) {
    final isSelected = _gameState.selectedMeaning == item.meaning;
    final isDisabled = _gameState.disabledMeanings.contains(item.meaning);

    return GestureDetector(
      onTap: isDisabled ? null : () => _gameState.selectMeaning(item.meaning),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDisabled
              ? const Color(0xFF1E1E1E)
              : isSelected
              ? const Color.fromARGB(255, 180, 176, 61)
              : const Color(0xFF1E3A5F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDisabled
                ? const Color(0xFF333333)
                : isSelected
                ? const Color.fromARGB(255, 180, 176, 61)
                : const Color(0xFF3D6491),
            width: 1,
          ),
        ),
        child: Text(
          item.meaning,
          style: TextStyle(
            color: isDisabled ? const Color(0xFF555555) : Colors.white,
            fontSize: 14,
            decorationColor: const Color(0xFF555555),
          ),
        ),
      ),
    );
  }
}
