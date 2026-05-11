import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  int _score = 0;
  int _lives = 3;
  String? _selectedMeaning;
  final Set<String> _disabledMeanings = {};

  int get score => _score;
  int get lives => _lives;
  String? get selectedMeaning => _selectedMeaning;
  Set<String> get disabledMeanings => Set.unmodifiable(_disabledMeanings);
  bool get isGameOver => _lives <= 0;

  void selectMeaning(String meaning) {
    if (_disabledMeanings.contains(meaning)) return;
    _selectedMeaning = _selectedMeaning == meaning ? null : meaning;
    notifyListeners();
  }

  void onCorrectMatch(String meaning) {
    _score++;
    _disabledMeanings.add(meaning);
    _selectedMeaning = null;
    notifyListeners();
  }

  void loseLife() {
    if (_lives <= 0) return;
    _lives--;
    notifyListeners();
  }

  void reset() {
    _score = 0;
    _lives = 3;
    _selectedMeaning = null;
    _disabledMeanings.clear();
    notifyListeners();
  }
}