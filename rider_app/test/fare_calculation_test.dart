import 'package:flutter_test/flutter_test.dart';

// Standalone verification of the fare calculation formula used in RideBookingSheet and Backend
double calculateTierFare({
  required double baseFareNpr,
  required double perKmRate,
  required double minFareNpr,
  required double distanceKm,
}) {
  final distance = distanceKm > 0 ? distanceKm : 1.0;
  final rawFare = baseFareNpr + (distance * perKmRate);
  return rawFare.clamp(minFareNpr, 99999.0).roundToDouble();
}

// Backend formula for reference:
// double rawFare = baseFare + (distanceKm * perKm);
// double finalFare = Math.max(rawFare, minFare);
// return Math.round(finalFare);
int calculateBackendFare({
  required double baseFare,
  required double perKm,
  required double minFare,
  required double distanceKm,
}) {
  final rawFare = baseFare + (distanceKm * perKm);
  final finalFare = rawFare < minFare ? minFare : rawFare;
  return finalFare.round();
}

void main() {
  group('Fare Calculation Consistency (Frontend vs Backend)', () {
    test('Bike tier: 6.4 km must calculate to 132 in both frontend and backend', () {
      const baseFare = 30.0;
      const perKm = 16.0;
      const minFare = 45.0;
      const distanceKm = 6.4;

      final frontendFare = calculateTierFare(
        baseFareNpr: baseFare,
        perKmRate: perKm,
        minFareNpr: minFare,
        distanceKm: distanceKm,
      );

      final backendFare = calculateBackendFare(
        baseFare: baseFare,
        perKm: perKm,
        minFare: minFare,
        distanceKm: distanceKm,
      );

      expect(frontendFare, equals(132.0));
      expect(backendFare, equals(132));
      expect(frontendFare.toInt(), equals(backendFare));
    });

    test('Bike tier: Minimum fare clamp for short distances (0.5 km)', () {
      const baseFare = 30.0;
      const perKm = 16.0;
      const minFare = 45.0;
      const distanceKm = 0.5;

      final frontendFare = calculateTierFare(
        baseFareNpr: baseFare,
        perKmRate: perKm,
        minFareNpr: minFare,
        distanceKm: distanceKm,
      );

      final backendFare = calculateBackendFare(
        baseFare: baseFare,
        perKm: perKm,
        minFare: minFare,
        distanceKm: distanceKm,
      );

      expect(frontendFare, equals(45.0));
      expect(backendFare, equals(45));
    });

    test('Comfort tier (PREMIUM): 6.4 km calculates identically in frontend and backend', () {
      const baseFare = 150.0;
      const perKm = 45.0;
      const minFare = 150.0;
      const distanceKm = 6.4;

      final frontendFare = calculateTierFare(
        baseFareNpr: baseFare,
        perKmRate: perKm,
        minFareNpr: minFare,
        distanceKm: distanceKm,
      );

      final backendFare = calculateBackendFare(
        baseFare: baseFare,
        perKm: perKm,
        minFare: minFare,
        distanceKm: distanceKm,
      );

      expect(frontendFare, equals(438.0));
      expect(backendFare, equals(438));
    });

    test('XL tier: 6.4 km calculates identically in frontend and backend', () {
      const baseFare = 200.0;
      const perKm = 55.0;
      const minFare = 200.0;
      const distanceKm = 6.4;

      final frontendFare = calculateTierFare(
        baseFareNpr: baseFare,
        perKmRate: perKm,
        minFareNpr: minFare,
        distanceKm: distanceKm,
      );

      final backendFare = calculateBackendFare(
        baseFare: baseFare,
        perKm: perKm,
        minFare: minFare,
        distanceKm: distanceKm,
      );

      expect(frontendFare, equals(552.0));
      expect(backendFare, equals(552));
    });
  });
}

