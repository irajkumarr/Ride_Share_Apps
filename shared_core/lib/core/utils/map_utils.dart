import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/location/lat_lng_model.dart';

/// Helper utilities for Google Maps operations like markers, styling, bounds, and coordinates.
class MapUtils {
  MapUtils._();

  /// Converts [LatLngModel] to Google Maps [LatLng].
  static LatLng toGoogleLatLng(LatLngModel model) {
    return LatLng(model.latitude, model.longitude);
  }

  /// Converts Google Maps [LatLng] to [LatLngModel].
  static LatLngModel fromGoogleLatLng(LatLng latLng, {double? heading, double? speed}) {
    return LatLngModel(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
      heading: heading,
      speed: speed,
    );
  }

  /// Loads map theme JSON from asset path into [GoogleMapController].
  static Future<void> setMapStyle(GoogleMapController controller, String assetPath) async {
    try {
      final style = await rootBundle.loadString(assetPath);
      // ignore: deprecated_member_use
      await controller.setMapStyle(style);
    } catch (_) {
      // Graceful fallback if style fails to load
    }
  }

  /// Calculates the Haversine distance in kilometers between two [LatLngModel] coordinates.
  static double calculateDistance(LatLngModel start, LatLngModel end) {
    const double earthRadiusKm = 6371.0;
    final double dLat = (end.latitude - start.latitude) * (math.pi / 180.0);
    final double dLng = (end.longitude - start.longitude) * (math.pi / 180.0);

    final double lat1Rad = start.latitude * (math.pi / 180.0);
    final double lat2Rad = end.latitude * (math.pi / 180.0);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Calculates a [LatLngBounds] containing all points in [coordinates]
  /// with a safety margin to avoid zero-delta bounds on single points or identical coordinates.
  static LatLngBounds boundsFromLatLngList(List<LatLng> coordinates) {
    assert(coordinates.isNotEmpty, 'coordinates list must not be empty');

    double x0 = coordinates.first.latitude;
    double x1 = coordinates.first.latitude;
    double y0 = coordinates.first.longitude;
    double y1 = coordinates.first.longitude;

    for (final latLng in coordinates) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }

    // Guard against identical / single point bounds where northeast == southwest
    if ((x1 - x0).abs() < 0.0001 && (y1 - y0).abs() < 0.0001) {
      x0 -= 0.002;
      x1 += 0.002;
      y0 -= 0.002;
      y1 += 0.002;
    }

    return LatLngBounds(
      northeast: LatLng(x1, y1),
      southwest: LatLng(x0, y0),
    );
  }

  /// Smoothly animates the camera to fit all [points] within the visible viewport,
  /// accounting for bottom sheet height, top bars, and safe margins across all screen sizes.
  static Future<void> animateCameraToBounds(
    GoogleMapController controller, {
    required List<LatLng> points,
    double topPadding = 80.0,
    double bottomPadding = 300.0,
    double horizontalPadding = 40.0,
  }) async {
    if (points.isEmpty) return;
    try {
      final bounds = boundsFromLatLngList(points);
      // Double-pass animation for optimal LatLngBounds fitting with custom edge insets
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, horizontalPadding),
      );
    } catch (_) {}
  }

  /// Creates a [BitmapDescriptor] from custom bytes (e.g. SVG or resized PNG).
  static Future<BitmapDescriptor> getMarkerIconFromAsset(
    String path, {
    int width = 96,
  }) async {
    final byteData = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: width,
    );
    final frameInfo = await codec.getNextFrame();
    final byteDataResized = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteDataResized!.buffer.asUint8List();
    return BitmapDescriptor.bytes(bytes);
  }

  /// Launches external Google Maps with turn-by-turn navigation from [origin] (or current position)
  /// to [destination] (e.g. pickup or destination lat/lng).
  static Future<bool> launchGoogleMapsNavigation({
    required double destLat,
    required double destLng,
    double? originLat,
    double? originLng,
  }) async {
    final String url;
    if (originLat != null && originLng != null) {
      url =
          'https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$destLat,$destLng&travelmode=driving';
    } else {
      url =
          'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=driving';
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }
}
