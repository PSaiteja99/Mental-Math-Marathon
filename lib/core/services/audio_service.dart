import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioService {
  final AudioPlayer _effectPlayer;
  final AudioPlayer _musicPlayer;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  String? _currentMusicPath;
  bool _disposed = false;

  AudioService()
      : _effectPlayer = AudioPlayer(),
        _musicPlayer = AudioPlayer();

  final _initCtx = AudioContext(
    android: AudioContextAndroid(
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      usageType: AndroidUsageType.game,
      contentType: AndroidContentType.sonification,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: {AVAudioSessionOptions.mixWithOthers},
    ),
  );

  bool _playersReady = false;

  Future<void> _ensurePlayers() async {
    if (_playersReady) return;
    _playersReady = true;
    await _effectPlayer.setAudioContext(_initCtx);
    await _musicPlayer.setAudioContext(_initCtx);
  }

  void playCorrect() => _playEffect('sounds/correct.wav');
  void playWrong() => _playEffect('sounds/wrong.wav');
  void playClick() => _playEffect('sounds/sound/click.wav');
  void playCountdown() => _playEffect('sounds/countdown.wav');
  void playStart() => _playEffect('sounds/soundshelfstudio-ui-app-notification-524745.wav');
  void playHome() => _playEffect('sounds/sound/home.wav');
  void playStatistics() => _playEffect('sounds/sound/statistics.wav');
  void playAchievements() => _playEffect('sounds/sound/acheivements.wav');
  void playSettings() => _playEffect('sounds/sound/settings.wav');
  void playToggle() => _playEffect('sounds/sound/toggle.wav');
  void playPause() => _playEffect('sounds/deltarune_weird_route_sound.wav');
  void playWin() => _playEffect('sounds/sound/win.wav');
  void playKeepPracticing() => _playEffect('sounds/sound/keep_practicing.wav');
  void playLevelUp() => _playEffect('sounds/sound/level_up.wav');
  void playCompletedAchievement() => _playEffect('sounds/sound/completed_acheivement.wav');
  void playPendingAchievement() => _playEffect('sounds/sound/pending_achievemnt.wav');
  void playRecentSessions() => _playEffect('sounds/sound/recent_sessions.wav');
  void playProgress() => _playEffect('sounds/sound/progress.wav');
  void playStatisticsCards() => _playEffect('sounds/sound/statistics_cards.wav');

  static const _boxingTapSounds = [
    'sounds/sound/0.wav',
    'sounds/sound/1.wav',
    'sounds/sound/2.wav',
    'sounds/sound/3.wav',
    'sounds/sound/4.wav',
    'sounds/sound/8.wav',
    'sounds/sound/9.wav',
    'sounds/sound/15.wav',
    'sounds/sound/20.wav',
    'sounds/sound/42.wav',
    'sounds/sound/69.wav',
  ];

  Future<void> playRandomBoxingTapSound() async {
    if (!_soundEnabled) return;
    final path = _boxingTapSounds[Random().nextInt(_boxingTapSounds.length)];
    try {
      await _ensurePlayers();
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource(path));
    } catch (_) {}
  }

  Future<void> playMenuMusic() => _playMusic('sounds/MENU.mp3');
  Future<void> playGameMusic() => _playMusic('sounds/BGM1.mp3');
  Future<void> playResultMusic() => _playMusic('sounds/BGM2.mp3');

  Future<void> _playEffect(String path) async {
    if (!_soundEnabled) return;
    try {
      await _ensurePlayers();
      await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource(path));
    } catch (_) {}
  }

  Future<void> _playMusic(String path) async {
    if (!_musicEnabled || _disposed) return;
    if (_currentMusicPath == path && _musicPlayer.state == PlayerState.playing) return;
    if (_currentMusicPath == path && _musicPlayer.state == PlayerState.paused) {
      await _musicPlayer.resume();
      return;
    }
    _currentMusicPath = path;
    try {
      await _ensurePlayers();
      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      if (!_musicEnabled || _disposed) return;
      await _musicPlayer.play(AssetSource(path));
    } catch (_) {}
  }

  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    try {
      await _musicPlayer.resume();
    } catch (_) {}
  }

  Future<void> _stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
    _currentMusicPath = null;
  }

  void setEnabled(bool enabled) => _soundEnabled = enabled;

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (_musicEnabled) {
      _playMusic('sounds/MENU.mp3');
    } else {
      _stopMusic();
    }
  }

  bool get isEnabled => _soundEnabled;
  bool get isMusicEnabled => _musicEnabled;

  void dispose() {
    _disposed = true;
    _effectPlayer.dispose();
    _musicPlayer.dispose();
  }
}

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});
