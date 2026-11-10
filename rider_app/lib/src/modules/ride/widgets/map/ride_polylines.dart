import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Helper methods to generate [Polyline] sets for route preview and navigation.
class RidePolylines {
  const RidePolylines._();

  static Polyline createBackdropPolyline({
    required List<LatLng> points,
    Color color = Colors.black,
    double width = 7.0,
  }) {
    return Polyline(
      polylineId: const PolylineId('trip_route_backdrop'),
      points: points,
      color: color,
      width: width.round(),
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
  }

  static Polyline createActiveRoutePolyline({
    required List<LatLng> points,
    Color color = const Color(0xFF0F172A),
    double width = 5.0,
  }) {
    return Polyline(
      polylineId: const PolylineId('trip_route_line'),
      points: points,
      color: color,
      width: width.round(),
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
  }

  static Set<Polyline> buildAnimatedRoutePolylines({
    required List<LatLng> fullRoutePoints,
    required List<LatLng> animatedCurrentPoints,
  }) {
    return {
      createBackdropPolyline(
        points: fullRoutePoints,
        color: const Color(0xFFE2E8F0),
        width: 7,
      ),
      createActiveRoutePolyline(
        points: animatedCurrentPoints,
        color: const Color(0xFF0F172A),
        width: 5,
      ),
    };
  }

  static Set<Polyline> buildStaticRoutePolylines({
    required List<LatLng> points,
    Color color = Colors.black,
    double width = 5,
  }) {
    if (points.isEmpty) return {};
    return {
      createActiveRoutePolyline(points: points, color: color, width: width),
    };
  }
}
