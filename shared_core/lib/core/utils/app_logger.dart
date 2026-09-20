import '../../config/flavor/flavor_config.dart';
import 'package:logger/logger.dart';

/// Centralised logging utility wrapping the [Logger] package.
///
/// Log levels are automatically adjusted per flavor:
/// - Development / Staging → all levels enabled.
/// - Production → only warnings and errors.
///
/// Usage:
/// ```dart
/// AppLogger.info('User logged in');
/// AppLogger.error('API call failed', error: e, stackTrace: st);
/// ```
abstract final class AppLogger {
  static late Logger _logger;

  /// Call once during app bootstrap.
  static void init({required AppFlavor flavor}) {
   
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: AppConfig.isDev ? 2 : 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: flavor == AppFlavor.prod ? Level.warning : Level.trace,
      filter: _AppLogFilter(flavor),
    );
  }

  /// Verbose/trace level – very detailed diagnostic info.
  static void trace(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.t(message, error: error, stackTrace: stackTrace);

  /// Debug level – step-through debugging info.
  static void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  /// Info level – general noteworthy events.
  static void info(String message, {Object? error, StackTrace? stackTrace}) => _logger.i(
    message,
    error: error,
    stackTrace: stackTrace,
  );

  /// Warning level – potentially harmful situations.
  static void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) => _logger.w(message, error: error, stackTrace: stackTrace);

  /// Error level – errors that should be investigated.
  static void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  /// Fatal level – severe errors that may crash the app.
  static void fatal(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.f(message, error: error, stackTrace: stackTrace);

  /// Returns the current flavor (for conditional logging in widgets).
  static bool get isDebug => AppConfig.isDev;
}

/// Custom [LogFilter] that suppresses debug-level logs in production.
class _AppLogFilter extends LogFilter {
  _AppLogFilter(this._flavor);
  final AppFlavor _flavor;

  @override
  bool shouldLog(LogEvent event) {
    if (_flavor == AppFlavor.prod) {
      return event.level.index >= Level.warning.index;
    }
    return true;
  }
}
