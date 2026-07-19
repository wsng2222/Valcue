import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Single analytics entry point for product events.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;

  Future<void> init() async {
    _analytics = FirebaseAnalytics.instance;
    await _analytics!.setAnalyticsCollectionEnabled(true);
  }

  void logEvent(String name, [Map<String, Object?> params = const {}]) {
    if (kDebugMode) {
      debugPrint('[analytics] $name ${params.isEmpty ? '' : params}');
    }

    final analytics = _analytics;
    if (analytics == null) return;

    final parameters = <String, Object>{
      for (final entry in params.entries)
        if (entry.value != null) entry.key: entry.value!,
      'build_type': kDebugMode ? 'debug' : 'release',
    };
    unawaited(_sendEvent(analytics, name, parameters));
  }

  Future<void> _sendEvent(
    FirebaseAnalytics analytics,
    String name,
    Map<String, Object> parameters,
  ) async {
    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[analytics] Failed to send $name: $error');
      }
    }
  }
}
