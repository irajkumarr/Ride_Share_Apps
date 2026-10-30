import 'dart:async';

import 'package:driver_app/src/data/remote/driver_ride_api_service.dart';
import 'package:driver_app/src/data/local/auth_local_data_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_core/shared_core.dart';

enum DriverShiftStatus { offline, available, onRide }

class DriverStatusState {
  final DriverShiftStatus status;
  final bool isUpdating;
  final String? errorMessage;
  final LatLngModel? lastPosition;

  const DriverStatusState({
    required this.status,
    this.isUpdating = false,
    this.errorMessage,
    this.lastPosition,
  });

  DriverStatusState copyWith({
    DriverShiftStatus? status,
    bool? isUpdating,
    String? errorMessage,
    LatLngModel? lastPosition,
  }) {
    return DriverStatusState(
      status: status ?? this.status,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: errorMessage,
      lastPosition: lastPosition ?? this.lastPosition,
    );
  }
}

class DriverStatusCubit extends Cubit<DriverStatusState> {
  DriverStatusCubit({
    required DriverRideApiService driverRideApi,
    required WebSocketService webSocketService,
    required LocationService locationService,
    required AuthLocalDataSource authLocal,
  }) : _driverRideApi = driverRideApi,
       _webSocketService = webSocketService,
       _locationService = locationService,
       _authLocal = authLocal,
       super(const DriverStatusState(status: DriverShiftStatus.offline));

  final DriverRideApiService _driverRideApi;
  final WebSocketService _webSocketService;
  final LocationService _locationService;
  final AuthLocalDataSource _authLocal;

  Timer? _locationPingTimer;
  StreamSubscription<LatLngModel>? _positionStreamSub;

  Future<void> toggleOnlineOffline() async {
    if (state.status == DriverShiftStatus.offline) {
      await goOnline();
    } else if (state.status == DriverShiftStatus.available) {
      await goOffline();
    }
  }

  Future<void> goOnline() async {
    emit(state.copyWith(isUpdating: true, errorMessage: null));
    try {
      final hasPerm = await _locationService.ensurePermission();
      if (!hasPerm) {
        emit(
          state.copyWith(
            isUpdating: false,
            errorMessage: "Location permission is required to go online.",
          ),
        );
        return;
      }

      final pos = await _locationService.getCurrentLocation();
      if (pos != null) {
        emit(state.copyWith(lastPosition: pos));
        await _driverRideApi.pingLocation(
          latitude: pos.latitude,
          longitude: pos.longitude,
          heading: pos.heading,
        );
      }

      await _driverRideApi.updateDriverStatus("AVAILABLE");

      await _connectWebSocketAndTopics();
      _startLocationPings();

      emit(
        state.copyWith(status: DriverShiftStatus.available, isUpdating: false),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: "Failed to go online: " + e.toString(),
        ),
      );
    }
  }

  Future<void> goOffline() async {
    emit(state.copyWith(isUpdating: true, errorMessage: null));
    try {
      _stopLocationPings();
      await _driverRideApi.updateDriverStatus("OFFLINE");
      emit(
        state.copyWith(status: DriverShiftStatus.offline, isUpdating: false),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: "Failed to go offline: " + e.toString(),
        ),
      );
    }
  }

  Future<void> restoreOnRideStatus() async {
    try {
      await _connectWebSocketAndTopics();
      _startLocationPings();
      emit(state.copyWith(status: DriverShiftStatus.onRide, isUpdating: false));
    } catch (e) {
      emit(state.copyWith(status: DriverShiftStatus.onRide, isUpdating: false));
    }
  }

  void setOnRide() {
    emit(state.copyWith(status: DriverShiftStatus.onRide));
  }

  void setAvailable() {
    emit(state.copyWith(status: DriverShiftStatus.available));
  }

  Future<void> _connectWebSocketAndTopics() async {
    final token = await _authLocal.getAccessToken();
    final wsUrl = dotenv.env['WS_URL'] ?? 'ws://192.168.1.115:8080/ws';
    _webSocketService.connect(
      url: wsUrl,
      authToken: token,
      onConnected: () {
        AppLogger.info('STOMP connected for driver.');
      },
      onError: (err) {
        AppLogger.error('STOMP driver error: ' + err.toString());
      },
    );
  }

  void _startLocationPings() {
    _stopLocationPings();

    _positionStreamSub = _locationService
        .getLocationStream(
          enableBackgroundNotification: true,
          notificationTitle: "RideNest Pro Online",
          notificationText:
              "Continuous background GPS is tracking your location for rides.",
          intervalDurationInSeconds: 5,
        )
        .listen((pos) {
          emit(state.copyWith(lastPosition: pos));
          _sendLocationUpdate(pos);
        });

    _locationPingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final pos = await _locationService.getCurrentLocation();
      if (pos != null) {
        emit(state.copyWith(lastPosition: pos));
        _sendLocationUpdate(pos);
      }
    });
  }

  void _sendLocationUpdate(LatLngModel pos) {
    if (_webSocketService.isConnected) {
      _webSocketService.send(
        destination: '/app/driver.location',
        body: {
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'heading': pos.heading,
          'speed': pos.speed,
        },
      );
    }

    _driverRideApi
        .pingLocation(
          latitude: pos.latitude,
          longitude: pos.longitude,
          heading: pos.heading,
        )
        .catchError((_) {});
  }

  void _stopLocationPings() {
    _locationPingTimer?.cancel();
    _locationPingTimer = null;
    _positionStreamSub?.cancel();
    _positionStreamSub = null;
  }

  @override
  Future<void> close() {
    _stopLocationPings();
    return super.close();
  }
}
