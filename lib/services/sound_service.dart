import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service for playing sound effects in the app
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  static const String _beepAsset = 'sfx/beep.mp3';
  static const String _finishedAsset = 'sfx/finished.mp3';
  static const String _silenceAsset = 'sfx/silence.mp3';

  /// Matches the session the voice guide sets up: play over the person's own
  /// music, and dip it briefly rather than stopping it. On iOS the audio
  /// session is shared by the whole app, so a different setting here would
  /// quietly change how the voice guide sounds too.
  static final AudioContext _effectsContext = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {
        AVAudioSessionOptions.mixWithOthers,
        AVAudioSessionOptions.duckOthers,
      },
    ),
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.gainTransientMayDuck,
    ),
  );

  /// The silent loop only keeps the app's audio alive in the background. It
  /// must not take audio focus on Android, or music would stay dipped for
  /// the whole workout.
  static final AudioContext _silenceContext = _effectsContext.copy(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.assistanceSonification,
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  AudioPlayer? _beepPlayer;
  AudioPlayer? _finishedPlayer;
  AudioPlayer? _silentPlayer;
  bool _enabled = true;
  bool _initialized = false;

  /// Initialize the sound service
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await AudioPlayer.global.setAudioContext(_effectsContext);
      // Separate players, so the finish sound never cuts off a beep.
      _beepPlayer = await _createPlayer(_effectsContext);
      _finishedPlayer = await _createPlayer(_effectsContext);
    } catch (e) {
      // Sound effects are optional; the workout must still run without them.
    }
  }

  Future<AudioPlayer> _createPlayer(AudioContext context) async {
    final player = AudioPlayer();
    await player.setPlayerMode(PlayerMode.lowLatency);
    await player.setReleaseMode(ReleaseMode.stop);
    await _applyPlayerContext(player, context);
    return player;
  }

  /// Only Android has per-player audio settings. iOS has one session for the
  /// whole app, already set in [init], and logs a warning on every attempt.
  Future<void> _applyPlayerContext(
    AudioPlayer player,
    AudioContext context,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await player.setAudioContext(context);
  }

  /// Set whether sound effects are enabled
  void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Play the beep sound
  Future<void> playBeep() => _play(_beepPlayer, _beepAsset, volume: 0.8);

  /// Play the finished sound when workout completes
  Future<void> playFinished() =>
      _play(_finishedPlayer, _finishedAsset, volume: 1.0);

  Future<void> _play(
    AudioPlayer? player,
    String asset, {
    required double volume,
  }) async {
    if (!_enabled || player == null) return;

    try {
      // Restart from the top if the previous play has not finished yet.
      await player.stop();
      await player.play(AssetSource(asset), volume: volume);
    } catch (e) {
      // Sound effects should fail silently during runtime.
    }
  }

  /// Start playing the silent audio loop to keep audio session alive in background
  Future<void> startSilentLoop() async {
    if (!_enabled || !_initialized) return;
    if (_silentPlayer != null) return;

    try {
      final player = AudioPlayer();
      _silentPlayer = player;
      await player.setReleaseMode(ReleaseMode.loop);
      await _applyPlayerContext(player, _silenceContext);
      await player.play(AssetSource(_silenceAsset), volume: 0.0);
    } catch (e) {
      // Fail silently
    }
  }

  /// Stop the silent audio loop
  Future<void> stopSilentLoop() async {
    final player = _silentPlayer;
    if (player == null) return;
    _silentPlayer = null;
    try {
      await player.dispose();
    } catch (e) {
      // Fail silently
    }
  }

  /// Dispose resources
  void dispose() {
    unawaited(stopSilentLoop());
    unawaited(_beepPlayer?.dispose());
    unawaited(_finishedPlayer?.dispose());
    _beepPlayer = null;
    _finishedPlayer = null;
    _initialized = false;
  }
}
