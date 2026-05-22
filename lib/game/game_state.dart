import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  int _score = 0;
  int _lives = 3;
  String? _selectedMeaning;
  final Set<String> _disabledMeanings = {};
  bool _isPaused = false;
  bool _isSfxOn = true;
  bool _isBgmOn = true;
  double _gunAngle = 0.0;
  bool muzzleFlash = false;

  int get score => _score;
  int get lives => _lives;
  String? get selectedMeaning => _selectedMeaning;
  Set<String> get disabledMeanings => Set.unmodifiable(_disabledMeanings);
  bool get isGameOver => _lives <= 0;
  bool get isPaused => _isPaused;
  bool get isSfxOn => _isSfxOn;
  bool get isBgmOn => _isBgmOn;
  double get gunAngle => _gunAngle;

  void setGunAngle(double angle) {
    _gunAngle = angle;
    notifyListeners();
  }

  void triggerMuzzleFlash() {
    muzzleFlash = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 350), () {
      muzzleFlash = false;
      notifyListeners();
    });
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void toggleSfx() {
    _isSfxOn = !_isSfxOn;
    notifyListeners();
  }

  void toggleBgm() {
    _isBgmOn = !_isBgmOn;
    notifyListeners();
  }

  void selectMeaning(String meaning) {
    if (_disabledMeanings.contains(meaning)) return;
    _selectedMeaning = _selectedMeaning == meaning ? null : meaning;
    notifyListeners();
  }

  void clearSelection() {
    _selectedMeaning = null;
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
    _isPaused = false;
    _gunAngle = 0.0;
    notifyListeners();
  }
}