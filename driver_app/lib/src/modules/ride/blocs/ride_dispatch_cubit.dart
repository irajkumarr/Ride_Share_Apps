import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_app/src/data/remote/driver_ride_api_service.dart';
import 'package:driver_app/src/data/remote/dto/ride_dispatch_dto.dart';
import 'package:driver_app/src/modules/home/blocs/driver_status_cubit.dart';
import 'package:shared_core/shared_core.dart';

abstract class RideDispatchState {}

class RideDispatchIdle extends RideDispatchState {}

class RideRequestReceivedState extends RideDispatchState {
  final RideRequestPayloadDto request;
  final int remainingSeconds;
  RideRequestReceivedState({
    required this.request,
    required this.remainingSeconds,
  });

  RideRequestReceivedState copyWith({
    RideRequestPayloadDto? request,
    int? remainingSeconds,
  }) {
    return RideRequestReceivedState(
      request: request ?? this.request,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
}

class RideAcceptingState extends RideDispatchState {
  final RideRequestPayloadDto request;
  RideAcceptingState(this.request);
}

class ActiveTripState extends RideDispatchState {
  final String rideId;
  final RideRequestPayloadDto request;
  final String currentStatus;
  final String? statusMessage;

  ActiveTripState({
    required this.rideId,
    required this.request,
    required this.currentStatus,
    this.statusMessage,
  });

  ActiveTripState copyWith({
    String? rideId,
    RideRequestPayloadDto? request,
    String? currentStatus,
    String? statusMessage,
  }) {
    return ActiveTripState(
      rideId: rideId ?? this.rideId,
      request: request ?? this.request,
      currentStatus: currentStatus ?? this.currentStatus,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class TripCompletedSummaryState extends RideDispatchState {
  final String rideId;
  final RideRequestPayloadDto request;
  final double fare;
  final String message;

  TripCompletedSummaryState({
    required this.rideId,
    required this.request,
    required this.fare,
    required this.message,
  });
}

class RideDispatchError extends RideDispatchState {
  final String message;
  RideDispatchError(this.message);
}

class RideDispatchCubit extends Cubit<RideDispatchState> {
  RideDispatchCubit({
    required DriverRideApiService driverRideApi,
    required WebSocketService webSocketService,
    required DriverStatusCubit driverStatusCubit,
  }) : _driverRideApi = driverRideApi,
       _webSocketService = webSocketService,
       _driverStatusCubit = driverStatusCubit,
       super(RideDispatchIdle());

  final DriverRideApiService _driverRideApi;
  final WebSocketService _webSocketService;
  final DriverStatusCubit _driverStatusCubit;

  Timer? _countdownTimer;

  Future<void> checkActiveRide() async {
    try {
      final rideData = await _driverRideApi.getActiveRide();
      if (rideData != null && rideData['id'] != null) {
        final rideId = rideData['id'] as String;
        final status = rideData['status'] as String? ?? 'ACCEPTED';
        final pickupAddress = rideData['pickupAddress'] as String? ?? 'Pickup';
        final dropoffAddress =
            rideData['dropoffAddress'] as String? ?? 'Destination';
        final estimatedFare =
            (rideData['estimatedFare'] as num?)?.toDouble() ?? 0.0;
        final pickupLat = (rideData['pickupLat'] as num?)?.toDouble();
        final pickupLng = (rideData['pickupLng'] as num?)?.toDouble();
        final dropoffLat = (rideData['dropoffLat'] as num?)?.toDouble();
        final dropoffLng = (rideData['dropoffLng'] as num?)?.toDouble();
        final riderName = rideData['riderName'] as String?;

        final request = RideRequestPayloadDto(
          rideId: rideId,
          riderName: riderName,
          pickupAddress: pickupAddress,
          dropoffAddress: dropoffAddress,
          estimatedFare: estimatedFare,
          pickupLat: pickupLat,
          pickupLng: pickupLng,
          dropoffLat: dropoffLat,
          dropoffLng: dropoffLng,
        );

        await _driverStatusCubit.restoreOnRideStatus();
        subscribeToTopics();

        emit(
          ActiveTripState(
            rideId: rideId,
            request: request,
            currentStatus: status,
            statusMessage: 'Trip in progress ($status)',
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to restore active ride: $e');
    }
  }

  void subscribeToTopics() {
    // 1. Subscribe to driver ride dispatch queue
    _webSocketService.subscribe(
      destination: '/user/queue/ride-requests',
      onMessage: (data) {
        try {
          debugPrint('Received ride request: $data');
          final payload = RideRequestPayloadDto.fromJson(data);
          onRideRequestReceived(payload);
        } catch (e) {
          AppLogger.error('Failed to parse incoming ride request: $e');
        }
      },
    );

    // 2. Subscribe to ride status updates
    _webSocketService.subscribe(
      destination: '/user/queue/ride-status',
      onMessage: (data) {
        try {
          final statusPayload = RideStatusPayloadDto.fromJson(data);
          onRideStatusReceived(statusPayload);
        } catch (e) {
          AppLogger.error('Failed to parse ride status payload: $e');
        }
      },
    );
  }

  void onRideRequestReceived(RideRequestPayloadDto request) {
    if (state is ActiveTripState) return;

    _countdownTimer?.cancel();
    emit(RideRequestReceivedState(request: request, remainingSeconds: 15));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state;
      if (current is RideRequestReceivedState) {
        if (current.remainingSeconds <= 1) {
          timer.cancel();
          declineRide(current.request.rideId, isTimeout: true);
        } else {
          emit(
            current.copyWith(remainingSeconds: current.remainingSeconds - 1),
          );
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> acceptRide(RideRequestPayloadDto request) async {
    _countdownTimer?.cancel();
    emit(RideAcceptingState(request));

    try {
      // Use authoritative REST API for transactional ride acceptance
      await _driverRideApi.acceptRide(request.rideId);
      _driverStatusCubit.setOnRide();

      emit(
        ActiveTripState(
          rideId: request.rideId,
          request: request,
          currentStatus: 'ACCEPTED',
          statusMessage: 'Ride accepted. Navigate to pickup location.',
        ),
      );
    } catch (e) {
      emit(RideDispatchError('Failed to accept ride: $e'));
      Future.delayed(const Duration(seconds: 3), () {
        if (state is RideDispatchError) emit(RideDispatchIdle());
      });
    }
  }

  Future<void> declineRide(String rideId, {bool isTimeout = false}) async {
    _countdownTimer?.cancel();
    try {
      await _driverRideApi.declineRide(rideId);
    } catch (e) {
      AppLogger.error('Error declining ride: $e');
    } finally {
      emit(RideDispatchIdle());
    }
  }

  Future<void> updateStatus(String status) async {
    final current = state;
    if (current is! ActiveTripState) return;

    try {
      String? resp;
      if (_webSocketService.isConnected) {
        _webSocketService.send(
          destination: '/app/ride.status.update',
          body: {'rideId': current.rideId, 'status': status},
        );
      } else {
        resp = await _driverRideApi.updateRideStatus(
          rideId: current.rideId,
          status: status,
        );
      }


      if (status == 'COMPLETED') {
        _driverStatusCubit.setAvailable();
        emit(
          TripCompletedSummaryState(
            rideId: current.rideId,
            request: current.request,
            fare: current.request.estimatedFare,
            message: resp ?? 'Trip completed successfully!',
          ),
        );
      } else {
        emit(
          current.copyWith(
            currentStatus: status,
            statusMessage: resp ?? 'Status updated to $status',
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating ride status: ${e.apiMessage}');
      debugPrint('Stack trace: $stackTrace');
      emit(current.copyWith(statusMessage: 'Error updating status: $e'));
    }
  }

  void onRideStatusReceived(RideStatusPayloadDto payload) {
    if (payload.status == 'CANCELLED') {
      _driverStatusCubit.setAvailable();
      emit(RideDispatchIdle());
    }
  }

  void dismissTripSummary() {
    emit(RideDispatchIdle());
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    _webSocketService.unsubscribe('/user/queue/ride-requests');
    _webSocketService.unsubscribe('/user/queue/ride-status');
    return super.close();
  }
}
