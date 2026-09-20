import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/map_utils.dart';

/// Reusable Google Map view component styled for Rider and Driver apps.
class CustomMapView extends StatefulWidget {
  final LatLng initialCameraPosition;
  final double initialZoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Circle> circles;
  final void Function(GoogleMapController)? onMapCreated;
  final void Function(LatLng)? onTap;
  final void Function(CameraPosition)? onCameraMove;
  final void Function()? onCameraIdle;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final EdgeInsets padding;
  final String? customMapStyleAsset;

  const CustomMapView({
    super.key,
    required this.initialCameraPosition,
    this.initialZoom = 15.0,
    this.markers = const {},
    this.polylines = const {},
    this.circles = const {},
    this.onMapCreated,
    this.onTap,
    this.onCameraMove,
    this.onCameraIdle,
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = false,
    this.zoomControlsEnabled = false,
    this.padding = EdgeInsets.zero,
    this.customMapStyleAsset,
  });

  @override
  State<CustomMapView> createState() => _CustomMapViewState();
}

class _CustomMapViewState extends State<CustomMapView> {
  GoogleMapController? _controller;

  @override
  void didUpdateWidget(covariant CustomMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customMapStyleAsset != oldWidget.customMapStyleAsset &&
        _controller != null &&
        widget.customMapStyleAsset != null) {
      MapUtils.setMapStyle(_controller!, widget.customMapStyleAsset!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultStyle = widget.customMapStyleAsset ??
        (isDark ? 'packages/shared_core/assets/mapTheme/darkMap.json' : null);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialCameraPosition,
        zoom: widget.initialZoom,
      ),
      markers: widget.markers,
      polylines: widget.polylines,
      circles: widget.circles,
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      padding: widget.padding,
      onTap: widget.onTap,
      onCameraMove: widget.onCameraMove,
      onCameraIdle: widget.onCameraIdle,
      onMapCreated: (controller) {
        _controller = controller;
        if (defaultStyle != null) {
          MapUtils.setMapStyle(controller, defaultStyle);
        }
        widget.onMapCreated?.call(controller);
      },
    );
  }
}
