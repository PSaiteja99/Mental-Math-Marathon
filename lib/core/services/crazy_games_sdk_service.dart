import 'dart:async';
import 'dart:js_interop';

@JS('CrazyGames.SDK')
external JSObject? get _crazySdk;

@JS('CrazyGames.SDK.init')
external JSPromise<JSAny?> _sdkInit();

@JS('CrazyGames.SDK.game.gameLoadingStart')
external void _gameLoadingStart();

@JS('CrazyGames.SDK.game.gameLoadingStop')
external void _gameLoadingStop();

@JS('CrazyGames.SDK.game.gameplayStart')
external void _gameplayStart();

@JS('CrazyGames.SDK.game.gameplayStop')
external void _gameplayStop();

@JS('CrazyGames.SDK.game.happyTime')
external void _happyTime();

@JS('CrazyGames.SDK.ad.requestAd')
external JSPromise<JSAny?> _requestAd(String type);

@JS('CrazyGames.SDK.social.requestInviteUrl')
external JSPromise<JSString?> _requestInviteUrl();

@JS('CrazyGames.SDK.sound.mute')
external void _soundMute();

@JS('CrazyGames.SDK.sound.unmute')
external void _soundUnmute();

@JS('CrazyGames.SDK.sound.getMute')
external bool _soundGetMute();

class CrazyGamesSdkService {
  CrazyGamesSdkService._();
  static final CrazyGamesSdkService instance = CrazyGamesSdkService._();

  bool _initialized = false;

  bool get isAvailable => _crazySdk != null;

  Future<void> init() async {
    if (!isAvailable || _initialized) return;
    try {
      await _sdkInit().toDart;
      _initialized = true;
    } catch (_) {}
  }

  void gameLoadingStart() {
    if (!isAvailable) return;
    try { _gameLoadingStart(); } catch (_) {}
  }

  void gameLoadingStop() {
    if (!isAvailable) return;
    try { _gameLoadingStop(); } catch (_) {}
  }

  void gameplayStart() {
    if (!isAvailable) return;
    try { _gameplayStart(); } catch (_) {}
  }

  void gameplayStop() {
    if (!isAvailable) return;
    try { _gameplayStop(); } catch (_) {}
  }

  void happyTime() {
    if (!isAvailable) return;
    try { _happyTime(); } catch (_) {}
  }

  Future<bool> showMidgameAd() async {
    if (!isAvailable) return false;
    try {
      await _requestAd('midgame').toDart;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> showRewardedAd() async {
    if (!isAvailable) return false;
    try {
      await _requestAd('rewarded').toDart;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String?> requestInviteUrl() async {
    if (!isAvailable) return null;
    try {
      final result = await _requestInviteUrl().toDart;
      return result?.dartify() as String?;
    } catch (_) {
      return null;
    }
  }

  void muteAudio() {
    if (!isAvailable) return;
    try { _soundMute(); } catch (_) {}
  }

  void unmuteAudio() {
    if (!isAvailable) return;
    try { _soundUnmute(); } catch (_) {}
  }

  bool get isMuted {
    if (!isAvailable) return false;
    try { return _soundGetMute(); } catch (_) { return false; }
  }
}
