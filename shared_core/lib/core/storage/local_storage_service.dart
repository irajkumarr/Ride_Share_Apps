import 'package:shared_preferences/shared_preferences.dart';

/// Key constants for [LocalStorageService] to prevent magic strings.
abstract final class LocalStorageKeys {
  static const String isLoggedIn = 'is_logged_in';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String fcmToken = 'fcm_token';
  static const String lastSyncAt = 'last_sync_at';
  static const String appVersion = 'app_version';
  static const String savedPickupAddress = 'saved_pickup_address';
}

/// Contract for non-sensitive local key-value storage (SharedPreferences).
///
/// Use [SecureStorageService] for tokens and other sensitive data.
abstract class LocalStorageService {
  Future<void> setString(String key, {required String value});
  Future<void> setInt(String key, {required int value});
  Future<void> setDouble(String key, {required double value});
  Future<void> setBool(String key, {required bool value});
  Future<void> setStringList(String key, {required List<String> value});

  String? getString(String key);
  int? getInt(String key);
  double? getDouble(String key);
  bool? getBool(String key);
  List<String>? getStringList(String key);

  Future<void> remove(String key);
  Future<void> clear();
  bool containsKey(String key);
}

/// [SharedPreferences]-backed implementation of [LocalStorageService].
class LocalStorageServiceImpl implements LocalStorageService {
  const LocalStorageServiceImpl(this._prefs);

  final SharedPreferences _prefs;

  // ── Write ─────────────────────────────────────────────────────────────────

  @override
  Future<void> setString(String key, {required String value}) =>
      _prefs.setString(key, value);

  @override
  Future<void> setInt(String key, {required int value}) =>
      _prefs.setInt(key, value);

  @override
  Future<void> setDouble(String key, {required double value}) =>
      _prefs.setDouble(key, value);

  @override
  Future<void> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  @override
  Future<void> setStringList(String key, {required List<String> value}) =>
      _prefs.setStringList(key, value);

  // ── Read ──────────────────────────────────────────────────────────────────

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  double? getDouble(String key) => _prefs.getDouble(key);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  // ── Manage ────────────────────────────────────────────────────────────────

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();

  @override
  bool containsKey(String key) => _prefs.containsKey(key);
}
