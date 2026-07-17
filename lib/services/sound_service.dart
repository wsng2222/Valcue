import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

/// Service for playing sound effects in the app
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  AudioCache? _audioCache;
  bool _enabled = true;
  bool _initialized = false;

  /// Initialize the sound service
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    // Initialize AudioCache with prefix pointing to assets/sfx/
    _audioCache = AudioCache(prefix: 'assets/sfx/');
  }

  /// Set whether sound effects are enabled
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Play the beep sound (with debounce to prevent rapid double plays)
  Future<void> playBeep() async {
    if (!_enabled || _audioCache == null) return;

    try {
      // Play the actual beep sound file with duckAudio: true to mix with background music
      await _audioCache!.play(
        'beep.mp3',
        mode: PlayerMode.LOW_LATENCY,
        volume: 0.8,
        duckAudio: true,
      );
    } catch (e) {
      // Sound effects should fail silently during runtime.
      return;
    }
  }

  /// Play the finished sound when workout completes
  Future<void> playFinished() async {
    if (!_enabled || _audioCache == null) return;

    try {
      // audioplayers 0.18.3 API: use AudioCache to play asset files
      await _audioCache!.play(
        'finished.mp3',
        mode: PlayerMode.LOW_LATENCY,
        volume: 1.3,
        duckAudio: true,
      );
    } catch (e) {
      // Silently fail if sound can't be played
      // (e.g., file not found, permission issues)
    }
  }

  AudioPlayer? _silentPlayer;

  /// Start playing the silent audio loop to keep audio session alive in background
  Future<void> startSilentLoop() async {
    if (!_enabled || _audioCache == null) return;
    if (_silentPlayer != null) return;

    try {
      _silentPlayer = await _audioCache!.loop(
        'silence.mp3',
        volume: 0.0,
      );
    } catch (e) {
      // Fail silently
    }
  }

  /// Stop the silent audio loop
  Future<void> stopSilentLoop() async {
    if (_silentPlayer == null) return;
    try {
      await _silentPlayer!.stop();
      _silentPlayer = null;
    } catch (e) {
      // Fail silently
    }
  }

  /// Dispose resources
  void dispose() {
    stopSilentLoop();
    _audioCache?.clearCache();
    _audioCache = null;
  }
}
