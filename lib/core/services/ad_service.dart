import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'crazy_games_sdk_service.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  int _gameCount = 0;
  int _questionCount = 0;
  bool _initialBreakDone = false;

  bool adsEnabled = true;

  void onQuestionAnswered() {
    _questionCount++;
    if (_questionCount >= 8) {
      _questionCount = 0;
      _tryShowMidgame();
    }
  }

  void onGameEnded() {
    _gameCount++;
    _questionCount = 0;
  }

  Future<void> onGameStart() async {
    if (!_initialBreakDone && adsEnabled) {
      _initialBreakDone = true;
      await _tryShowMidgame();
    }
  }

  Future<void> onReturnHome() async {
    if (_gameCount > 0 && adsEnabled) {
      _gameCount = 0;
      await _tryShowMidgame();
    }
  }

  Future<bool> _tryShowMidgame() async {
    if (!adsEnabled) return false;
    return await CrazyGamesSdkService.instance.showMidgameAd();
  }

  Future<bool> showRewardedAd() async {
    if (!adsEnabled) return false;
    return await CrazyGamesSdkService.instance.showRewardedAd();
  }

  void happyTime() {
    CrazyGamesSdkService.instance.happyTime();
  }

  void reset() {
    _gameCount = 0;
    _questionCount = 0;
  }
}

final adServiceProvider = Provider<AdService>((ref) => AdService.instance);
