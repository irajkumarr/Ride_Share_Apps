import 'dart:convert';

import 'package:shared_core/shared_core.dart';

import '../local/recent_places_local_data_source.dart';
import '../remote/places_api_service.dart';

class PlacesRepo {
  PlacesRepo({
    required PlacesApiService api,
    required RecentPlacesLocalDataSource local,
    LocalStorageService? storage,
  }) : _api = api,
       _local = local,
       _storage =
           storage ??
           (sl.isRegistered<LocalStorageService>()
               ? sl<LocalStorageService>()
               : null);

  final PlacesApiService _api;
  final RecentPlacesLocalDataSource _local;
  final LocalStorageService? _storage;

  Future<List<AddressModel>> searchPlaces(
    String query, {
    LatLngModel? proximity,
  }) async {
    return _api.searchPlaces(query, proximity: proximity);
  }

  Future<AddressModel?> reverseGeocode(LatLngModel coordinates) async {
    return _api.reverseGeocode(coordinates);
  }

  /// Save user-chosen pickup address to persistent local storage.
  Future<void> saveSavedPickupAddress(AddressModel address) async {
    try {
      final jsonStr = jsonEncode(address.toJson());
      if (_storage != null) {
        await _storage!.setString(
          LocalStorageKeys.savedPickupAddress,
          value: jsonStr,
        );
      }
    } catch (_) {}
  }

  /// Retrieve the user-chosen saved pickup address if available.
  AddressModel? getSavedPickupAddress() {
    try {
      if (_storage != null) {
        final raw = _storage!.getString(LocalStorageKeys.savedPickupAddress);
        if (raw != null && raw.isNotEmpty) {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          return AddressModel.fromJson(decoded);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Clear the saved pickup address.
  Future<void> clearSavedPickupAddress() async {
    try {
      if (_storage != null) {
        await _storage!.remove(LocalStorageKeys.savedPickupAddress);
      }
    } catch (_) {}
  }

  List<AddressModel> getFavoritePlaces() {
    return const [
      AddressModel(
        id: 'fav_home',
        title: 'Home (Kathmandu)',
        formattedAddress: 'Baluwatar, Ward 4, Kathmandu, Nepal',
        coordinates: LatLngModel(latitude: 27.7280, longitude: 85.3320),
        country: 'Nepal',
      ),
      AddressModel(
        id: 'fav_work',
        title: 'Office (Pulchowk)',
        formattedAddress: 'Pulchowk Road, Lalitpur, Nepal',
        coordinates: LatLngModel(latitude: 27.6780, longitude: 85.3170),
        country: 'Nepal',
      ),
    ];
  }

  Future<List<AddressModel>> getRecentPlaces() async {
    return _local.getRecentPlaces();
  }

  List<AddressModel> getRecentPlacesSync() {
    return _local.getRecentPlacesSync();
  }

  Future<void> saveRecentPlace(AddressModel place) async {
    await _local.saveRecentPlace(place);
  }

  Future<void> clearRecentPlaces() async {
    await _local.clearRecentPlaces();
  }
}
