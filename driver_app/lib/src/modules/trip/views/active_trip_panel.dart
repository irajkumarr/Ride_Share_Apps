import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_app/src/data/remote/dto/ride_dispatch_dto.dart';
import 'package:driver_app/src/modules/ride/blocs/ride_dispatch_cubit.dart';
import 'package:driver_app/src/modules/trip/utils/trip_location_utils.dart';
import 'package:shared_core/shared_core.dart';

/// Redesigned Active Trip Control Card matching the screenshot:
/// - Top status & guaranteed fare:
///   [ • EN ROUTE TO PICKUP • BIKE RIDE ] and [GUARANTEED FARE  Rs. 185]
/// - Rider details row:
///   Photo thumbnail with [VIP] badge, "Aarav Shrestha", "★ 4.9 • 124 rides", Call button, Chat button (with unread badge)
/// - Rider note banner:
///   ✨ Rider Note: "Waiting near the main entrance gate"
/// - Route pickup timeline address:
///   Green circle + "Gatthaghar, Madhyapur Thimi-03 (Near Ci...  ETA 12:20"
/// - **100m Proximity Trigger**:
///   The slide button [SLIDE: ARRIVED AT PICKUP > >] is visible only when the driver is within 100 meters of pickup.
///   If outside 100m, an informative proximity lock pill is displayed indicating the remaining distance to unlock.
class ActiveTripPanel extends StatelessWidget {
  const ActiveTripPanel({
    super.key,
    required this.tripState,
    this.distanceToPickupMeters = 1200.0,
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

    final riderName =
        (req.riderName != null && req.riderName!.trim().isNotEmpty)
        ? req.riderName!.trim()
        : 'Aarav Shrestha';
    final riderRating = (req.riderRating != null && req.riderRating! > 0)
        ? req.riderRating!.toStringAsFixed(1)
        : '4.9';
    final riderRidesCount = req.riderTripsCount ?? 124;
    final riderNote =
        (req.riderNote != null && req.riderNote!.trim().isNotEmpty)
        ? req.riderNote!
        : 'Waiting near the main entrance gate';
    final vehicleCategory =
        (req.vehicleCategory != null && req.vehicleCategory!.isNotEmpty)
        ? req.vehicleCategory!.toUpperCase()
        : 'BIKE RIDE';

    final etaText = TripLocationUtils.formatEtaClockTime(
      distanceToPickupMeters,
    );
    final distanceText = TripLocationUtils.formatDistance(
      distanceToPickupMeters,
    );

    // Geofence check: Must be within 100 meters to slide "ARRIVED AT PICKUP"
    final isWithinPickupGeofence = distanceToPickupMeters <= 100.0;

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
                // Blue Pill: [• EN ROUTE TO PICKUP • BIKE RIDE]
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            status == 'ARRIVED'
                                ? 'AT PICKUP LOCATION • $vehicleCategory'
                                : (status == 'IN_PROGRESS'
                                      ? 'TRIP IN PROGRESS • $vehicleCategory'
                                      : 'EN ROUTE TO PICKUP • $vehicleCategory'),
                            style: const TextStyle(
                              color: Color(0xFF1D4ED8),
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

                // Fare Display: [GUARANTEED FARE  Rs. 185]
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GUARANTEED FARE',
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
            const SizedBox(height: 16),

            // 2. Rider Details Card: Portrait, Name, Rating, Call, Chat
            Row(
              children: [
                // Rider Portrait with VIP Tag
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFE2E8F0),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/rider_portrait.jpg'),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D4ED8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Text(
                          'VIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Name & Rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        riderName,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            riderRating,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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
                          Text(
                            '$riderRidesCount rides',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.phone_outlined,
                        color: Color(0xFF1E293B),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Chat Action Button with unread notification badge
                // GestureDetector(
                //   onTap:
                //       onChatTap ??
                //       () {
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           SnackBar(
                //             content: Text('Opening chat with $riderName...'),
                //           ),
                //         );
                //       },
                //   child: Stack(
                //     clipBehavior: Clip.none,
                //     children: [
                //       Container(
                //         width: 46,
                //         height: 46,
                //         decoration: BoxDecoration(
                //           color: const Color(0xFFEFF6FF),
                //           borderRadius: BorderRadius.circular(16),
                //           border: Border.all(color: const Color(0xFFBFDBFE)),
                //         ),
                //         child: const Center(
                //           child: Icon(
                //             Icons.chat_bubble_outline_rounded,
                //             color: Color(0xFF2563EB),
                //             size: 20,
                //           ),
                //         ),
                //       ),
                //       Positioned(
                //         top: -3,
                //         right: -3,
                //         child: Container(
                //           width: 17,
                //           height: 17,
                //           decoration: BoxDecoration(
                //             color: const Color(0xFFEA580C),
                //             shape: BoxShape.circle,
                //             border: Border.all(color: Colors.white, width: 2),
                //           ),
                //           child: const Center(
                //             child: Text(
                //               '1',
                //               style: TextStyle(
                //                 color: Colors.white,
                //                 fontSize: 9,
                //                 fontWeight: FontWeight.w900,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 14),

            // 3. Rider Note Banner
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFFFFFBEB),
            //     borderRadius: BorderRadius.circular(14),
            //     border: Border.all(color: const Color(0xFFFEF3C7)),
            //   ),
            //   child: Row(
            //     children: [
            //       const Icon(
            //         Icons.auto_awesome_rounded,
            //         size: 16,
            //         color: Color(0xFFD97706),
            //       ),
            //       const SizedBox(width: 8),
            //       const Text(
            //         'Rider Note:',
            //         style: TextStyle(
            //           color: Color(0xFFB45309),
            //           fontSize: 12,
            //           fontWeight: FontWeight.w900,
            //         ),
            //       ),
            //       const SizedBox(width: 5),
            //       Expanded(
            //         child: Text(
            //           '"$riderNote"',
            //           style: const TextStyle(
            //             color: Color(0xFF78350F),
            //             fontSize: 12,
            //             fontWeight: FontWeight.w600,
            //           ),
            //           maxLines: 1,
            //           overflow: TextOverflow.ellipsis,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 12),

            // 4. Pickup Address Timeline Row
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF10B981),
                      width: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    status == 'IN_PROGRESS'
                        ? req.dropoffAddress
                        : req.pickupAddress,
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
            const SizedBox(height: 16),

            // Navigation Options Bar (Visible when trip is IN_PROGRESS)
            if (status == 'IN_PROGRESS') ...[
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
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            // 5. Action Area with 100m Proximity Geofencing
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
      // REQUIREMENT: That slide button should only be visible after the driver is near 100m from pickup point.
      if (isWithinGeofence) {
        return SlideToActButton(
          text: 'SLIDE: ARRIVED AT PICKUP > >',
          height: 58,
          borderRadius: 20,
          backgroundColor: const Color(0xFFEA580C),
          thumbColor: Colors.white,
          thumbIconColor: Color(0xFFEA580C),
          thumbIcon: Icons.keyboard_double_arrow_right_rounded,
          onSlideComplete: () async {
            context.read<RideDispatchCubit>().updateStatus('ARRIVED');
          },
        );
      } else {
        // Driver is still more than 100m away -> Show locked proximity indicator
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.near_me_rounded,
                size: 18,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Approaching pickup: $distanceText • Slide unlocks within 100m',
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }
    } else if (status == 'ARRIVED') {
      // Driver at pickup -> Slide to start trip
      return SlideToActButton(
        text: 'SLIDE: START TRIP > >',
        height: 58,
        borderRadius: 20,
        backgroundColor: const Color(0xFF059669),
        thumbColor: Colors.white,
        thumbIconColor: const Color(0xFF059669),
        thumbIcon: Icons.keyboard_double_arrow_right_rounded,
        onSlideComplete: () async {
          context.read<RideDispatchCubit>().updateStatus('IN_PROGRESS');
        },
      );
    } else {
      // Trip in progress -> Slide to complete trip
      return SlideToActButton(
        text: 'SLIDE: COMPLETE TRIP > >',
        height: 58,
        borderRadius: 20,
        backgroundColor: const Color(0xFF0F172A),
        thumbColor: Colors.white,
        thumbIconColor: Color(0xFF0F172A),
        thumbIcon: Icons.keyboard_double_arrow_right_rounded,
        onSlideComplete: () async {
          context.read<RideDispatchCubit>().updateStatus('COMPLETED');
        },
      );
    }
  }
}
