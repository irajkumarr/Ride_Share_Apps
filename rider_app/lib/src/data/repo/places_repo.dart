import 'package:shared_core/shared_core.dart';
import '../remote/places_api_service.dart';

class PlacesRepo {
  PlacesRepo({required PlacesApiService api}) : _api = api;

  final PlacesApiService _api;

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

  List<AddressModel> getRecentPlaces() {
    return const [
      AddressModel(
        id: 'rec_1',
        title: 'Civil Mall',
        formattedAddress: 'Sundhara, Kathmandu, Nepal',
        coordinates: LatLngModel(latitude: 27.7005, longitude: 85.3135),
        country: 'Nepal',
      ),
      AddressModel(
        id: 'rec_2',
        title: 'Tribhuvan International Airport',
        formattedAddress: 'Ring Road, Kathmandu, Nepal',
        coordinates: LatLngModel(latitude: 27.6966, longitude: 85.3591),
        country: 'Nepal',
      ),
      AddressModel(
        id: 'rec_3',
        title: 'Jhamsikhel Restaurant Row',
        formattedAddress: 'Jhamsikhel, Lalitpur, Nepal',
        coordinates: LatLngModel(latitude: 27.6740, longitude: 85.3110),
        country: 'Nepal',
      ),
    ];
  }
}
