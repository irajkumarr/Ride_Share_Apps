import 'package:dio/dio.dart';
import 'package:shared_core/shared_core.dart';

/// Remote API service for geocoding and places autocomplete search.
class PlacesApiService {
  final ApiClient _apiClient;
  final Dio _dio;

  PlacesApiService({required ApiClient apiClient, required Dio dio})
    : _apiClient = apiClient,
      _dio = dio;

  /// Searches places based on [query] with optional proximity coordinates.
  Future<List<AddressModel>> searchPlaces(
    String query, {
    LatLngModel? proximity,
  }) async {
    if (query.trim().isEmpty) return [];

    final lat = proximity?.latitude ?? 27.7172;
    final lng = proximity?.longitude ?? 85.3240;

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'countrycodes': 'np', // Restrict search results strictly to Nepal
          'format': 'json',
          'addressdetails': '1',
          'limit': '10',
          'viewbox':
              '80.05,30.45,88.20,26.35', // Nepal geographical bounding box
          'bounded': '1',
        },
        options: Options(
          headers: {'User-Agent': 'RiderApp/1.0', 'Accept-Language': 'en,ne'},
        ),
      );

      if (response.data is List) {
        final list = response.data as List;
        return list.map((item) {
          final map = item as Map<String, dynamic>;
          final displayName = map['display_name'] as String? ?? query;
          final parts = displayName.split(',');
          final title = parts.first.trim();
          final subtitle = parts.skip(1).take(3).join(',').trim();

          final itemLat = double.tryParse(map['lat']?.toString() ?? '') ?? lat;
          final itemLng = double.tryParse(map['lon']?.toString() ?? '') ?? lng;

          return AddressModel(
            id:
                map['place_id']?.toString() ??
                '${DateTime.now().microsecondsSinceEpoch}',
            title: title,
            formattedAddress: subtitle.isNotEmpty
                ? subtitle
                : '$displayName, Nepal',
            coordinates: LatLngModel(latitude: itemLat, longitude: itemLng),
            placeId: map['place_id']?.toString(),
            country: 'Nepal',
          );
        }).toList();
      }
    } catch (e) {
      AppLogger.error('Real Places API Search Error: $e');
      rethrow;
    }

    return const [];
  }

  /// Reverse geocodes coordinates into an address strictly via API.
  Future<AddressModel?> reverseGeocode(LatLngModel coordinates) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': coordinates.latitude,
          'lon': coordinates.longitude,
          'format': 'json',
          'addressdetails': '1',
        },
        options: Options(
          headers: {'User-Agent': 'RiderApp/1.0', 'Accept-Language': 'en,ne'},
        ),
      );

      if (response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        final displayName = map['display_name'] as String? ?? '';
        final parts = displayName.split(',');
        final title = parts.first.trim();
        final subtitle = parts.skip(1).take(3).join(',').trim();

        return AddressModel(
          id:
              map['place_id']?.toString() ??
              'rev_${DateTime.now().millisecondsSinceEpoch}',
          title: title.isNotEmpty ? title : 'Pin Location',
          formattedAddress: subtitle.isNotEmpty ? subtitle : displayName,
          coordinates: coordinates,
          placeId: map['place_id']?.toString(),
          country: 'Nepal',
        );
      }
    } catch (e) {
      AppLogger.error('Real Reverse Geocode API Error: $e');
      rethrow;
    }

    return null;
  }
}
