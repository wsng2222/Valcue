import 'package:flutter/foundation.dart';

/// Lightweight analytics hook.
/// No vendor dependency: logs to debug console.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  void logEvent(String name, [Map<String, Object?> params = const {}]) {
    debugPrint('[analytics] $name ${params.isEmpty ? '' : params}');
  }
}

