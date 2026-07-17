import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Lazily initializes the Firebase services used only by remote Live Activity
/// updates.
///
/// The rest of Valcue deliberately remains independent from Firebase. A build
/// without the required `--dart-define` values keeps the phase-one local
/// notification and ActivityKit behavior, while a configured iOS build can
/// upload its complete interval schedule to the phase-two backend.
class WorkoutLiveActivityFirebaseRuntime {
  WorkoutLiveActivityFirebaseRuntime._();

  static final WorkoutLiveActivityFirebaseRuntime instance =
      WorkoutLiveActivityFirebaseRuntime._();

  static const bool _remoteUpdatesEnabled = bool.fromEnvironment(
    'VALCUE_LIVE_ACTIVITY_REMOTE_ENABLED',
    defaultValue: false,
  );
  static const bool _debugAppCheck = bool.fromEnvironment(
    'VALCUE_FIREBASE_APP_CHECK_DEBUG',
    defaultValue: false,
  );
  static const String _apiKey = String.fromEnvironment(
    'VALCUE_FIREBASE_API_KEY',
  );
  static const String _appId = String.fromEnvironment(
    'VALCUE_FIREBASE_APP_ID',
  );
  static const String _messagingSenderId = String.fromEnvironment(
    'VALCUE_FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String _projectId = String.fromEnvironment(
    'VALCUE_FIREBASE_PROJECT_ID',
  );
  static const String _iosBundleId = String.fromEnvironment(
    'VALCUE_FIREBASE_IOS_BUNDLE_ID',
    defaultValue: 'com.nogic.valcue',
  );
  static const String functionsRegion = String.fromEnvironment(
    'VALCUE_FIREBASE_FUNCTIONS_REGION',
    defaultValue: 'asia-northeast3',
  );

  Future<FirebaseFunctions?>? _initializing;

  /// Returns true if the app is built with valid Firebase configuration variables.
  bool get isFirebaseAvailable {
    return !kIsWeb &&
        _apiKey.isNotEmpty &&
        _appId.isNotEmpty &&
        _messagingSenderId.isNotEmpty &&
        _projectId.isNotEmpty;
  }

  /// Whether remote Live Activity updates are supported on this device.
  bool get isConfigured {
    return _remoteUpdatesEnabled &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.iOS &&
        isFirebaseAvailable;
  }

  /// Returns `null` when phase-two remote updates are intentionally disabled.
  /// Initialization failures are allowed to propagate to the schedule backend,
  /// which treats them as retryable without interrupting the active workout.
  Future<FirebaseFunctions?> functions() {
    if (!isFirebaseAvailable) return Future<FirebaseFunctions?>.value();

    final pending = _initializing;
    if (pending != null) return pending;

    final initializing = _initialize();
    _initializing = initializing;
    return initializing.catchError((Object error, StackTrace stackTrace) {
      _initializing = null;
      Error.throwWithStackTrace(error, stackTrace);
    });
  }

  Future<FirebaseFunctions?> _initialize() async {
    final FirebaseApp app;
    if (Firebase.apps.isEmpty) {
      app = await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: _apiKey,
          appId: _appId,
          messagingSenderId: _messagingSenderId,
          projectId: _projectId,
          iosBundleId: _iosBundleId,
        ),
      );
    } else {
      app = Firebase.app();
    }

    final appCheck = FirebaseAppCheck.instanceFor(app: app);
    await appCheck.activate(
      providerApple: _debugAppCheck
          ? const AppleDebugProvider()
          : const AppleAppAttestWithDeviceCheckFallbackProvider(),
      providerAndroid: _debugAppCheck
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
    );
    await appCheck.setTokenAutoRefreshEnabled(true);

    final auth = FirebaseAuth.instanceFor(app: app);
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }

    return FirebaseFunctions.instanceFor(
      app: app,
      region: functionsRegion,
    );
  }
}
