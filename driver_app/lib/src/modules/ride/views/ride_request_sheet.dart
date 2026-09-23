import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_app/src/data/remote/dto/ride_dispatch_dto.dart';
import 'package:driver_app/src/modules/ride/blocs/ride_dispatch_cubit.dart';

/// Modal bottom sheet presenting the incoming ride dispatch offer matching the exact design:
/// - Top tags: [⚡ NEW DISPATCH OFFER] green pill, [🛡 Auto-Match] outline pill, and circular [10 SEC] countdown ring
/// - Fare & Surge row: "Rs. 185", "+Rs. 35 Surge" red badge, "Cash on Arrival"
/// - Route metrics pill: "4.2 km total • 14 min trip • 🛵 Bike Moto"
/// - Route addresses timeline: Pickup with green dot + address + Chowk, Destination with red pin + address + Gate
/// - Rider card: Profile avatar circle ("AS"), Name ("Aarav Shrestha"), Rating ("★ 4.9"), trips count, note pill ("I have exact cash")
/// - Actions: Outlined "✕ Decline" and filled dark teal "ACCEPT RIDE 10s ->"
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

    // Derived values with realistic fallbacks
    final surge = request.surgeBonus ?? 35.0;
    final payment = request.paymentType ?? 'Cash on Arrival';
    // final distanceKm = (request.distanceMeters != null && request.distanceMeters! > 0)
    //     ? (request.distanceMeters! / 1000.0).toStringAsFixed(1)
    //     : '4.2';
    final distanceKm = request.distanceToPickupKm;
    final durationMin = request.estimatedDurationMin ?? 14;
    final vehicleCat = request.vehicleCategory ?? 'Bike Moto';

    final riderName =
        (request.riderName != null && request.riderName!.trim().isNotEmpty)
        ? request.riderName!.trim()
        : 'Aarav Shrestha';
    final riderRating =
        (request.riderRating != null && request.riderRating! > 0)
        ? request.riderRating!.toStringAsFixed(1)
        : '4.9';
    final riderTrips =
        (request.riderTripsCount != null && request.riderTripsCount! > 0)
        ? '${request.riderTripsCount}+ verified trips • Regular commuter'
        : '120+ verified trips • Regular commuter';
    final riderNote =
        (request.riderNote != null && request.riderNote!.trim().isNotEmpty)
        ? request.riderNote!
        : 'I have exact cash';

    final initials = _getInitials(riderName);

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
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
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
                margin: const EdgeInsets.only(bottom: 14),
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
                            'NEW DISPATCH OFFER',
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
                    const SizedBox(width: 8),

                    // Auto-Match tag
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
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 13,
                            color: Color(0xFF475569),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Auto-Match',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Speaker sound on/off toggle button
                    // if (onSoundToggle != null) ...[
                    //   GestureDetector(
                    //     onTap: onSoundToggle,
                    //     child: Container(
                    //       width: 40,
                    //       height: 40,
                    //       decoration: BoxDecoration(
                    //         color: isMuted
                    //             ? const Color(0xFFF1F5F9)
                    //             : const Color(0xFFEFF6FF),
                    //         borderRadius: BorderRadius.circular(14),
                    //         border: Border.all(
                    //           color: isMuted
                    //               ? const Color(0xFFE2E8F0)
                    //               : const Color(0xFFBFDBFE),
                    //           width: 1.2,
                    //         ),
                    //       ),
                    //       child: Center(
                    //         child: Icon(
                    //           isMuted
                    //               ? Icons.volume_off_rounded
                    //               : Icons.volume_up_rounded,
                    //           size: 20,
                    //           color: isMuted
                    //               ? const Color(0xFF94A3B8)
                    //               : const Color(0xFF2563EB),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    //   const SizedBox(width: 10),
                    // ],

                    // Circular countdown timer ring
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 46,
                          height: 46,
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
              ],
            ),

            // const SizedBox(height: 14),

            // 2. Fare & Surge Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Rs. ${request.estimatedFare.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
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
            const SizedBox(height: 12),

            // 3. Metrics Bar Pill
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.route_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$distanceKm km total',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '•',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
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
                  const Spacer(),
                  // const Text('🛵', style: TextStyle(fontSize: 13)),
                  // const SizedBox(width: 4),
                  // Text(
                  //   vehicleCat,
                  //   style: const TextStyle(
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.w800,
                  //     color: Color(0xFF0F172A),
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 14),

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
                      height: 48,
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
                const SizedBox(width: 14),

                // Timeline Addresses
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pickup Section
                      const Text(
                        'PICKUP • 400M AWAY (2 MIN)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request.pickupAddress,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: 6,
                          //     vertical: 2,
                          //   ),
                          //   decoration: BoxDecoration(
                          //     color: const Color(0xFFF1F5F9),
                          //     borderRadius: BorderRadius.circular(6),
                          //   ),
                          //   child: const Text(
                          //     'Chowk',
                          //     style: TextStyle(
                          //       fontSize: 10,
                          //       fontWeight: FontWeight.w700,
                          //       color: Color(0xFF64748B),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Destination Section
                      const Text(
                        'DESTINATION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request.dropoffAddress,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: 6,
                          //     vertical: 2,
                          //   ),
                          //   decoration: BoxDecoration(
                          //     color: const Color(0xFFF1F5F9),
                          //     borderRadius: BorderRadius.circular(6),
                          //   ),
                          //   child: const Text(
                          //     'Main Gate',
                          //     style: TextStyle(
                          //       fontSize: 10,
                          //       fontWeight: FontWeight.w700,
                          //       color: Color(0xFF64748B),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 5. Rider Info Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Rider Avatar
                      Container(
                        width: 40,
                        height: 40,
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

                      // Rider Name & Trips
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
                            // const SizedBox(height: 2),
                            // Text(
                            //   riderTrips,
                            //   style: const TextStyle(
                            //     fontSize: 11,
                            //     fontWeight: FontWeight.w600,
                            //     color: Color(0xFF64748B),
                            //   ),
                            //   maxLines: 1,
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                          ],
                        ),
                      ),

                      // Rider Rating Badge
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 8,
                      //     vertical: 4,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(10),
                      //     border: Border.all(color: const Color(0xFFE2E8F0)),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       const Icon(
                      //         Icons.star_rounded,
                      //         size: 14,
                      //         color: Color(0xFFF59E0B),
                      //       ),
                      //       const SizedBox(width: 3),
                      //       Text(
                      //         riderRating,
                      //         style: const TextStyle(
                      //           fontSize: 12,
                      //           fontWeight: FontWeight.w800,
                      //           color: Color(0xFF0F172A),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        SizedBox(width: 6),
                        Text(
                          'Decline',
                          style: TextStyle(
                            fontSize: 14,
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ACCEPT RIDE ${remainingSeconds}s',
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
