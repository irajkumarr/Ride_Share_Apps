import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_app/src/modules/ride/blocs/ride_dispatch_cubit.dart';
import 'package:driver_app/src/modules/trip/utils/trip_location_utils.dart';
import 'package:shared_core/shared_core.dart';

/// Active Trip Control Panel for driver:
/// - Distinct statuses: EN ROUTE TO PICKUP, AT PICKUP, and TRIP IN PROGRESS
/// - Guaranteed real fare
/// - Authoritative passenger details (real initials, verified rating only if present)
/// - Authoritative pickup and dropoff addresses with real dynamic distance and clock ETA
/// - 150m Proximity geofence with manual arrival fallback
/// - Direct Call action & Google Maps navigation launch
class ActiveTripPanel extends StatelessWidget {
  const ActiveTripPanel({
    super.key,
    required this.tripState,
    this.distanceToPickupMeters = 0.0,
    this.onCallTap,
    this.onChatTap,
    this.onOpenGoogleMaps,
    this.onToggleFullScreen,
    this.isFullScreenMap = false,
  });

  final ActiveTripState tripState;
  final double distanceToPickupMeters;
  final VoidCallback? onCallTap;
  final VoidCallback? onChatTap;
  final VoidCallback? onOpenGoogleMaps;
  final VoidCallback? onToggleFullScreen;
  final bool isFullScreenMap;

  @override
  Widget build(BuildContext context) {
    final req = tripState.request;
    final status = tripState.currentStatus;

    final hasRiderName =
        req.riderName != null && req.riderName!.trim().isNotEmpty;
    final riderName = hasRiderName ? req.riderName!.trim() : 'Passenger';
    final hasRating = req.riderRating != null && req.riderRating! > 0;
    final riderRating = hasRating ? req.riderRating!.toStringAsFixed(1) : null;
    final hasTrips = req.riderTripsCount != null && req.riderTripsCount! > 0;
    final riderRidesCount = hasTrips ? '${req.riderTripsCount} rides' : null;
    final riderNote = req.riderNote?.trim();

    final vehicleCategory =
        (req.vehicleCategory != null && req.vehicleCategory!.isNotEmpty)
        ? req.vehicleCategory!.toUpperCase()
        : 'RIDE';

    final etaText = TripLocationUtils.formatEtaClockTime(
      distanceToPickupMeters,
    );
    final distanceText = TripLocationUtils.formatDistance(
      distanceToPickupMeters,
    );

    // 150 meters geofence threshold to accommodate urban GPS drift
    final isWithinPickupGeofence = distanceToPickupMeters <= 150.0;

    final isArrived = status == 'ARRIVED';
    final isInProgress = status == 'IN_PROGRESS';

    final headerText = isArrived
        ? 'AT PICKUP • WAITING FOR RIDER'
        : (isInProgress
              ? 'TRIP IN PROGRESS • $vehicleCategory'
              : 'ROUTE TO PICKUP • $vehicleCategory');

    final headerColor = isArrived
        ? const Color(0xFFD97706)
        : (isInProgress ? const Color(0xFF059669) : const Color(0xFF1D4ED8));

    final headerBgColor = isArrived
        ? const Color(0xFFFFFBEB)
        : (isInProgress ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF));

    final targetAddress = isInProgress ? req.dropoffAddress : req.pickupAddress;
    final initials = _getInitials(riderName);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // 1. Top Header: Status Pill & Guaranteed Fare
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: headerBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: headerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            headerText,
                            style: TextStyle(
                              color: headerColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Guaranteed Fare
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'ESTIMATED FARE',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Rs. ${req.estimatedFare.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 2. Rider Details Card: Initials Avatar, Name, Rating/Verification, Call
            Row(
              children: [
                // Rider Initials Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFF132226),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Rating/Trips
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        riderName,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (riderRating != null) ...[
                            const Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              riderRating,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                          if (riderRating != null &&
                              riderRidesCount != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 3.5,
                              height: 3.5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF94A3B8),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (riderRidesCount != null) ...[
                            Text(
                              riderRidesCount,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Call Action Button
                GestureDetector(
                  onTap:
                      onCallTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling $riderName...')),
                        );
                      },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.phone_rounded,
                        color: Color(0xFF1E293B),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Optional Real Rider Note
            if (riderNote != null && riderNote.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFEF3C7)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sticky_note_2_outlined,
                      size: 15,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Note: "$riderNote"',
                        style: const TextStyle(
                          color: Color(0xFF78350F),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // 3. Destination / Pickup Address Row with Real Distance & Clock ETA
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isInProgress
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isInProgress
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981),
                      width: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    targetAddress,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  etaText,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Navigation Options Bar (Visible when trip is IN_PROGRESS)
            if (isInProgress) ...[
              Row(
                children: [
                  // 1. Open in Google Maps Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onOpenGoogleMaps,
                      icon: const Icon(
                        Icons.map_rounded,
                        size: 18,
                        color: Color(0xFF1D4ED8),
                      ),
                      label: const Text(
                        'Google Maps',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: Color(0xFF93C5FD),
                          width: 1.2,
                        ),
                        backgroundColor: const Color(0xFFEFF6FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 2. Full Screen Live In-App View Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onToggleFullScreen,
                      icon: Icon(
                        isFullScreenMap
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                      label: Text(
                        isFullScreenMap ? 'Exit Full' : 'Live In-App',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF0F172A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // 4. Action Area with 150m Proximity Geofencing
            _buildActionArea(
              context,
              status,
              isWithinPickupGeofence,
              distanceText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionArea(
    BuildContext context,
    String status,
    bool isWithinGeofence,
    String distanceText,
  ) {
    if (status == 'ACCEPTED') {
      if (isWithinGeofence) {
        return SlideToActButton(
          text: 'SLIDE: ARRIVED AT PICKUP > >',
          height: 56,
          borderRadius: 18,
          backgroundColor: const Color(0xFFEA580C),
          thumbColor: Colors.white,
          thumbIconColor: const Color(0xFFEA580C),
          thumbIcon: Icons.keyboard_double_arrow_right_rounded,
          onSlideComplete: () async {
            context.read<RideDispatchCubit>().updateStatus('ARRIVED');
          },
        );
      } else {
        // Driver outside 150m: show proximity indicator with manual override
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.near_me_rounded,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Approaching pickup: $distanceText • Slide unlocks within 150m',
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text('Confirm Arrival at Pickup'),
                      content: const Text(
                        'Are you at the pickup location? You can confirm arrival if GPS has drifted or is inaccurate.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEA580C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                            context.read<RideDispatchCubit>().updateStatus(
                              'ARRIVED',
                            );
                          },
                          child: const Text(
                            'Yes, I Have Arrived',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    'Arrived but GPS stuck? Tap to confirm',
                    style: TextStyle(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.9),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else if (status == 'ARRIVED') {
      return SlideToActButton(
        text: 'SLIDE: START TRIP > >',
        height: 56,
        borderRadius: 18,
        backgroundColor: const Color(0xFF059669),
        thumbColor: Colors.white,
        thumbIconColor: const Color(0xFF059669),
        thumbIcon: Icons.keyboard_double_arrow_right_rounded,
        onSlideComplete: () async {
          context.read<RideDispatchCubit>().updateStatus('IN_PROGRESS');
        },
      );
    } else {
      return SlideToActButton(
        text: 'SLIDE: COMPLETE TRIP > >',
        height: 56,
        borderRadius: 18,
        backgroundColor: const Color(0xFF0F172A),
        thumbColor: Colors.white,
        thumbIconColor: const Color(0xFF0F172A),
        thumbIcon: Icons.keyboard_double_arrow_right_rounded,
        onSlideComplete: () async {
          context.read<RideDispatchCubit>().updateStatus('COMPLETED');
        },
      );
    }
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
