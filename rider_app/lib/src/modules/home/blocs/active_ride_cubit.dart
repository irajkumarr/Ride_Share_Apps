import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_core/shared_core.dart';

import '../../../data/local/auth_local_data_source.dart';
import '../../../data/remote/ride_api_service.dart';
import '../../../data/repo/ride_repo.dart';

abstract class ActiveRideState {}

class ActiveRideInitial extends ActiveRideState {}

class RoutePreviewReady extends ActiveRideState {
  final AddressModel pickup;
  final AddressModel destination;
  final RouteModel route;
  final double distanceKm;
  final int durationMins;

  RoutePreviewReady({
    required this.pickup,
    required this.destination,
    required this.route,
    required this.distanceKm,
    required this.durationMins,
  });
}

class DriverSearching extends ActiveRideState {
  final RideBookingModel booking;
  DriverSearching(this.booking);
}

class DriverAssignedState extends ActiveRideState {
  final RideBookingModel booking;
  final DriverModel driver;
  final LatLngModel driverPosition;
  final String statusText;

  DriverAssignedState({
    required this.booking,
    required this.driver,
    required this.driverPosition,
    required this.statusText,
  });
}

class TripCompletedState extends ActiveRideState {
  final RideBookingModel booking;
  final DriverModel? driver;
  final String? message;
  TripCompletedState(this.booking, {this.driver, this.message});
}

class RideCancelledState extends ActiveRideState {
  final String message;
  RideCancelledState(this.message);
}

class ActiveRideCubit extends BaseCubit<ActiveRideState> {
  final RideRepo _rideRepo;
  final WebSocketService _webSocketService;
  final AuthLocalDataSource _authLocalDataSource;

  Timer? _simulationTimer;
  Timer? _fallbackAcceptanceTimer;
  int _simulationStep = 0;
  List<LatLngModel> _currentPolylinePoints = [];
  String? _currentRideId;

  ActiveRideCubit({
    required RideRepo rideRepo,
    required WebSocketService webSocketService,
    required AuthLocalDataSource authLocalDataSource,
  }) : _rideRepo = rideRepo,
       _webSocketService = webSocketService,
       _authLocalDataSource = authLocalDataSource,
       super(ActiveRideInitial());

  Future<void> checkActiveRide() async {
    try {
      final rideData = await _rideRepo.getActiveRide();
      if (rideData != null && rideData['id'] != null) {
        final rideId = rideData['id'] as String;
        final status = rideData['status'] as String? ?? 'REQUESTED';
        _currentRideId = rideId;

        final pickup = AddressModel(
          id: 'pickup',
          title: rideData['pickupAddress']?.toString() ?? 'Pickup',
          formattedAddress: rideData['pickupAddress']?.toString() ?? 'Pickup',
          coordinates: LatLngModel(
            latitude: (rideData['pickupLat'] as num?)?.toDouble() ?? 0.0,
            longitude: (rideData['pickupLng'] as num?)?.toDouble() ?? 0.0,
          ),
          country: 'Nepal',
        );

        final destination = AddressModel(
          id: 'destination',
          title: rideData['dropoffAddress']?.toString() ?? 'Destination',
          formattedAddress:
              rideData['dropoffAddress']?.toString() ?? 'Destination',
          coordinates: LatLngModel(
            latitude: (rideData['dropoffLat'] as num?)?.toDouble() ?? 0.0,
            longitude: (rideData['dropoffLng'] as num?)?.toDouble() ?? 0.0,
          ),
          country: 'Nepal',
        );

        final booking = RideBookingModel(
          id: rideId,
          pickup: pickup,
          destination: destination,
          vehicleTier: 'Economy',
          fareNpr: (rideData['estimatedFare'] as num?)?.toDouble() ?? 0.0,
          paymentMethod: 'Cash',
          route: const RouteModel(
            points: [],
            distanceInMeters: 0,
            durationInSeconds: 0,
          ),
          status: RideStatus.searchingDriver,
        );

        // Connect WebSocket and resume tracking
        final wsUrl =
            dotenv.env['WS_URL'] ??
            (dotenv.env['BASE_URL'] != null
                ? dotenv.env['BASE_URL']!.replaceFirst('http', 'ws') + '/ws'
                : 'ws://localhost:8080/ws');
        final token = await _authLocalDataSource.getAccessToken();

        _webSocketService.connect(
          url: wsUrl,
          authToken: token,
          onConnected: () => _subscribeToWebSocketTopics(booking),
        );

        if (status == 'ACCEPTED' ||
            status == 'ARRIVED' ||
            status == 'IN_PROGRESS') {
          final driver = DriverModel(
            id: rideData['driverId']?.toString() ?? 'driver',
            name: rideData['driverName']?.toString() ?? 'Driver',
            photoUrl: '',
            rating: 4.9,
            totalRides: 100,
            vehicleModel: rideData['vehicleMakeModel']?.toString() ?? 'Vehicle',
            vehicleColor: '',
            licensePlate: rideData['licensePlate']?.toString() ?? '',
            phoneNumber: rideData['driverPhone']?.toString() ?? '',
            location: pickup.coordinates,
          );

          emit(
            DriverAssignedState(
              booking: booking.copyWith(
                status: status == 'IN_PROGRESS'
                    ? RideStatus.tripInProgress
                    : (status == 'ARRIVED'
                          ? RideStatus.driverArriving
                          : RideStatus.driverAssigned),
                driver: driver,
              ),
              driver: driver,
              driverPosition: pickup.coordinates,
              statusText: 'Trip in progress ($status)',
            ),
          );
        } else {
          emit(DriverSearching(booking));
        }
      }
    } catch (e) {
      AppLogger.error('Failed to restore active ride for rider: $e');
    }
  }

  Future<void> prepareRoutePreview({
    required AddressModel pickup,
    required AddressModel destination,
  }) async {
    await safeCall<RouteModel>(
      label: 'PrepareRoutePreview',
      call: () => _rideRepo.getRouteBetweenCoordinates(
        origin: pickup.coordinates,
        destination: destination.coordinates,
      ),
      loading: () => ActiveRideInitial(),
      success: (route) {
        _currentPolylinePoints = route.points;
        final km = route.distanceInMeters / 1000;
        final mins = (route.durationInSeconds / 60).round();
        return RoutePreviewReady(
          pickup: pickup,
          destination: destination,
          route: route,
          distanceKm: km,
          durationMins: mins,
        );
      },
      failure: (err) => ActiveRideInitial(),
    );
  }

  Future<void> bookRide({
    required AddressModel pickup,
    required AddressModel destination,
    required RouteModel route,
    required String vehicleTier,
    required double fareNpr,
    required String paymentMethod,
    String? promoCode,
  }) async {
    var booking = RideBookingModel(
      id: '',
      pickup: pickup,
      destination: destination,
      vehicleTier: vehicleTier,
      fareNpr: fareNpr,
      paymentMethod: paymentMethod,
      promoCode: promoCode,
      route: route,
      status: RideStatus.searchingDriver,
    );

    emit(DriverSearching(booking));

    // 1. Send Request directly to real backend REST API
    try {
      booking = await _rideRepo.requestRide(booking);
      _currentRideId = booking.id;
      emit(DriverSearching(booking));
    } catch (e) {
      AppLogger.error('API requestRide failed: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      emit(
        RideCancelledState(
          errorMsg.isNotEmpty
              ? e.apiMessage
              : 'Failed to request ride. Please try again.',
        ),
      );
      return;
    }

    // 2. Connect to real STOMP WebSocket using environment URL & JWT Auth Token
    final wsUrl =
        dotenv.env['WS_URL'] ??
        (dotenv.env['BASE_URL'] != null
            ? dotenv.env['BASE_URL']!.replaceFirst('http', 'ws') + '/ws'
            : 'ws://localhost:8080/ws');
    final token = await _authLocalDataSource.getAccessToken();

    _webSocketService.connect(
      url: wsUrl,
      authToken: token,
      onConnected: () {
        AppLogger.info(
          'Subscribing rider to real-time STOMP topics for ride: ${booking.id}',
        );
        _subscribeToWebSocketTopics(booking);
      },
      onError: (err) {
        AppLogger.error('STOMP WebSocket error for ride tracking: $err');
      },
    );
  }

  void _subscribeToWebSocketTopics(RideBookingModel booking) {
    // 1. Rider Status Updates (/user/queue/ride-status)
    _webSocketService.subscribe(
      destination: '/user/queue/ride-status',
      onMessage: (data) {
        AppLogger.info('Received real WebSocket ride status: $data');
        _handleRideStatusUpdate(booking, data);
      },
    );

    // 2. Real-time Live Driver Coordinates (/user/queue/driver-location)
    _webSocketService.subscribe(
      destination: '/user/queue/driver-location',
      onMessage: (data) {
        _handleDriverLocationUpdate(booking, data);
      },
    );

    // 3. Driver Live Location Topic (/topic/rides/{rideId}/location)
    _webSocketService.subscribe(
      destination: '/topic/rides/${booking.id}/location',
      onMessage: (data) {
        _handleDriverLocationUpdate(booking, data);
      },
    );
  }

  void _handleRideStatusUpdate(
    RideBookingModel booking,
    Map<String, dynamic> data,
  ) {
    final status = data['status']?.toString().toUpperCase();
    final message = data['message']?.toString();

    if (status == 'ACCEPTED') {
      // If already assigned with driver details, do not re-emit duplicate state with empty/null data
      if (state is DriverAssignedState) {
        final current = state as DriverAssignedState;
        // If the new payload has empty/null driverData, ignore it to prevent overwriting with placeholder
        if (data['driverData'] == null &&
            current.driver.id.isNotEmpty &&
            current.driver.id != 'driver_assigned') {
          AppLogger.info(
            'Ignoring duplicate ACCEPTED status payload without driver details',
          );
          return;
        }
      }

      // If driverData is missing and we don't have driver, don't overwrite if existing state already has it
      final driverData = data['driverData'] as Map<String, dynamic>?;
      final vehicleData = data['vehicle'] as Map<String, dynamic>?;

      final driver = DriverModel(
        id: driverData?['id']?.toString() ?? 'driver_assigned',
        name: driverData?['fullName']?.toString() ?? 'Assigned Driver',
        photoUrl: driverData?['photoUrl']?.toString() ?? '',
        rating: (driverData?['rating'] as num?)?.toDouble() ?? 4.9,
        totalRides: (driverData?['totalRides'] as num?)?.toInt() ?? 100,
        vehicleModel: vehicleData?['model']?.toString() ?? booking.vehicleTier,
        vehicleColor: vehicleData?['color']?.toString() ?? '',
        licensePlate: vehicleData?['licensePlate']?.toString() ?? '',
        phoneNumber: driverData?['phone']?.toString() ?? '',
        location: booking.pickup.coordinates,
      );

      final acceptedBooking = booking.copyWith(
        status: RideStatus.driverAssigned,
        driver: driver,
      );

      emit(
        DriverAssignedState(
          booking: acceptedBooking,
          driver: driver,
          driverPosition: driver.location,
          statusText: message ?? 'Driver Accepted your ride request',
        ),
      );
    } else if (status == 'ARRIVED') {
      if (state is DriverAssignedState) {
        final cur = state as DriverAssignedState;
        emit(
          DriverAssignedState(
            booking: cur.booking.copyWith(status: RideStatus.driverArriving),
            driver: cur.driver,
            driverPosition: cur.driverPosition,
            statusText: message ?? 'Driver has arrived at pickup point',
          ),
        );
      }
    } else if (status == 'IN_PROGRESS') {
      if (state is DriverAssignedState) {
        final cur = state as DriverAssignedState;
        emit(
          DriverAssignedState(
            booking: cur.booking.copyWith(status: RideStatus.tripInProgress),
            driver: cur.driver,
            driverPosition: cur.driverPosition,
            statusText:
                message ?? 'Trip in progress to ${booking.destination.title}',
          ),
        );
      }
    } else if (status == 'COMPLETED') {
      DriverModel? currentDriver;
      if (state is DriverAssignedState) {
        currentDriver = (state as DriverAssignedState).driver;
      }
      emit(
        TripCompletedState(
          booking,
          driver: currentDriver,
          message: "Ride Completed",
        ),
      );
    } else if (status == 'CANCELLED') {
      final msg = message ?? 'Ride has been cancelled';
      cancelRide(customMessage: msg);
    } else if (status == 'NO_DRIVERS') {
      final msg = message ?? 'No drivers currently available. Please try again';
      cancelRide(customMessage: msg);
    }
  }

  void _handleDriverLocationUpdate(
    RideBookingModel booking,
    Map<String, dynamic> data,
  ) {
    final lat = (data['latitude'] as num?)?.toDouble();
    final lng = (data['longitude'] as num?)?.toDouble();

    if (lat != null && lng != null && state is DriverAssignedState) {
      final cur = state as DriverAssignedState;
      final newPos = LatLngModel(latitude: lat, longitude: lng);
      emit(
        DriverAssignedState(
          booking: cur.booking,
          driver: cur.driver,
          driverPosition: newPos,
          statusText: cur.statusText,
        ),
      );
    }
  }

  /// Cleanly resets and returns to initial dashboard state after trip completion
  /// without triggering the cancel ride API.
  void resetTrip() {
    _currentRideId = null;
    _webSocketService.disconnect();
    emit(ActiveRideInitial());
  }

  Future<void> cancelRide({String? customMessage}) async {
    String? apiMsg;
    if (_currentRideId != null) {
      try {
        apiMsg = await _rideRepo.cancelRide(_currentRideId!);
      } catch (e) {
        AppLogger.warning('Cancel ride API failed: $e');
      }
      _currentRideId = null;
    }

    _webSocketService.disconnect();
    final effectiveMessage = customMessage ?? apiMsg ?? 'Ride Cancelled';
    emit(RideCancelledState(effectiveMessage));
  }

  @override
  Future<void> close() {
    _webSocketService.disconnect();
    return super.close();
  }
}
