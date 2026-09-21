import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager extends ChangeNotifier {
  static final AudioManager instance = AudioManager._internal();

  factory AudioManager() => instance;

  AudioManager._internal();

  AudioPlayer? _bgmPlayer;
  AudioPlayer? _sfxDropPlayer;
  AudioPlayer? _sfxClearPlayer;
  AudioPlayer? _sfxRecordPlayer;
  bool _initialized = false;

  // Playlist of 5 background tracks
  static const List<String> bgmPlaylist = [
    'soundtrack/bgm1.mp3',
    'soundtrack/bgm2.mp3',
    'soundtrack/bgm3.mp3',
    'soundtrack/bgm4.mp3',
    'soundtrack/bgm5.mp3',
  ];

  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;
  bool _isBgmStarted = false;
  int _lastBgmIndex = -1;
  final Random _random = Random();

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEnabled => _isSoundEnabled;

  void _ensureInitialized() {
    if (_initialized) return;
    _initialized = true;

    try {
      _bgmPlayer = AudioPlayer();
      _sfxDropPlayer = AudioPlayer();
      _sfxClearPlayer = AudioPlayer();
      _sfxRecordPlayer = AudioPlayer();

      _bgmPlayer?.onPlayerComplete.listen((_) {
        if (_isMusicEnabled) {
          playNextRandomBgm();
        }
      });

      _sfxDropPlayer?.setReleaseMode(ReleaseMode.stop);
      _sfxClearPlayer?.setReleaseMode(ReleaseMode.stop);
      _sfxRecordPlayer?.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('AudioManager init warning: $e');
    }
  }

  /// Starts background music playback if not already playing
  Future<void> startBgm() async {
    if (!_isMusicEnabled || _isBgmStarted) return;
    _isBgmStarted = true;
    await playNextRandomBgm();
  }

  /// Picks a random track from the 5 BGM tracks and plays it
  Future<void> playNextRandomBgm() async {
    if (!_isMusicEnabled) return;
    _ensureInitialized();

    try {
      int nextIndex;
      if (bgmPlaylist.length > 1) {
        do {
          nextIndex = _random.nextInt(bgmPlaylist.length);
        } while (nextIndex == _lastBgmIndex);
      } else {
        nextIndex = 0;
      }
      _lastBgmIndex = nextIndex;

      final track = bgmPlaylist[nextIndex];
      await _bgmPlayer?.setVolume(0.4);
      await _bgmPlayer?.play(AssetSource(track));
    } catch (e) {
      debugPrint('AudioManager startBgm error: $e');
    }
  }

  /// Toggle background music ON / OFF
  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    if (_isMusicEnabled) {
      _isBgmStarted = true;
      playNextRandomBgm();
    } else {
      _bgmPlayer?.pause();
    }
    notifyListeners();
  }

  /// Toggle sound effects ON / OFF
  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    notifyListeners();
  }

  /// Play block placement sound (drop.wav)
  void playDrop() {
    if (!_isSoundEnabled) return;
    _ensureInitialized();
    try {
      _sfxDropPlayer?.stop();
      _sfxDropPlayer?.setVolume(0.85);
      _sfxDropPlayer?.play(AssetSource('sound/drop.wav'));
    } catch (e) {
      debugPrint('AudioManager playDrop error: $e');
    }
  }

  /// Play line clear sound (clear.wav)
  void playClear() {
    if (!_isSoundEnabled) return;
    _ensureInitialized();
    try {
      _sfxClearPlayer?.stop();
      _sfxClearPlayer?.setVolume(1.0);
      _sfxClearPlayer?.play(AssetSource('sound/clear.wav'));
    } catch (e) {
      debugPrint('AudioManager playClear error: $e');
    }
  }

  /// Play new high score record fanfare (newrecord.mp3)
  void playNewRecord() {
    if (!_isSoundEnabled) return;
    _ensureInitialized();
    try {
      _sfxRecordPlayer?.stop();
      _sfxRecordPlayer?.setVolume(1.0);
      _sfxRecordPlayer?.play(AssetSource('soundtrack/newrecord.mp3'));
    } catch (e) {
      debugPrint('AudioManager playNewRecord error: $e');
    }
  }

  @override
  void dispose() {
    _bgmPlayer?.dispose();
    _sfxDropPlayer?.dispose();
    _sfxClearPlayer?.dispose();
    _sfxRecordPlayer?.dispose();
    super.dispose();
  }
}
