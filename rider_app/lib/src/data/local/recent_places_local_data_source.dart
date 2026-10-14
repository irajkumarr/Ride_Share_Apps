import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_core/models/location/address_model.dart';

class RecentPlacesLocalDataSource {
  static const String boxName = 'recent_places_box';
  static const String _recentKey = 'recent_searches_list';
  static const int _maxRecents = 15;

  Box<String>? _box;

  Future<Box<String>> _getBox() async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<String>(boxName);
    return _box!;
  }

  /// Get recent searched places from Hive, newest first.
  Future<List<AddressModel>> getRecentPlaces() async {
    try {
      final box = await _getBox();
      final rawList = box.get(_recentKey);
      if (rawList == null || rawList.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(rawList) as List<dynamic>;
      return decoded
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Synchronous getter if box is already open
  List<AddressModel> getRecentPlacesSync() {
    try {
      if (_box == null || !_box!.isOpen) return [];
      final rawList = _box!.get(_recentKey);
      if (rawList == null || rawList.isEmpty) return [];
      final decoded = jsonDecode(rawList) as List<dynamic>;
      return decoded
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Save a recently searched or selected place.
  /// Removes duplicate if existing (by title or coordinates), prepends to head,
  /// and caps at [_maxRecents].
  Future<void> saveRecentPlace(AddressModel place) async {
    try {
      final box = await _getBox();
      final currentList = await getRecentPlaces();

      // Filter out duplicate
      final updatedList = currentList.where((p) {
        final sameTitle = p.title.trim().toLowerCase() == place.title.trim().toLowerCase();
        final sameCoords = (p.coordinates.latitude - place.coordinates.latitude).abs() < 0.0001 &&
            (p.coordinates.longitude - place.coordinates.longitude).abs() < 0.0001;
        return !sameTitle && !sameCoords;
      }).toList();

      // Insert newest at beginning
      updatedList.insert(0, place);

      // Keep only up to max
      final cappedList = updatedList.take(_maxRecents).toList();

      final encoded = jsonEncode(cappedList.map((e) => e.toJson()).toList());
      await box.put(_recentKey, encoded);
    } catch (_) {}
  }

  /// Clear all stored recent places.
  Future<void> clearRecentPlaces() async {
    try {
      final box = await _getBox();
      await box.delete(_recentKey);
    } catch (_) {}
  }
}
