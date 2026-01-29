import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:interval_cardio/l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app_shell/app_shell.dart';
import 'app_settings/app_settings_provider.dart';
import 'features/routines/storage/routine_provider.dart';
import 'features/profile/providers/workout_history_provider.dart';
import 'features/profile/providers/weight_tracker_provider.dart';
import 'theme/app_theme.dart';
import 'services/sound_service.dart';
import 'services/ad_service.dart';
import 'services/voice_guide_service.dart';
import 'onboarding/onboarding_flow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide Android system navigation bar with maximum intensity
  const platform = MethodChannel('com.interval_cardio/system');
  try {
    await platform.invokeMethod('hideSystemUI');
  } catch (e) {
    debugPrint('Failed to hide system UI via platform channel: $e');
  }

  // Flutter-side backup: Hide Android system navigation bar completely
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize sound service
  await SoundService().init();

  // Initialize Google Mobile Ads (with error handling)
  try {
    debugPrint('Initializing Google Mobile Ads...');
    await MobileAds.instance.initialize();
    debugPrint('Google Mobile Ads initialized successfully');
    // Preload interstitial ad for workout start
    debugPrint('Preloading interstitial ad...');
    AdService().loadAd();
  } catch (e) {
    // If ad initialization fails, app should still work
    // Ads are optional for testing
    debugPrint('Ad initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => RoutineProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutHistoryProvider()),
        ChangeNotifierProvider(create: (_) => WeightTrackerProvider()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Interval Cardio',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeModeEnum,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('es'),
              Locale('fr'),
              Locale('de'),
              Locale('it'),
              Locale('nl'),
              Locale('da'),
              Locale('nb'),
              Locale('ru'),
              Locale('pt'),
              Locale('ja'),
              Locale('zh'),
              Locale('ko'),
              Locale('vi'),
              Locale('ar'),
              Locale('th'),
            ],
            locale: settingsProvider.locale,
            builder: (context, child) {
              // IMPORTANT: This builder runs under Localizations, so we can safely
              // read locale and react to runtime changes.
              return _VoiceGuideBootstrap(
                voiceEnabled: settingsProvider.voiceGuideEnabled,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: OnboardingGate(
              home: AppShell(key: AppShell.globalKey),
            ),
          );
        },
      ),
    );
  }
}

/// Bootstraps VoiceGuideService and keeps it in sync with:
/// - runtime locale switching
/// - settings toggle (voiceEnabled)
class _VoiceGuideBootstrap extends StatefulWidget {
  final bool voiceEnabled;
  final Widget child;

  const _VoiceGuideBootstrap({
    required this.voiceEnabled,
    required this.child,
  });

  @override
  State<_VoiceGuideBootstrap> createState() => _VoiceGuideBootstrapState();
}

class _VoiceGuideBootstrapState extends State<_VoiceGuideBootstrap> with WidgetsBindingObserver {
  Locale? _lastLocale;
  bool? _lastEnabled;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-hide navigation bar when app resumes
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
      // Also call platform method
      const platform = MethodChannel('com.interval_cardio/system');
      platform.invokeMethod('hideSystemUI').catchError((e) {
        debugPrint('Failed to hide system UI on resume: $e');
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _VoiceGuideBootstrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final enabled = widget.voiceEnabled;

    // Avoid redundant async calls on rebuilds.
    final localeChanged =
        _lastLocale?.toLanguageTag() != locale.toLanguageTag();
    final enabledChanged = _lastEnabled != enabled;

    if (_lastLocale == null || _lastEnabled == null) {
      _lastLocale = locale;
      _lastEnabled = enabled;
      // Fire-and-forget; service internally guards initialization.
      VoiceGuideService.instance.init(locale: locale, voiceEnabled: enabled);
      return;
    }

    if (localeChanged) {
      _lastLocale = locale;
      VoiceGuideService.instance.setLocale(locale);
    }
    if (enabledChanged) {
      _lastEnabled = enabled;
      VoiceGuideService.instance.setVoiceEnabled(enabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force hide navigation bar on every build
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    // Ensure navigation bar stays hidden every rebuild
    SchedulerBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    });
    return widget.child;
  }
}
