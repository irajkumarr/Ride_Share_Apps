import 'package:equatable/equatable.dart';
import 'lat_lng_model.dart';

/// Represents a navigation/trip route polyline with distance and ETA.
class RouteModel extends Equatable {
  final List<LatLngModel> points;
  final double distanceInMeters;
  final double durationInSeconds;
  final String? encodedPolyline;

  const RouteModel({
    required this.points,
    required this.distanceInMeters,
    required this.durationInSeconds,
    this.encodedPolyline,
  });

  String get formattedDistance {
    if (distanceInMeters >= 1000) {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
    return '${distanceInMeters.toStringAsFixed(0)} m';
  }

  String get formattedDuration {
    final minutes = (durationInSeconds / 60).round();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMins = minutes % 60;
      return remainingMins > 0 ? '$hours hr $remainingMins min' : '$hours hr';
    }
    return '$minutes min';
  }

  @override
  List<Object?> get props => [
        points,
        distanceInMeters,
        durationInSeconds,
        encodedPolyline,
      ];
}
