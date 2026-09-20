import '../error/exceptions.dart';
import '../utils/app_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

/// Hive box name constants – one box per feature / data type.
abstract final class HiveBoxNames {
  static const String user = 'user_box';
  static const String settings = 'settings_box';
  static const String cache = 'generic_cache_box';
  static const String notifications = 'notifications_box';
  static const String offlineQueue = 'offline_queue_box';
}

/// Contract for Hive-based local caching with optional TTL support.
abstract class HiveCacheService {
  /// Opens all required Hive boxes.
  Future<void> openBoxes();

  /// Stores [value] (JSON-encodable) under [key] in [boxName].
  /// Optional [ttlSeconds] marks the entry for expiry.
  Future<void> put<T>({
    required String boxName,
    required String key,
    required T value,
    int? ttlSeconds,
  });

  /// Retrieves the value for [key] from [boxName].
  /// Returns `null` if not found or TTL has expired.
  T? get<T>({required String boxName, required String key});

  /// Removes a single entry.
  Future<void> delete({required String boxName, required String key});

  /// Clears all entries from [boxName].
  Future<void> clearBox(String boxName);

  /// Clears all Hive boxes.
  Future<void> clearAll();

  /// Whether a non-expired entry exists for [key] in [boxName].
  bool has({required String boxName, required String key});
}

/// Hive-backed implementation with JSON serialisation and TTL envelope.
class HiveCacheServiceImpl implements HiveCacheService {
  static const String _valueKey = 'v';
  static const String _expiryKey = 'e';

  @override
  Future<void> openBoxes() async {
    await Future.wait([
      Hive.openBox<dynamic>(HiveBoxNames.user),
      Hive.openBox<dynamic>(HiveBoxNames.settings),
      Hive.openBox<dynamic>(HiveBoxNames.cache),
      Hive.openBox<dynamic>(HiveBoxNames.notifications),
      Hive.openBox<dynamic>(HiveBoxNames.offlineQueue),
    ]);
    AppLogger.info('HiveCacheService: all boxes opened');
  }

  @override
  Future<void> put<T>({
    required String boxName,
    required String key,
    required T value,
    int? ttlSeconds,
  }) async {
    try {
      final box = Hive.box<dynamic>(boxName);
      final envelope = <String, dynamic>{
        _valueKey: value is String ? value : jsonEncode(value),
        if (ttlSeconds != null)
          _expiryKey: DateTime.now().add(Duration(seconds: ttlSeconds)).millisecondsSinceEpoch,
      };
      await box.put(key, envelope);
    } catch (e) {
      AppLogger.error('HiveCacheService.put failed', error: e);
      throw CacheException(message: e.toString());
    }
  }

  @override
  T? get<T>({required String boxName, required String key}) {
    try {
      final box = Hive.box<dynamic>(boxName);
      final envelope = box.get(key) as Map<dynamic, dynamic>?;
      if (envelope == null) return null;

      // Check TTL
      final expiry = envelope[_expiryKey] as int?;
      if (expiry != null && DateTime.now().millisecondsSinceEpoch > expiry) {
        box.delete(key); // lazy eviction
        return null;
      }

      final raw = envelope[_valueKey];
      if (raw is T) return raw;
      if (raw is String) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is T) return decoded;
        } catch (_) {}
      }
      return null;
    } catch (e) {
      AppLogger.error('HiveCacheService.get failed', error: e);
      return null;
    }
  }

  @override
  Future<void> delete({required String boxName, required String key}) async {
    try {
      await Hive.box<dynamic>(boxName).delete(key);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearBox(String boxName) async {
    try {
      await Hive.box<dynamic>(boxName).clear();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearAll() async {
    for (final name in [
      HiveBoxNames.user,
      HiveBoxNames.settings,
      HiveBoxNames.cache,
      HiveBoxNames.notifications,
      HiveBoxNames.offlineQueue,
    ]) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box<dynamic>(name).clear();
      }
    }
  }

  @override
  bool has({required String boxName, required String key}) {
    try {
      final box = Hive.box<dynamic>(boxName);
      if (!box.containsKey(key)) return false;
      // Still need to check TTL
      final result = get<dynamic>(boxName: boxName, key: key);
      return result != null;
    } catch (_) {
      return false;
    }
  }
}
