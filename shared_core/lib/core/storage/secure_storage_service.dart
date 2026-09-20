// ignore_for_file: deprecated_member_use

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contract for storing sensitive data (tokens, credentials) using
/// platform-level encryption (Keychain on iOS, EncryptedSharedPreferences
/// on Android).
abstract class SecureStorageService {
  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> deleteTokens();

  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<Map<String, String>> readAll();
}

/// Secure key constants.
abstract final class SecureStorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userPin = 'user_pin';
  static const String biometricEnabled = 'biometric_enabled';
  static const String deviceId = 'device_id';
}

/// [FlutterSecureStorage]-backed implementation.
class SecureStorageServiceImpl implements SecureStorageService {
  SecureStorageServiceImpl()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  final FlutterSecureStorage _storage;

  // ── Token helpers ─────────────────────────────────────────────────────────

  @override
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: SecureStorageKeys.accessToken, value: token);

  @override
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: SecureStorageKeys.refreshToken, value: token);

  @override
  Future<String?> getAccessToken() => _storage.read(key: SecureStorageKeys.accessToken);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: SecureStorageKeys.refreshToken);

  @override
  Future<void> deleteTokens() async {
    await _storage.delete(key: SecureStorageKeys.accessToken);
    await _storage.delete(key: SecureStorageKeys.refreshToken);
  }

  // ── Generic helpers ───────────────────────────────────────────────────────

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();

  @override
  Future<Map<String, String>> readAll() => _storage.readAll();
}
