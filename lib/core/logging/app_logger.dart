import 'package:flutter/foundation.dart';

/// Small logging boundary that deliberately never serializes arbitrary
/// payloads. Callers pass a safe, already-redacted message only.
class AppLogger {
  const AppLogger({this.enabled = kDebugMode});

  final bool enabled;

  void info(String message) {
    if (enabled) debugPrint('[MacroMate] $message');
  }

  void warning(String message) {
    if (enabled) debugPrint('[MacroMate][warning] $message');
  }

  void error(String operation, Object error) {
    if (enabled) debugPrint('[MacroMate][$operation] ${_safeError(error)}');
  }

  String _safeError(Object error) {
    final text = error.toString();
    // Keep plugin/database diagnostics useful without leaking common secret
    // fields or complete backup/health payloads into logs.
    return text
        .replaceAll(
          RegExp(
            r'(password|token|secret|api[_-]?key)\s*[:=]\s*[^,; ]+',
            caseSensitive: false,
          ),
          '[redacted]',
        )
        .replaceAll(RegExp(r'\{[^}]{200,}\}'), '{payload redacted}');
  }
}
