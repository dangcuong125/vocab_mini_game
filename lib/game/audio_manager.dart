import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._();
  factory AudioManager() => _instance;
  AudioManager._();

  final _bgm = AudioPlayer();
  bool _bgmPlaying = false;

  bool sfxEnabled = true;
  bool bgmEnabled = true;

  Future<void> startBgm() async {
    if (!bgmEnabled || _bgmPlaying) return;
    _bgmPlaying = true;
    await _bgm.setReleaseMode(ReleaseMode.loop);
    await _bgm.play(AssetSource('Sounds/ActionPhaseMusic.mp3'));
  }

  Future<void> stopBgm() async {
    _bgmPlaying = false;
    await _bgm.stop();
  }

  Future<void> setBgm(bool enabled) async {
    bgmEnabled = enabled;
    if (!enabled) {
      await stopBgm();
    } else {
      await startBgm();
    }
  }

  Future<void> playShoot() async {
    if (!sfxEnabled) return;
    final p = AudioPlayer();
    await p.play(AssetSource('Sounds/shoot_sound.mp3'));
    p.onPlayerComplete.listen((_) => p.dispose());
  }

  Future<void> playCorrect() async {
    if (!sfxEnabled) return;
    final p = AudioPlayer();
    await p.play(AssetSource('Sounds/Pick_correct_answer.wav'));
    p.onPlayerComplete.listen((_) => p.dispose());
  }

  Future<void> playWrong() async {
    if (!sfxEnabled) return;
    final p = AudioPlayer();
    await p.play(AssetSource('Sounds/pick_wrong_answer.wav'));
    p.onPlayerComplete.listen((_) => p.dispose());
  }

  Future<void> playWin() async {
    await stopBgm();
    if (!sfxEnabled) return;
    final p = AudioPlayer();
    await p.play(AssetSource('Sounds/GameLevelCompleted.wav'));
    p.onPlayerComplete.listen((_) => p.dispose());
  }

  Future<void> playLose() async {
    await stopBgm();
    if (!sfxEnabled) return;
    final p = AudioPlayer();
    await p.play(AssetSource('Sounds/GameLose.wav'));
    p.onPlayerComplete.listen((_) => p.dispose());
  }

  void dispose() {
    _bgm.dispose();
  }
}
