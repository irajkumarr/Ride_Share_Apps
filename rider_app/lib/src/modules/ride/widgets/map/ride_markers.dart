import 'dart:ui';

import 'package:shared_core/shared_core.dart';

import '../../../../data/remote/ride_api_service.dart';

/// Helper methods to generate [Marker] instances for the ride lifecycle.
class RideMarkers {
  const RideMarkers._();

  static Marker createPickupMarker({
    required LatLng position,
    required String title,
  }) {
    return Marker(
      markerId: const MarkerId('pickup_marker'),
      position: position,
      infoWindow: InfoWindow(title: 'Pickup', snippet: title),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
  }

  static Marker createDestinationMarker({
    required LatLng position,
    required String title,
  }) {
    return Marker(
      markerId: const MarkerId('destination_marker'),
      position: position,
      infoWindow: InfoWindow(title: 'Destination', snippet: title),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }

  static Marker createDriverMarker({
    required LatLng position,
    required DriverModel driver,
    double heading = 0.0,
    BitmapDescriptor? icon,
  }) {
    return Marker(
      markerId: const MarkerId('driver_marker'),
      position: position,
      rotation: heading,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      zIndexInt: 5,
      infoWindow: InfoWindow(
        title: driver.name,
        snippet:
            '${driver.vehicleColor} ${driver.vehicleModel} (${driver.licensePlate})',
      ),
      icon:
          icon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
  }

  static Set<Marker> buildPreviewMarkers({
    required LatLng pickup,
    required String pickupTitle,
    required LatLng destination,
    required String destinationTitle,
  }) {
    return {
      createPickupMarker(position: pickup, title: pickupTitle),
      createDestinationMarker(position: destination, title: destinationTitle),
    };
  }

  static Set<Marker> buildDriverAssignedMarkers({
    required LatLng driverPosition,
    required DriverModel driver,
    double driverHeading = 0.0,
    BitmapDescriptor? driverIcon,
    required LatLng pickup,
    required String pickupTitle,
    required LatLng destination,
    required String destinationTitle,
    bool isTripInProgress = false,
  }) {
    final driverMarker = createDriverMarker(
      position: driverPosition,
      driver: driver,
      heading: driverHeading,
      icon: driverIcon,
    );
    final destMarker = createDestinationMarker(
      position: destination,
      title: destinationTitle,
    );

    if (isTripInProgress) {
      return {driverMarker, destMarker};
    }

    return {
      driverMarker,
      createPickupMarker(position: pickup, title: pickupTitle),
      destMarker,
    };
  }
}
