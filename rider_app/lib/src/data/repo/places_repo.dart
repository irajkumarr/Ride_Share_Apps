import 'package:shared_core/shared_core.dart';
import '../local/recent_places_local_data_source.dart';
import '../remote/places_api_service.dart';

class PlacesRepo {
  PlacesRepo({
    required PlacesApiService api,
    required RecentPlacesLocalDataSource local,
  })  : _api = api,
        _local = local;

  final PlacesApiService _api;
  final RecentPlacesLocalDataSource _local;

  Future<List<AddressModel>> searchPlaces(
    String query, {
    LatLngModel? proximity,
  }) async {
    return _api.searchPlaces(query, proximity: proximity);
  }

  Future<AddressModel?> reverseGeocode(LatLngModel coordinates) async {
    return _api.reverseGeocode(coordinates);
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

