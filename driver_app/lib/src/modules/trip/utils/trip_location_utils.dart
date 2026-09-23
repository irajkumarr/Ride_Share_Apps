import 'dart:math' as math;

/// Utility calculations for driver trip proximity, headings, and formatting
class TripLocationUtils {
  TripLocationUtils._();

  /// Calculates straight-line distance in meters between two coordinates using the Haversine formula.
  static double distanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0; // Earth's radius in meters
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);

  /// Returns user-friendly distance string (e.g. "85 m away" or "1.2 km away")
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m away';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km away';
    }
  }

  /// Estimated arrival time string given remaining distance in meters (assumes average city speed ~25 km/h)
  static String formatEtaClockTime(double meters) {
    final speedMps = 25 * 1000 / 3600; // ~6.94 m/s
    final seconds = (meters / speedMps).round();
    final arrival = DateTime.now().add(Duration(seconds: seconds));
    final hour = arrival.hour.toString().padLeft(2, '0');
    final minute = arrival.minute.toString().padLeft(2, '0');
    return 'ETA $hour:$minute';
  }

  /// Estimated duration in minutes (minimum 1 min)
  static int estimatedDurationMinutes(double meters) {
    final speedMps = 25 * 1000 / 3600;
    final mins = (meters / speedMps / 60).round();
    return mins < 1 ? 1 : mins;
  }
}
