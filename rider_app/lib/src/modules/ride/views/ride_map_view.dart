import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import '../../../data/remote/ride_api_service.dart';
import '../../home/blocs/active_ride_cubit.dart';
import '../widgets/map/map_controls.dart';
import '../widgets/map/radar_overlay.dart';
import '../widgets/map/ride_map.dart';
import 'ride_state_overlay.dart';

/// Interactive map view with contextual pins, dynamic badges, and floating controls
/// reflecting the real-time ride state.
class RideMapView extends StatelessWidget {
  final ActiveRideState activeState;
  final LatLng initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final double bottomSheetHeight;
  final Offset? destinationScreenOffset;
  final Offset? pickupScreenOffset;
  final Offset? driverScreenOffset;
  final Animation<double> radarAnimation;
  final int? liveEtaMinutes;
  final double? liveDistanceKm;
  final MapCreatedCallback onMapCreated;
  final CameraPositionCallback onCameraMove;
  final VoidCallback onCameraIdle;
  final VoidCallback onClearTrip;
  final VoidCallback onFinishTrip;
  final VoidCallback onRecenter;

  const RideMapView({
    super.key,
    required this.activeState,
    required this.initialCameraPosition,
    required this.markers,
    required this.polylines,
    required this.bottomSheetHeight,
    required this.destinationScreenOffset,
    required this.pickupScreenOffset,
    required this.driverScreenOffset,
    required this.radarAnimation,
    this.liveEtaMinutes,
    this.liveDistanceKm,
    required this.onMapCreated,
    required this.onCameraMove,
    required this.onCameraIdle,
    required this.onClearTrip,
    required this.onFinishTrip,
    required this.onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    final bottomControlsOffset = bottomSheetHeight + 16.0;

    return Stack(
      children: [
        // 1. Interactive Google Map
        RideMap(
          initialCameraPosition: initialCameraPosition,
          initialZoom: 15.5,
          markers: markers,
          polylines: polylines,
          bottomPadding: bottomControlsOffset,
          onMapCreated: onMapCreated,
          onCameraMove: onCameraMove,
          onCameraIdle: onCameraIdle,
        ),

        // 2. Radar scan rings & pickup pin during Driver Searching
        if (activeState is DriverSearching) ...[
          DriverSearchingRadar(
            animation: radarAnimation,
            centerOffset: pickupScreenOffset,
          ),
          PickupPersonPinCallout(screenOffset: pickupScreenOffset),
        ],

        // 3. Floating top bar controls & map markers for Driver Assigned
        if (activeState case final DriverAssignedState driverAssigned) ...[
          TopCircularBackButton(onPressed: onClearTrip),

          if (driverAssigned.booking.status == RideStatus.tripInProgress) ...[
            OnTripHeaderBadge(licensePlate: driverAssigned.driver.licensePlate),
            DestinationFlagPin(
              screenOffset: destinationScreenOffset,
              destinationTitle: driverAssigned.booking.destination.title,
              etaMinutes: liveEtaMinutes,
              distanceKm: liveDistanceKm,
            ),
          ] else if (driverAssigned.booking.status ==
              RideStatus.driverArriving) ...[
            DriverArrivedHeaderBadge(
              licensePlate: driverAssigned.driver.licensePlate,
            ),
          ] else ...[
            // ApproachingMotorcycleMarker(screenOffset: driverScreenOffset),
          ],
        ],

        // 4. Floating top controls for Trip Completed
        if (activeState case final TripCompletedState completed) ...[
          TopCircularBackButton(onPressed: onFinishTrip),
          TopCircularCloseButton(onPressed: onFinishTrip),
          TripCompletedHeaderBadge(
            licensePlate: completed.driver?.licensePlate ?? '',
          ),
        ],

        // 5. Floating destination ETA callout pin for Route Preview
        if (activeState case final RoutePreviewReady preview) ...[
          DestinationEtaCallout(
            screenOffset: destinationScreenOffset,
            durationMins: preview.durationMins,
          ),
        ],

        // 6. Floating Back Button for preview and searching states
        if (activeState is! DriverAssignedState &&
            activeState is! TripCompletedState) ...[
          FloatingMapBackButton(
            bottomOffset: bottomControlsOffset,
            onPressed: onClearTrip,
          ),
        ],

        // 7. Floating GPS recenter button
        if (activeState is DriverSearching ||
            activeState is DriverAssignedState ||
            activeState is RoutePreviewReady) ...[
          FloatingRecenterButton(
            bottomOffset: bottomControlsOffset,
            onPressed: onRecenter,
          ),
        ],
      ],
    );
  }
}
