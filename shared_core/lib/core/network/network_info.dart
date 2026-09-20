import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Contract for checking network connectivity.
///
/// Use in repositories before making network requests:
/// ```dart
/// if (!await networkInfo.isConnected) {
///   return Left(const NetworkFailure());
/// }
/// ```
abstract class NetworkInfo {
  /// Returns `true` if the device has an active internet connection.
  Future<bool> get isConnected;

  /// Emits `true` / `false` whenever connectivity changes.
  Stream<bool> get connectivityStream;
}

/// Concrete implementation backed by [InternetConnection].
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl(this._internetConnection);

  final InternetConnection _internetConnection;

  @override
  Future<bool> get isConnected => _internetConnection.hasInternetAccess;

  @override
  Stream<bool> get connectivityStream => _internetConnection.onStatusChange.map(
    (status) => status == InternetStatus.connected,
  );
}
