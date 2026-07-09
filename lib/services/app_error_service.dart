import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/debug_log.dart';

class AppErrorReport {
  final DateTime occurredAt;
  final String source;
  final String message;
  final String stackTrace;
  final bool fatal;

  const AppErrorReport({
    required this.occurredAt,
    required this.source,
    required this.message,
    required this.stackTrace,
    required this.fatal,
  });

  Map<String, dynamic> toJson() {
    return {
      'occurredAt': occurredAt.toIso8601String(),
      'source': source,
      'message': message,
      'stackTrace': stackTrace,
      'fatal': fatal,
    };
  }

  factory AppErrorReport.fromJson(Map<String, dynamic> json) {
    return AppErrorReport(
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      source: json['source'] as String,
      message: json['message'] as String,
      stackTrace: json['stackTrace'] as String,
      fatal: json['fatal'] as bool? ?? false,
    );
  }
}

/// Best-effort local error capture for release debugging.
///
/// This does not replace a hosted crash reporting service, but it gives us a
/// persistent ring buffer of recent errors so crashes are easier to diagnose.
class AppErrorService {
  AppErrorService._();

  static final AppErrorService instance = AppErrorService._();

  static const String _storageKey = 'app_error_reports';
  static const int _maxReports = 20;
  static const int _maxMessageLength = 1000;
  static const int _maxStackLength = 4000;

  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {
    final context = details.context?.toDescription();
    final library = details.library;
    final exceptionText = details.exceptionAsString();
    final messageParts = <String>[
      if (library != null && library.isNotEmpty) 'library=$library',
      if (context != null && context.isNotEmpty) 'context=$context',
      exceptionText,
    ];

    await recordError(
      details.exception,
      details.stack ?? StackTrace.current,
      source: 'flutter',
      fatal: fatal,
      messageOverride: messageParts.join(' | '),
    );
  }

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    required String source,
    bool fatal = false,
    String? messageOverride,
  }) async {
    try {
      await init();
      final prefs = _prefs;
      if (prefs == null) return;

      final existing = _readReports(prefs);
      final report = AppErrorReport(
        occurredAt: DateTime.now(),
        source: source,
        message:
            _truncate(messageOverride ?? error.toString(), _maxMessageLength),
        stackTrace: _truncate(stackTrace.toString(), _maxStackLength),
        fatal: fatal,
      );

      final updated = <AppErrorReport>[report, ...existing];
      if (updated.length > _maxReports) {
        updated.removeRange(_maxReports, updated.length);
      }

      await prefs.setString(
        _storageKey,
        jsonEncode(updated.map((e) => e.toJson()).toList()),
      );
      debugLog(
        '[AppErrorService] Recorded ${fatal ? "fatal" : "non-fatal"} '
        'error from $source: ${report.message}',
      );
    } catch (e) {
      debugLog('[AppErrorService] Failed to persist error report: $e');
    }
  }

  Future<List<AppErrorReport>> loadReports() async {
    await init();
    final prefs = _prefs;
    if (prefs == null) return [];
    return _readReports(prefs);
  }

  Future<void> clearReports() async {
    await init();
    await _prefs?.remove(_storageKey);
  }

  List<AppErrorReport> _readReports(SharedPreferences prefs) {
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final reports = <AppErrorReport>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          reports.add(AppErrorReport.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {
          // Skip corrupted report items and keep the rest.
        }
      }
      return reports;
    } catch (e) {
      debugLog('[AppErrorService] Failed to decode stored reports: $e');
      return [];
    }
  }

  String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength)}...';
  }
}
