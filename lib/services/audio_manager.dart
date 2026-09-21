import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager extends ChangeNotifier {
  static final AudioManager instance = AudioManager._internal();

  factory AudioManager() => instance;

  AudioManager._internal();

  /// Flag to disable audio calls in unit test environments
  static bool enableAudio = true;

  AudioPlayer? _bgmPlayer;
  AudioPlayer? _sfxDropPlayer;
  AudioPlayer? _sfxClearPlayer;
  AudioPlayer? _sfxRecordPlayer;
  bool _initialized = false;
  int _bgmPlayToken = 0;

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
  int _lastBgmIndex = -1;
  final Random _random = Random();

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundEnabled => _isSoundEnabled;

  void _ensureInitialized() {
    if (!enableAudio || _initialized) return;
    _initialized = true;

    try {
      // Configure global audio context so SFX and BGM mix smoothly without interrupting each other on Android/iOS
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ),
      );

      _bgmPlayer = AudioPlayer();
      _sfxDropPlayer = AudioPlayer();
      _sfxClearPlayer = AudioPlayer();
      _sfxRecordPlayer = AudioPlayer();

      // Configure BGM Player
      _bgmPlayer?.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );

      // Configure SFX Players to not steal audio focus
      final sfxContext = AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      );

      _sfxDropPlayer?.setAudioContext(sfxContext);
      _sfxClearPlayer?.setAudioContext(sfxContext);
      _sfxRecordPlayer?.setAudioContext(sfxContext);

      // On completion, wait 5 seconds of silence before playing next BGM
      _bgmPlayer?.onPlayerComplete.listen((_) {
        _onBgmTrackFinished();
      });

      _sfxDropPlayer?.setReleaseMode(ReleaseMode.stop).catchError((_) {});
      _sfxClearPlayer?.setReleaseMode(ReleaseMode.stop).catchError((_) {});
      _sfxRecordPlayer?.setReleaseMode(ReleaseMode.stop).catchError((_) {});
    } catch (e) {
      debugPrint('AudioManager init warning: $e');
    }
  }

  void _onBgmTrackFinished() async {
    final currentToken = ++_bgmPlayToken;
    // 5 seconds of silence between tracks
    await Future.delayed(const Duration(seconds: 5));
    if (_isMusicEnabled && _bgmPlayToken == currentToken) {
      await playNextRandomBgm();
    }
  }

  /// Ensures BGM is actively playing; unlocks and resumes on user gesture
  Future<void> ensureBgmPlaying() async {
    if (!enableAudio || !_isMusicEnabled) return;
    _ensureInitialized();

    try {
      final state = _bgmPlayer?.state;
      if (state == PlayerState.playing) {
        return;
      } else if (state == PlayerState.paused) {
        await _bgmPlayer?.resume().catchError((_) {});
      } else {
        await playNextRandomBgm();
      }
    } catch (e) {
      debugPrint('AudioManager ensureBgmPlaying error: $e');
    }
  }

  /// Starts background music playback
  Future<void> startBgm() async {
    await ensureBgmPlaying();
  }

  /// Picks a random track from the 5 BGM tracks and plays it
  Future<void> playNextRandomBgm() async {
    if (!enableAudio || !_isMusicEnabled) return;
    _ensureInitialized();

    try {
      _bgmPlayToken++;
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
      await _bgmPlayer?.stop().catchError((_) {});
      await _bgmPlayer?.setVolume(0.4).catchError((_) {});
      await _bgmPlayer?.play(AssetSource(track)).catchError((e) {
        debugPrint('BGM play error (possibly awaiting user gesture): $e');
      });
    } catch (e) {
      debugPrint('AudioManager playNextRandomBgm error: $e');
    }
  }

  /// Toggle background music ON / OFF
  void toggleMusic() {
    _isMusicEnabled = !_isMusicEnabled;
    _bgmPlayToken++;
    if (_isMusicEnabled) {
      ensureBgmPlaying();
    } else {
      _bgmPlayer?.pause().catchError((_) {});
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
    if (!enableAudio || !_isSoundEnabled) return;
    _ensureInitialized();
    try {
      _sfxDropPlayer?.stop().catchError((_) {});
      _sfxDropPlayer?.setVolume(0.85).catchError((_) {});
      _sfxDropPlayer?.play(AssetSource('sound/drop.wav')).catchError((_) {});
    } catch (e) {
      debugPrint('AudioManager playDrop error: $e');
    }
  }

  /// Play line clear sound (clear.wav)
  void playClear() {
    if (!enableAudio || !_isSoundEnabled) return;
    _ensureInitialized();
    try {
      _sfxClearPlayer?.stop().catchError((_) {});
      _sfxClearPlayer?.setVolume(1.0).catchError((_) {});
      _sfxClearPlayer?.play(AssetSource('sound/clear.wav')).catchError((_) {});
    } catch (e) {
      debugPrint('AudioManager playClear error: $e');
    }
  }

  /// Play new high score record fanfare (newrecord.mp3)
  void playNewRecord() {
    if (!enableAudio || !_isSoundEnabled) return;
    _ensureInitialized();
    try {
      _sfxRecordPlayer?.stop().catchError((_) {});
      _sfxRecordPlayer?.setVolume(1.0).catchError((_) {});
      _sfxRecordPlayer?.play(AssetSource('soundtrack/newrecord.mp3')).catchError((e) {
        debugPrint('AudioManager playNewRecord error: $e');
      });
    } catch (e) {
      debugPrint('AudioManager playNewRecord error: $e');
    }
  }

  @override
  void dispose() {
    _bgmPlayer?.dispose().catchError((_) {});
    _sfxDropPlayer?.dispose().catchError((_) {});
    _sfxClearPlayer?.dispose().catchError((_) {});
    _sfxRecordPlayer?.dispose().catchError((_) {});
    super.dispose();
  }
}
