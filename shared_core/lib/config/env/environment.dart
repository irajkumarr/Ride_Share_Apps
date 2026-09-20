import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central access point for all runtime environment variables.
///
/// Values are loaded from the correct `.env.*` file during [main] bootstrap
/// and exposed as typed getters throughout the app.
///
/// Usage:
/// ```dart
/// final baseUrl = Environment.apiBaseUrl;
/// ```
class Environment {
  Environment._();

  // ── API ──────────────────────────────────────────────────────────────────

  /// Base URL for all REST API calls (e.g. `https://api.example.com/v1`).
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';

  /// Request timeout in seconds.
  static int get apiTimeoutSeconds =>
      int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '15') ?? 15;

  // ── Feature flags ─────────────────────────────────────────────────────────

  /// Toggle to enable verbose network logging (disabled in production).
  static bool get enableNetworkLogs =>
      (dotenv.env['ENABLE_NETWORK_LOGS'] ?? 'false') == 'true';

  /// Toggle crash-analytics / error reporting.
  static bool get enableCrashReporting =>
      (dotenv.env['ENABLE_CRASH_REPORTING'] ?? 'false') == 'true';

  /// Sentry Dsn for crash reporting.
  static String get sentryDsn => dotenv.env['SENTRY_DSN'] ?? '';
  // ── App meta ──────────────────────────────────────────────────────────────
}
