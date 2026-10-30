import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_app/src/data/remote/dto/ride_dispatch_dto.dart';
import 'package:driver_app/src/modules/ride/blocs/ride_dispatch_cubit.dart';
import 'package:driver_app/src/modules/trip/utils/trip_location_utils.dart';

/// Modal bottom sheet presenting an incoming ride dispatch offer:
/// - Real-time countdown timer with urgent color transition
/// - Authoritative fare and real surge bonus (only shown if present)
/// - Authoritative trip distance and duration computed from real coordinates
/// - Timeline addresses for Pickup and Destination
/// - Real passenger details (no fabricated ratings, trips, or notes)
/// - Responsive Accept and Decline actions
class RideRequestSheet extends StatelessWidget {
  const RideRequestSheet({
    super.key,
    required this.request,
    required this.remainingSeconds,
    this.isMuted = false,
    this.onSoundToggle,
  });

  final RideRequestPayloadDto request;
  final int remainingSeconds;
  final bool isMuted;
  final VoidCallback? onSoundToggle;

  @override
  Widget build(BuildContext context) {
    final progress = (remainingSeconds / 15.0).clamp(0.0, 1.0);
    final isUrgent = remainingSeconds <= 5;

    // Real surge bonus (strictly null/zero safe)
    final hasSurge = request.surgeBonus != null && request.surgeBonus! > 0;
    final payment = request.paymentType?.trim().isNotEmpty == true
        ? request.paymentType!.trim()
        : 'Cash on Arrival';

    // Calculate real distance and duration
    final distanceMeters =
        (request.pickupLat != null &&
            request.pickupLng != null &&
            request.dropoffLat != null &&
            request.dropoffLng != null)
        ? TripLocationUtils.distanceInMeters(
            request.pickupLat!,
            request.pickupLng!,
            request.dropoffLat!,
            request.dropoffLng!,
          )
        : (request.distanceToPickupKm != null && request.distanceToPickupKm! > 0
              ? request.distanceToPickupKm! * 1000.0
              : null);

    final distanceKmText = distanceMeters != null
        ? (distanceMeters / 1000.0).toStringAsFixed(1)
        : (request.distanceToPickupKm != null && request.distanceToPickupKm! > 0
              ? request.distanceToPickupKm!.toStringAsFixed(1)
              : null);

    final durationMin =
        request.estimatedDurationMin ??
        (distanceMeters != null
            ? TripLocationUtils.estimatedDurationMinutes(distanceMeters)
            : null);

    final vehicleCat = request.vehicleCategory?.trim().isNotEmpty == true
        ? request.vehicleCategory!.trim()
        : null;

    // Passenger details - real data only
    final hasRiderName =
        request.riderName != null && request.riderName!.trim().isNotEmpty;
    final riderName = hasRiderName ? request.riderName!.trim() : 'Passenger';
    final hasRating = request.riderRating != null && request.riderRating! > 0;
    final riderRating = hasRating
        ? request.riderRating!.toStringAsFixed(1)
        : null;
    final hasTrips =
        request.riderTripsCount != null && request.riderTripsCount! > 0;
    final riderTrips = hasTrips
        ? '${request.riderTripsCount} verified trips'
        : null;
    final riderNote = request.riderNote?.trim();

    final initials = _getInitials(riderName);

    // Distance to pickup label
    final pickupDistanceText =
        request.distanceToPickupKm != null && request.distanceToPickupKm! > 0
        ? 'PICKUP'
        : 'PICKUP LOCATION';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top grab handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 1. Top Tags & Countdown Ring Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Green dispatch offer tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 14,
                            color: Color(0xFF15803D),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'DISPATCH OFFER',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF15803D),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (vehicleCat != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          vehicleCat,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Countdown Timer Ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3.5,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUrgent
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF00B4A0),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$remainingSeconds',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isUrgent
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF0F172A),
                            height: 1.0,
                          ),
                        ),
                        const Text(
                          'SEC',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 2. Fare & Surge Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Rs. ${request.estimatedFare.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (hasSurge) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Text(
                          '+Rs. ${request.surgeBonus!.toStringAsFixed(0)} Surge',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  payment,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 3. Metrics Bar Pill (if metrics are available)
            if (distanceKmText != null || durationMin != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    if (distanceKmText != null) ...[
                      const Icon(
                        Icons.route_rounded,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$distanceKmText km total',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                    if (distanceKmText != null && durationMin != null) ...[
                      const SizedBox(width: 8),
                      const Text(
                        '•',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (durationMin != null) ...[
                      const Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$durationMin min trip',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 4. Pickup & Destination Timeline
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline Icons and Connecting Line
                Column(
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 42,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: const Color(0xFFCBD5E1),
                    ),
                    const Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: Color(0xFFEF4444),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Timeline Addresses
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pickup Section
                      Text(
                        pickupDistanceText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.pickupAddress,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // Destination Section
                      const Text(
                        'DESTINATION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.dropoffAddress,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 5. Rider Info Card (Only real data shown)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Rider Avatar with Initials
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF132226),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Rider Name & Trips / Rating
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              riderName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (riderTrips != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                riderTrips,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Rider Rating (only if real rating > 0)
                      if (riderRating != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                riderRating,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Optional Real Rider Note
                  if (riderNote != null && riderNote.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.sticky_note_2_outlined,
                            size: 14,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Note: "$riderNote"',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF92400E),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 6. Action Buttons: Decline & Accept
            Row(
              children: [
                // Decline Button
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<RideDispatchCubit>().declineRide(
                        request.rideId,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                        color: Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Decline',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Accept Ride Button
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<RideDispatchCubit>().acceptRide(request);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF132A2F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide.none,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ACCEPT (${remainingSeconds}s)',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
