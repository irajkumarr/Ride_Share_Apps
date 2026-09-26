import 'package:dio/dio.dart';
import 'package:shared_core/shared_core.dart';

enum RideStatus {
  idle,
  searchingDriver,
  driverAssigned,
  driverArriving,
  tripInProgress,
  tripCompleted,
  cancelled,
}

class DriverModel {
  final String id;
  final String name;
  final String photoUrl;
  final double rating;
  final int totalRides;
  final String vehicleModel;
  final String vehicleColor;
  final String licensePlate;
  final String phoneNumber;
  final LatLngModel location;

  const DriverModel({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.rating,
    required this.totalRides,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.licensePlate,
    required this.phoneNumber,
    required this.location,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String? ?? 'dr_101',
      name: json['name'] as String? ?? 'Bikash Shrestha',
      photoUrl: json['photoUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      totalRides: json['totalRides'] as int? ?? 1420,
      vehicleModel: json['vehicleModel'] as String? ?? 'Suzuki Swift',
      vehicleColor: json['vehicleColor'] as String? ?? 'White',
      licensePlate: json['licensePlate'] as String? ?? 'BA 2 PA 9845',
      phoneNumber: json['phoneNumber'] as String? ?? '+977 9841234567',
      location: json['location'] != null
          ? LatLngModel.fromJson(json['location'] as Map<String, dynamic>)
          : const LatLngModel(latitude: 27.7172, longitude: 85.3240),
    );
  }
}

class RideBookingModel {
  final String id;
  final AddressModel pickup;
  final AddressModel destination;
  final String vehicleTier;
  final double fareNpr;
  final String paymentMethod;
  final String? promoCode;
  final RouteModel route;
  final RideStatus status;
  final DriverModel? driver;

  const RideBookingModel({
    required this.id,
    required this.pickup,
    required this.destination,
    required this.vehicleTier,
    required this.fareNpr,
    required this.paymentMethod,
    this.promoCode,
    required this.route,
    required this.status,
    this.driver,
  });

  RideBookingModel copyWith({
    String? id,
    AddressModel? pickup,
    AddressModel? destination,
    String? vehicleTier,
    double? fareNpr,
    String? paymentMethod,
    String? promoCode,
    RouteModel? route,
    RideStatus? status,
    DriverModel? driver,
  }) {
    return RideBookingModel(
      id: id ?? this.id,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      vehicleTier: vehicleTier ?? this.vehicleTier,
      fareNpr: fareNpr ?? this.fareNpr,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      promoCode: promoCode ?? this.promoCode,
      route: route ?? this.route,
      status: status ?? this.status,
      driver: driver ?? this.driver,
    );
  }
}

/// Remote API service for routing and ride bookings.
class RideApiService {
  final ApiClient _apiClient;
  final Dio _dio;

  RideApiService({required ApiClient apiClient, required Dio dio})
      : _apiClient = apiClient,
        _dio = dio;

  /// Calculates route between two points strictly via OSRM routing API.
  Future<RouteModel> getRouteBetweenCoordinates({
    required LatLngModel origin,
    required LatLngModel destination,
  }) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';
    final response = await _dio.get(url);

    if (response.data is Map && response.data['routes'] != null) {
      final routes = response.data['routes'] as List;
      if (routes.isNotEmpty) {
        final first = routes.first as Map<String, dynamic>;
        final geometry = first['geometry'] as Map<String, dynamic>;
        final coords = geometry['coordinates'] as List;

        final points = coords.map((c) {
          final pair = c as List;
          return LatLngModel(
            latitude: (pair[1] as num).toDouble(),
            longitude: (pair[0] as num).toDouble(),
          );
        }).toList();

        final distance = (first['distance'] as num).toDouble();
        final duration = (first['duration'] as num).toDouble();

        return RouteModel(
          points: points,
          distanceInMeters: distance,
          durationInSeconds: duration,
        );
      }
    }

    throw Exception('Failed to calculate route from routing API');
  }

  /// Directly calls backend REST API: POST /api/v1/rides/request
  Future<RideBookingModel> createBookingRequest(RideBookingModel request) async {
    // Map vehicle tier to backend enum (ECONOMY, PREMIUM, XL)
    String backendVehicleType = 'ECONOMY';
    final tier = request.vehicleTier.toLowerCase();
    if (tier.contains('xl') || tier.contains('van')) {
      backendVehicleType = 'XL';
    } else if (tier.contains('comfort') || tier.contains('premium') || tier.contains('sedan')) {
      backendVehicleType = 'PREMIUM';
    } else {
      backendVehicleType = 'ECONOMY';
    }

    final payload = {
      'pickupLat': request.pickup.coordinates.latitude,
      'pickupLng': request.pickup.coordinates.longitude,
      'pickupAddress': request.pickup.formattedAddress.isNotEmpty
          ? request.pickup.formattedAddress
          : request.pickup.title,
      'dropoffLat': request.destination.coordinates.latitude,
      'dropoffLng': request.destination.coordinates.longitude,
      'dropoffAddress': request.destination.formattedAddress.isNotEmpty
          ? request.destination.formattedAddress
          : request.destination.title,
      'vehicleType': backendVehicleType,
      'estimatedFare': request.fareNpr,
      'distanceKm': request.route != null ? (request.route!.distanceInMeters / 1000.0) : null,
    };

    AppLogger.info('Sending ride request to API: $payload');
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiUrls.rideRequest,
      data: payload,
    );

    if (response['data'] != null) {
      final data = response['data'] as Map<String, dynamic>;
      final rideId = data['id']?.toString() ?? '';
      final estimatedFare = (data['estimatedFare'] as num?)?.toDouble() ?? request.fareNpr;

      return request.copyWith(
        id: rideId,
        fareNpr: estimatedFare,
        status: RideStatus.searchingDriver,
      );
    }

    throw Exception(response['message'] ?? 'Failed to request ride from server');
  }

  Future<String?> cancelRide(String rideId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(ApiUrls.rideCancel(rideId));
    if (response is Map<String, dynamic> && response['message'] != null) {
      return response['message']?.toString();
    }
    return 'Ride Cancelled';
  }
}


