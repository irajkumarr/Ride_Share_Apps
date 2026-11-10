import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Interactive Google Map widget tailored for ride operations.
class RideMap extends StatelessWidget {
  final LatLng initialCameraPosition;
  final double initialZoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final double bottomPadding;
  final MapCreatedCallback onMapCreated;
  final CameraPositionCallback? onCameraMove;
  final VoidCallback? onCameraIdle;

  const RideMap({
    super.key,
    required this.initialCameraPosition,
    this.initialZoom = 15.5,
    required this.markers,
    required this.polylines,
    required this.bottomPadding,
    required this.onMapCreated,
    this.onCameraMove,
    this.onCameraIdle,
  });

  @override
  Widget build(BuildContext context) {
    return CustomMapView(
      initialCameraPosition: initialCameraPosition,
      initialZoom: initialZoom,
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 55,
        bottom: bottomPadding,
        left: 24,
        right: 24,
      ),
      onMapCreated: onMapCreated,
      onCameraMove: onCameraMove,
      onCameraIdle: onCameraIdle,
    );
  }
}
