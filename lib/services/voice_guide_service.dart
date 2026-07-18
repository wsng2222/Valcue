import 'dart:async';
import 'dart:collection';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'number_speech.dart';

/// Production-grade Voice Guide service using system TTS (real-time).
///
/// Design goals:
/// - Never overlap: every speak request stops current speech first.
/// - No races: calls are serialized using a simple async mutex.
/// - Runtime locale switching supported.
/// - Text-level LRU caching + non-blocking prewarm for instant feel.
///
/// NOTE: Audio-file caching is intentionally NOT implemented because system TTS
/// output-to-file is not reliably supported cross-platform in Flutter without
/// hacks. The architecture keeps a clear single entrypoint so it can be added
/// later if a truly supported method becomes available.
class VoiceGuideService {
  VoiceGuideService._();

  static final VoiceGuideService instance = VoiceGuideService._();

  // Public API requires simple access (one service, simple methods).
  final FlutterTts _tts = FlutterTts();
  final _AsyncMutex _mutex = _AsyncMutex();
  final _AsyncMutex _initMutex = _AsyncMutex();
  final _LruCache<String, String> _textCache = _LruCache<String, String>(
    capacity: 512,
  );

  SharedPreferences? _prefs;
  Locale _locale = const Locale('en');
  bool _voiceEnabled = false;
  bool _initialized = false;
  int _stopGeneration = 0;

  // ---- Templates (11 languages) ----
  // Keys:
  // - countdown_left: "{n}초 남았습니다"
  // - speed: "속도 {x}"
  // - incline: "경사도 {x}%"
  // - rpm: "{n} RPM"
  // - level: "레벨 {n}"
  static const Map<String, Map<String, String>> _templates = {
    'en': {
      'countdown_left': '{n} seconds left',
      'speed': 'Speed {x}',
      'incline': 'Incline {x} percent',
      'rpm': '{n} RPM',
      'level': 'Level {n}',
    },
    'nl': {
      'countdown_left': 'Nog {n} seconden',
      'speed': 'Snelheid {x}',
      'incline': 'Helling {x} procent',
      'rpm': '{n} RPM',
      'level': 'Niveau {n}',
    },
    'nb': {
      'countdown_left': '{n} sekunder igjen',
      'speed': 'Hastighet {x}',
      'incline': 'Stigning {x} prosent',
      'rpm': '{n} RPM',
      'level': 'Nivå {n}',
    },
    'da': {
      'countdown_left': '{n} sekunder tilbage',
      'speed': 'Hastighed {x}',
      'incline': 'Hældning {x} procent',
      'rpm': '{n} RPM',
      'level': 'Niveau {n}',
    },
    'it': {
      'countdown_left': 'Mancano {n} secondi',
      'speed': 'Velocità {x}',
      'incline': 'Inclinazione {x} percento',
      'rpm': '{n} RPM',
      'level': 'Livello {n}',
    },
    'th': {
      'countdown_left': 'เหลืออีก {n} วินาที',
      'speed': 'ความเร็ว {x}',
      'incline': 'ความชัน {x} เปอร์เซ็นต์',
      'rpm': '{n} RPM',
      'level': 'ระดับ {n}',
    },
    'ko': {
      'countdown_left': '{n}초 남았습니다',
      'speed': '속도 {x}',
      'incline': '경사도 {x}%',
      'rpm': '{n} RPM',
      'level': '레벨 {n}',
    },
    'ja': {
      'countdown_left': '{n}秒残りです',
      'speed': '速度 {x}',
      'incline': '傾斜 {x}%',
      'rpm': '{n} RPM',
      'level': 'レベル {n}',
    },
    'zh': {
      'countdown_left': '还剩{n}秒',
      'speed': '速度 {x}',
      'incline': '坡度 {x}%',
      'rpm': '{n} RPM',
      'level': '等级 {n}',
    },
    'vi': {
      'countdown_left': 'Còn {n} giây',
      'speed': 'Tốc độ {x}',
      'incline': 'Độ dốc {x}%',
      'rpm': '{n} RPM',
      'level': 'Cấp {n}',
    },
    'ar': {
      'countdown_left': 'تبقّى {n} ثانية',
      'speed': 'السرعة {x}',
      'incline': 'الميل {x}%',
      'rpm': '{n} RPM',
      'level': 'المستوى {n}',
    },
    'de': {
      'countdown_left': 'Noch {n} Sekunden',
      'speed': 'Geschwindigkeit {x}',
      'incline': 'Steigung {x} %',
      'rpm': '{n} U/min',
      'level': 'Stufe {n}',
    },
    'fr': {
      'countdown_left': 'Il reste {n} secondes',
      'speed': 'Vitesse {x}',
      'incline': 'Inclinaison {x} %',
      'rpm': '{n} RPM',
      'level': 'Niveau {n}',
    },
    'es': {
      'countdown_left': 'Quedan {n} segundos',
      'speed': 'Velocidad {x}',
      'incline': 'Inclinación {x}%',
      'rpm': '{n} RPM',
      'level': 'Nivel {n}',
    },
    'pt': {
      'countdown_left': 'Faltam {n} segundos',
      'speed': 'Velocidade {x}',
      'incline': 'Inclinação {x}%',
      'rpm': '{n} RPM',
      'level': 'Nível {n}',
    },
    'ru': {
      'countdown_left': 'Осталось {n} секунд',
      'speed': 'Скорость {x}',
      'incline': 'Наклон {x}%',
      'rpm': '{n} об/мин',
      'level': 'Уровень {n}',
    },
  };

  // Map app locale -> likely supported TTS language tag(s).
  static const Map<String, List<String>> _ttsLanguageFallbacks = {
    'en': ['en-US', 'en-GB', 'en'],
    'ko': ['ko-KR', 'ko'],
    'ja': ['ja-JP', 'ja'],
    'zh': ['zh-CN', 'zh-TW', 'zh'],
    'vi': ['vi-VN', 'vi'],
    'ar': ['ar-SA', 'ar'],
    'de': ['de-DE', 'de'],
    'fr': ['fr-FR', 'fr'],
    'es': ['es-ES', 'es'],
    'pt': ['pt-PT', 'pt-BR', 'pt'],
    'ru': ['ru-RU', 'ru'],
    'nl': ['nl-NL', 'nl-BE', 'nl'],
    'nb': ['nb-NO', 'no-NO', 'nb', 'no'],
    'da': ['da-DK', 'da'],
    'it': ['it-IT', 'it'],
    'th': ['th-TH', 'th'],
  };

  // ---------------- Public API ----------------

  Future<void> init({
    required Locale locale,
    required bool voiceEnabled,
  }) async {
    await _initMutex.synchronized(() async {
      // Guard against double init (and race-y repeated calls).
      if (_initialized) {
        await setLocale(locale);
        await setVoiceEnabled(voiceEnabled);
        await _applyTtsSettings();
        return;
      }

      _prefs = await SharedPreferences.getInstance();

      // Configure TTS engine.
      await _safe(() async {
        final session = await AudioSession.instance;
        await session.configure(AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers |
                  AVAudioSessionCategoryOptions.mixWithOthers,
          androidAudioAttributes: const AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.assistant,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
        ));

        // iOS setup:
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.duckOthers,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.spokenAudio,
        );
        
        // iOS: awaitSpeakCompletion causes speech truncation issues
        await _tts.awaitSpeakCompletion(false);
      });

      _initialized = true;
      await setLocale(locale);
      await setVoiceEnabled(voiceEnabled);
      await _applyTtsSettings();

      if (_voiceEnabled) {
        _startPrewarm();
      }
    });
  }

  Future<void> _applyTtsSettings() async {
    await _safe(() async {
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
    });
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs?.setString('voice_guide.locale', locale.toLanguageTag());

    await _safe(() async {
      await _configureTtsLanguage(locale);
    });

    // Locale change affects templates/number formatting; keep cache,
    // but prewarm again for the new locale to avoid latency.
    if (_voiceEnabled) {
      _startPrewarm();
    }
  }

  Future<void> setVoiceEnabled(bool enabled) async {
    _voiceEnabled = enabled;
    await _prefs?.setBool('voice_guide.enabled', enabled);

    if (!enabled) {
      await stop();
      return;
    }

    _startPrewarm();
  }

  Future<void> speakCountdown(int seconds) async {
    await _speak(
      key: 'countdown_left',
      placeholders: {
        'n': seconds.toString(),
      },
      cacheKeySuffix: 'countdown:$seconds',
    );
  }

  Future<void> speakSpeed(double speed) async {
    final x = NumberSpeech.numberToSpeechString(
      _locale,
      speed,
      fixedFractionDigits: 1,
    );
    await _speak(
      key: 'speed',
      placeholders: {'x': x},
      cacheKeySuffix: 'speed:${speed.toStringAsFixed(1)}',
    );
  }

  Future<void> speakIncline(double incline) async {
    final x = NumberSpeech.numberToSpeechString(
      _locale,
      incline,
      fixedFractionDigits: 1,
    );
    await _speak(
      key: 'incline',
      placeholders: {'x': x},
      cacheKeySuffix: 'incline:${incline.toStringAsFixed(1)}',
    );
  }

  Future<void> speakRpm(int rpm) async {
    await _speak(
      key: 'rpm',
      placeholders: {'n': rpm.toString()},
      cacheKeySuffix: 'rpm:$rpm',
    );
  }

  Future<void> speakLevel(int level) async {
    await _speak(
      key: 'level',
      placeholders: {'n': level.toString()},
      cacheKeySuffix: 'level:$level',
    );
  }

  // Combined speeches for multiple parameters
  Future<void> speakSpeedAndIncline(double speed, double incline) async {
    final speedStr = NumberSpeech.numberToSpeechString(
      _locale,
      speed,
      fixedFractionDigits: 1,
    );
    final inclineStr = NumberSpeech.numberToSpeechString(
      _locale,
      incline,
      fixedFractionDigits: 1,
    );
    
    // Build combined text with a short pause between metrics.
    final lang = _resolveLanguageCode(_locale);
    final speedTemplate = _templates[lang]?['speed'] ?? _templates['en']!['speed'] ?? 'Speed {x}';
    final inclineTemplate = _templates[lang]?['incline'] ?? _templates['en']!['incline'] ?? 'Incline {x}%';
    
    final speedText = speedTemplate.replaceAll('{x}', speedStr);
    final inclineText = inclineTemplate.replaceAll('{x}', inclineStr);
    final combinedText = _joinWithShortPause(
      first: speedText,
      second: inclineText,
    );
    
    await _speakDirect(
      text: combinedText,
      cacheKeySuffix: 'speed_incline:${speed.toStringAsFixed(1)}_${incline.toStringAsFixed(1)}',
    );
  }

  Future<void> speakLevelAndRpm(int level, int rpm) async {
    final lang = _resolveLanguageCode(_locale);
    final levelTemplate = _templates[lang]?['level'] ?? _templates['en']!['level'] ?? 'Level {n}';
    final rpmTemplate = _templates[lang]?['rpm'] ?? _templates['en']!['rpm'] ?? '{n} RPM';
    
    final levelText = levelTemplate.replaceAll('{n}', level.toString());
    final rpmText = rpmTemplate.replaceAll('{n}', rpm.toString());
    final combinedText = _joinWithShortPause(
      first: levelText,
      second: rpmText,
    );
    
    await _speakDirect(
      text: combinedText,
      cacheKeySuffix: 'level_rpm:${level}_$rpm',
    );
  }

  Future<void> stop() async {
    // Stop must be immediate and must NOT wait on the speak mutex,
    // so that a new request can interrupt current speech instantly.
    _stopGeneration++;
    await _safe(() async {
      await _tts.stop();
    });
  }

  // ---------------- Internals ----------------

  Future<void> _speakDirect({
    required String text,
    required String cacheKeySuffix,
  }) async {
    if (!_voiceEnabled) return;
    if (!_initialized) return;

    final cacheKey = '${_locale.toLanguageTag()}|direct|$cacheKeySuffix';
    final cached = _textCache.get(cacheKey);
    final finalText = cached ?? text;
    _textCache.put(cacheKey, finalText);

    await _mutex.synchronized(() async {
      if (!_voiceEnabled) return;
      if (!_initialized) return;
      
      final gen = ++_stopGeneration;

      // Stop any current speech
      await _safe(() async {
        await _tts.stop();
      });

      // iOS: longer delay to ensure audio session is ready
      await Future.delayed(const Duration(milliseconds: 200));

      // Check again if we should still speak
      if (gen != _stopGeneration) return;
      if (!_voiceEnabled) return;

      await _safe(() async {
        if (gen != _stopGeneration) return;
        await _tts.speak(finalText);
      });
    });
  }

  /// Speak a custom raw text string
  Future<void> speakCustom(String text) async {
    if (!_voiceEnabled) return;
    if (!_initialized) return;

    await _mutex.synchronized(() async {
      if (!_voiceEnabled) return;
      if (!_initialized) return;
      
      final gen = ++_stopGeneration;

      await _safe(() async {
        await _tts.stop();
      });

      await Future.delayed(const Duration(milliseconds: 200));

      if (gen != _stopGeneration) return;
      if (!_voiceEnabled) return;

      await _safe(() async {
        if (gen != _stopGeneration) return;
        await _tts.speak(text);
      });
    });
  }

  Future<void> _speak({
    required String key,
    required Map<String, String> placeholders,
    required String cacheKeySuffix,
  }) async {
    if (!_voiceEnabled) return;
    if (!_initialized) return;

    final cacheKey = '${_locale.toLanguageTag()}|$key|$cacheKeySuffix';
    final cached = _textCache.get(cacheKey);
    final text = cached ?? _buildText(key, placeholders);
    _textCache.put(cacheKey, text);

    await _mutex.synchronized(() async {
      if (!_voiceEnabled) return;
      if (!_initialized) return;
      
      final gen = ++_stopGeneration;

      // Stop any current speech
      await _safe(() async {
        await _tts.stop();
      });

      // iOS: longer delay to ensure audio session is ready
      await Future.delayed(const Duration(milliseconds: 200));

      // Check again if we should still speak (another request may have come in)
      if (gen != _stopGeneration) return;
      if (!_voiceEnabled) return;

      await _safe(() async {
        // Final check before speaking
        if (gen != _stopGeneration) return;
        await _tts.speak(text);
      });
    });
  }

  String _buildText(String key, Map<String, String> placeholders) {
    final lang = _resolveLanguageCode(_locale);
    
    // Fallback logic
    String? template = _templates[lang]?[key];
    template ??= _templates['en']?[key];
    template ??= key;

    var out = template;
    placeholders.forEach((k, v) {
      out = out.replaceAll('{$k}', v);
    });
    return out;
  }

  String _joinWithShortPause({
    required String first,
    required String second,
  }) {
    final lang = _resolveLanguageCode(_locale);
    final separator = _shortPauseSeparator(lang);
    return '$first$separator$second';
  }

  String _shortPauseSeparator(String lang) {
    switch (lang) {
      case 'ja':
        return '、';
      case 'zh':
        return '，';
      case 'ar':
        return '، ';
      default:
        return ', ';
    }
  }

  String _resolveLanguageCode(Locale locale) {
    final code = locale.languageCode.toLowerCase();
    if (_templates.containsKey(code)) return code;
    return 'en';
  }

  Future<void> _configureTtsLanguage(Locale locale) async {
    final code = _resolveLanguageCode(locale);
    final candidates = _ttsLanguageFallbacks[code] ?? [code];

    for (final lang in candidates) {
      final ok = await _safeBool(() async {
        return await _tts.setLanguage(lang) as bool?;
      });
      if (ok == true) {
        return;
      }
    }

    // Last resort: try just languageCode.
    await _safe(() async {
      await _tts.setLanguage(locale.languageCode);
    });
  }

  void _startPrewarm() {
    // Fire-and-forget prewarm; never block UI.
    Future(() async {
      try {
        await _prewarmCommonPhrases();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[VoiceGuideService] prewarm failed: $e');
        }
      }
    });
  }

  Future<void> _prewarmCommonPhrases() async {
    if (!_voiceEnabled) return;

    final langTag = _locale.toLanguageTag();
    const batchSize = 25;
    int batchCount = 0;

    void put(String key, String suffix, Map<String, String> placeholders) {
      final cacheKey = '$langTag|$key|$suffix';
      if (_textCache.contains(cacheKey)) return;
      _textCache.put(cacheKey, _buildText(key, placeholders));
    }

    // Countdown: 30, 20, 10
    for (final s in const [30, 20, 10]) {
      put('countdown_left', 'countdown:$s', {'n': s.toString()});
      if (++batchCount % batchSize == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    // Speed 0.5..25.0 step 0.5
    for (int i = 1; i <= 50; i++) {
      final v = i * 0.5;
      final x = NumberSpeech.numberToSpeechString(
        _locale,
        v,
        fixedFractionDigits: 1,
      );
      put('speed', 'speed:${v.toStringAsFixed(1)}', {'x': x});
      if (++batchCount % batchSize == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    // Incline 0.5..15.0 step 0.5
    for (int i = 1; i <= 30; i++) {
      final v = i * 0.5;
      final x = NumberSpeech.numberToSpeechString(
        _locale,
        v,
        fixedFractionDigits: 1,
      );
      put('incline', 'incline:${v.toStringAsFixed(1)}', {'x': x});
      if (++batchCount % batchSize == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    // RPM 30..200 step 5
    for (int rpm = 30; rpm <= 200; rpm += 5) {
      put('rpm', 'rpm:$rpm', {'n': rpm.toString()});
      if (++batchCount % batchSize == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    // Level 1..20
    for (int level = 1; level <= 20; level++) {
      put('level', 'level:$level', {'n': level.toString()});
      if (++batchCount % batchSize == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }
  }

  Future<void> _safe(Future<void> Function() fn) async {
    try {
      await fn();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[VoiceGuideService] TTS error: $e');
      }
    }
  }

  Future<bool?> _safeBool(Future<bool?> Function() fn) async {
    try {
      return await fn();
    } catch (_) {
      return null;
    }
  }
}

/// Simple async mutex that serializes critical sections.
class _AsyncMutex {
  Future<void> _tail = Future.value();

  Future<T> synchronized<T>(Future<T> Function() action) async {
    final prev = _tail;
    final nextCompleter = Completer<void>();
    _tail = nextCompleter.future;

    await prev;
    try {
      return await action();
    } finally {
      nextCompleter.complete();
    }
  }
}

/// Small LRU cache for already-formatted TTS strings.
class _LruCache<K, V> {
  _LruCache({required this.capacity});

  final int capacity;
  final LinkedHashMap<K, V> _map = LinkedHashMap<K, V>();

  bool contains(K key) => _map.containsKey(key);

  V? get(K key) {
    final value = _map.remove(key);
    if (value == null) return null;
    // Re-insert to mark as recently used.
    _map[key] = value;
    return value;
  }

  void put(K key, V value) {
    if (_map.containsKey(key)) {
      _map.remove(key);
    }
    _map[key] = value;

    if (_map.length > capacity) {
      _map.remove(_map.keys.first);
    }
  }
}
