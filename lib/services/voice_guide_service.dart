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

  // ---- Templates (all supported languages) ----
  // Keys:
  // - countdown_left: "{n}초 남았습니다"
  // - speed: "속도 {x}"
  // - incline: "경사도 {x}%"
  // - rpm: "{n} RPM"
  // - level: "레벨 {n}"
  static const Map<String, Map<String, String>> _templates = {
    'en': {
      'speed': 'Speed {x} {unit}',
      'incline': 'Incline {x} percent',
      'rpm': '{n} revolutions per minute',
      'level': 'Level {n}',
    },
    'nl': {
      'speed': 'Snelheid {x} {unit}',
      'incline': 'Helling {x} procent',
      'rpm': '{n} omwentelingen per minuut',
      'level': 'Niveau {n}',
    },
    'nb': {
      'speed': 'Hastighet {x} {unit}',
      'incline': 'Stigning {x} prosent',
      'rpm': '{n} omdreininger per minutt',
      'level': 'Nivå {n}',
    },
    'da': {
      'speed': 'Hastighed {x} {unit}',
      'incline': 'Hældning {x} procent',
      'rpm': '{n} omdrejninger i minuttet',
      'level': 'Niveau {n}',
    },
    'it': {
      'speed': 'Velocità {x} {unit}',
      'incline': 'Inclinazione {x} percento',
      'rpm': '{n} giri al minuto',
      'level': 'Livello {n}',
    },
    'th': {
      'speed': 'ความเร็ว {x} {unit}',
      'incline': 'ความชัน {x} เปอร์เซ็นต์',
      'rpm': '{n} รอบต่อนาที',
      'level': 'ระดับ {n}',
    },
    'ko': {
      'speed': '시속 {x}{unit}',
      'incline': '경사도 {x}%',
      'rpm': '분당 {n}회전',
      'level': '레벨 {n}',
    },
    'ja': {
      'speed': '時速{x}{unit}',
      'incline': '傾斜 {x}%',
      'rpm': '1分あたり{n}回転',
      'level': 'レベル {n}',
    },
    'zh': {
      'speed': '时速{x}{unit}',
      'incline': '坡度 {x}%',
      'rpm': '每分钟{n}转',
      'level': '等级 {n}',
    },
    'vi': {
      'speed': 'Tốc độ {x} {unit}',
      'incline': 'Độ dốc {x}%',
      'rpm': '{n} vòng mỗi phút',
      'level': 'Cấp {n}',
    },
    'ar': {
      'speed': 'السرعة {x} {unit}',
      'incline': 'الميل {x} بالمئة',
      'rpm': '{n} دورة في الدقيقة',
      'level': 'المستوى {n}',
    },
    'de': {
      'speed': 'Geschwindigkeit {x} {unit}',
      'incline': 'Steigung {x} %',
      'rpm': '{n} Umdrehungen pro Minute',
      'level': 'Stufe {n}',
    },
    'fr': {
      'speed': 'Vitesse {x} {unit}',
      'incline': 'Inclinaison {x} pour cent',
      'rpm': '{n} tours par minute',
      'level': 'Niveau {n}',
    },
    'es': {
      'speed': 'Velocidad {x} {unit}',
      'incline': 'Inclinación {x} por ciento',
      'rpm': '{n} revoluciones por minuto',
      'level': 'Nivel {n}',
    },
    'pt': {
      'speed': 'Velocidade {x} {unit}',
      'incline': 'Inclinação {x} por cento',
      'rpm': '{n} rotações por minuto',
      'level': 'Nível {n}',
    },
    'ru': {
      'speed': 'Скорость {x} {unit}',
      'incline': 'Наклон {x} процентов',
      'rpm': '{n} оборотов в минуту',
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
    'pt': ['pt-BR', 'pt-PT', 'pt'],
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
          androidAudioFocusGainType:
              AndroidAudioFocusGainType.gainTransientMayDuck,
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
    await _speakDirect(
      text: _countdownText(seconds),
      cacheKeySuffix: 'countdown:$seconds',
    );
  }

  Future<void> speakSpeed(
    double speed, {
    String measurement = 'kmh',
  }) async {
    final x = NumberSpeech.numberToSpeechString(
      _locale,
      speed,
      fixedFractionDigits: 1,
    );
    await _speak(
      key: 'speed',
      placeholders: {
        'x': x,
        'unit': _speedUnit(
          _resolveLanguageCode(_locale),
          measurement,
          speed,
        ),
      },
      cacheKeySuffix: 'speed:$measurement:${speed.toStringAsFixed(1)}',
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
    final value = NumberSpeech.numberToSpeechString(_locale, rpm);
    await _speak(
      key: 'rpm',
      placeholders: {'n': value},
      cacheKeySuffix: 'rpm:$rpm',
    );
  }

  Future<void> speakLevel(int level) async {
    final value = NumberSpeech.numberToSpeechString(_locale, level);
    await _speak(
      key: 'level',
      placeholders: {'n': value},
      cacheKeySuffix: 'level:$level',
    );
  }

  // Combined speeches for multiple parameters
  Future<void> speakSpeedAndIncline(
    double speed,
    double incline, {
    String measurement = 'kmh',
  }) async {
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
    final speedTemplate =
        _templates[lang]?['speed'] ?? _templates['en']!['speed'] ?? 'Speed {x}';
    final inclineTemplate = _templates[lang]?['incline'] ??
        _templates['en']!['incline'] ??
        'Incline {x}%';

    final speedText = speedTemplate
        .replaceAll('{x}', speedStr)
        .replaceAll('{unit}', _speedUnit(lang, measurement, speed));
    final inclineText = inclineTemplate.replaceAll('{x}', inclineStr);
    final combinedText = _joinWithShortPause(
      first: speedText,
      second: inclineText,
    );

    await _speakDirect(
      text: combinedText,
      cacheKeySuffix:
          'speed_incline:$measurement:${speed.toStringAsFixed(1)}_${incline.toStringAsFixed(1)}',
    );
  }

  Future<void> speakLevelAndRpm(int level, int rpm) async {
    final lang = _resolveLanguageCode(_locale);
    final levelTemplate =
        _templates[lang]?['level'] ?? _templates['en']!['level'] ?? 'Level {n}';
    final rpmTemplate =
        _templates[lang]?['rpm'] ?? _templates['en']!['rpm'] ?? '{n} RPM';

    final levelText = levelTemplate.replaceAll(
      '{n}',
      NumberSpeech.numberToSpeechString(_locale, level),
    );
    final rpmText = rpmTemplate.replaceAll(
      '{n}',
      NumberSpeech.numberToSpeechString(_locale, rpm),
    );
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

  String _countdownText(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final lang = _resolveLanguageCode(_locale);
    final n = NumberSpeech.numberToSpeechString(_locale, safeSeconds);
    switch (lang) {
      case 'ko':
        return '$n초 남았습니다';
      case 'ja':
        return '残り$n秒です';
      case 'zh':
        return '还剩$n秒';
      case 'vi':
        return 'Còn $n giây';
      case 'th':
        return 'เหลืออีก $n วินาที';
      case 'ar':
        if (safeSeconds == 1) return 'تبقّت ثانية واحدة';
        if (safeSeconds == 2) return 'تبقّت ثانيتان';
        final lastTwo = safeSeconds % 100;
        if (lastTwo >= 3 && lastTwo <= 10) return 'تبقّت $n ثوانٍ';
        return 'تبقّت $n ثانية';
      case 'ru':
        final lastTwo = safeSeconds % 100;
        final last = safeSeconds % 10;
        if (lastTwo < 11 || lastTwo > 14) {
          if (last == 1) return 'Осталась $n секунда';
          if (last >= 2 && last <= 4) return 'Осталось $n секунды';
        }
        return 'Осталось $n секунд';
      case 'es':
        return safeSeconds == 1 ? 'Queda 1 segundo' : 'Quedan $n segundos';
      case 'pt':
        return safeSeconds == 1 ? 'Falta 1 segundo' : 'Faltam $n segundos';
      case 'it':
        return safeSeconds == 1 ? 'Manca 1 secondo' : 'Mancano $n secondi';
      case 'fr':
        return safeSeconds == 1
            ? 'Il reste une seconde'
            : 'Il reste $n secondes';
      case 'de':
        return safeSeconds == 1 ? 'Noch eine Sekunde' : 'Noch $n Sekunden';
      case 'nl':
        return safeSeconds == 1 ? 'Nog één seconde' : 'Nog $n seconden';
      case 'nb':
        return safeSeconds == 1 ? '1 sekund igjen' : '$n sekunder igjen';
      case 'da':
        return safeSeconds == 1 ? '1 sekund tilbage' : '$n sekunder tilbage';
      default:
        return safeSeconds == 1 ? '1 second left' : '$n seconds left';
    }
  }

  String _speedUnit(String lang, String measurement, num speed) {
    final usesMiles = measurement == 'mph';
    final isOne = speed.abs() == 1;
    switch (lang) {
      case 'ko':
        return usesMiles ? '마일' : '킬로미터';
      case 'ja':
        return usesMiles ? 'マイル' : 'キロメートル';
      case 'zh':
        return usesMiles ? '英里' : '公里';
      case 'vi':
        return usesMiles ? 'dặm mỗi giờ' : 'ki-lô-mét mỗi giờ';
      case 'th':
        return usesMiles ? 'ไมล์ต่อชั่วโมง' : 'กิโลเมตรต่อชั่วโมง';
      case 'ar':
        return usesMiles ? 'ميلًا في الساعة' : 'كيلومترًا في الساعة';
      case 'ru':
        return _russianSpeedUnit(usesMiles, speed);
      case 'es':
        return usesMiles
            ? '${isOne ? 'milla' : 'millas'} por hora'
            : '${isOne ? 'kilómetro' : 'kilómetros'} por hora';
      case 'pt':
        return usesMiles
            ? '${isOne ? 'milha' : 'milhas'} por hora'
            : '${isOne ? 'quilômetro' : 'quilômetros'} por hora';
      case 'it':
        return usesMiles
            ? '${isOne ? 'miglio' : 'miglia'} orarie'
            : '${isOne ? 'chilometro' : 'chilometri'} orari';
      case 'fr':
        return usesMiles
            ? '${isOne ? 'mile' : 'miles'} par heure'
            : '${isOne ? 'kilomètre' : 'kilomètres'} par heure';
      case 'de':
        return usesMiles
            ? '${isOne ? 'Meile' : 'Meilen'} pro Stunde'
            : 'Kilometer pro Stunde';
      case 'nl':
        return usesMiles ? 'mijl per uur' : 'kilometer per uur';
      case 'nb':
        return usesMiles ? 'miles per time' : 'kilometer i timen';
      case 'da':
        return usesMiles ? 'miles i timen' : 'kilometer i timen';
      default:
        return usesMiles
            ? '${isOne ? 'mile' : 'miles'} per hour'
            : '${isOne ? 'kilometer' : 'kilometers'} per hour';
    }
  }

  String _russianSpeedUnit(bool usesMiles, num speed) {
    if (speed != speed.roundToDouble()) {
      return usesMiles ? 'мили в час' : 'километра в час';
    }
    final value = speed.abs().round();
    final lastTwo = value % 100;
    final last = value % 10;
    if (lastTwo < 11 || lastTwo > 14) {
      if (last == 1) return usesMiles ? 'миля в час' : 'километр в час';
      if (last >= 2 && last <= 4) {
        return usesMiles ? 'мили в час' : 'километра в час';
      }
    }
    return usesMiles ? 'миль в час' : 'километров в час';
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
      _textCache.put(
        '$langTag|direct|countdown:$s',
        _countdownText(s),
      );
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
      for (final measurement in const ['kmh', 'mph']) {
        put(
          'speed',
          'speed:$measurement:${v.toStringAsFixed(1)}',
          {
            'x': x,
            'unit': _speedUnit(
              _resolveLanguageCode(_locale),
              measurement,
              v,
            ),
          },
        );
        if (++batchCount % batchSize == 0) {
          await Future<void>.delayed(Duration.zero);
        }
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
      put(
        'rpm',
        'rpm:$rpm',
        {'n': NumberSpeech.numberToSpeechString(_locale, rpm)},
      );
      if (++batchCount % batchSize == 0) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    // Level 1..20
    for (int level = 1; level <= 20; level++) {
      put(
        'level',
        'level:$level',
        {'n': NumberSpeech.numberToSpeechString(_locale, level)},
      );
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
