import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_app/src/modules/ride/blocs/ride_dispatch_cubit.dart';
import 'package:driver_app/src/modules/trip/utils/trip_location_utils.dart';

/// Modal bottom sheet presenting the completed trip summary matching the screenshot:
/// - Header: Green checkmark circle, "Trip Completed!" with [FINISHED] green badge, "Dropped off Aarav Shrestha at Sundhara"
/// - Collect Cash Box: Dark green gradient container with "• COLLECT CASH FROM RIDER", [Cash Mode] badge with faded watermark,
///   Large "Rs. 185", "Exact fare due", and informative note: "ⓘ Hand exact change if passenger pays with Rs. 500/1000 note."
/// - Trip Receipt & Split: Detailed breakdown with ID (#RN-8942), Base Fare, Distance Rate, Time Fare,
///   Peak Surge Bonus (+Rs. 35.00), RideNest Platform Fee 10% (-Rs. 18.00), and NET DRIVER PAYOUT ("Rs. 167.00").
/// - Rate Rider Card: Rider initials/avatar ("AS"), "Rate Aarav Shrestha", star rating selector (1-5 stars with 4.9 initial).
/// - Bottom primary button: "COLLECTED CASH & RETURN ONLINE"
class TripSummarySheet extends StatefulWidget {
  const TripSummarySheet({super.key, required this.summary});

  final TripCompletedSummaryState summary;

  @override
  State<TripSummarySheet> createState() => _TripSummarySheetState();
}

class _TripSummarySheetState extends State<TripSummarySheet> {
  int _selectedStars = 5;

  @override
  Widget build(BuildContext context) {
    final req = widget.summary.request;
    final fare = widget.summary.fare;

    final riderName =
        (req.riderName != null && req.riderName!.trim().isNotEmpty)
        ? req.riderName!.trim()
        : 'Aarav Shrestha';

    // Dropoff display name
    final dropoffLocation = req.dropoffAddress.isNotEmpty
        ? (req.dropoffAddress.split(',').first.trim())
        : 'Sundhara';

    // Pickup display name
    final pickupLocation = req.pickupAddress.isNotEmpty
        ? (req.pickupAddress.split(',').first.trim())
        : 'Gatthaghar';

    // Distance & time
    final distanceKm = '4.8';
    final durationMin = req.estimatedDurationMin ?? 14;

    // Financial breakdown calculations
    final surge = req.surgeBonus ?? 35.0;
    final baseFare = 60.0;
    final distanceRate = ((fare - surge - baseFare) * 0.75).clamp(20.0, 999.0);
    final timeFare = (fare - surge - baseFare - distanceRate).clamp(
      10.0,
      999.0,
    );
    final platformFee = (fare * 0.10); // 10%
    final netDriverPayout = fare - platformFee;

    final tripId = req.rideId.isNotEmpty
        ? '#RN-${req.rideId.length >= 4 ? req.rideId.substring(req.rideId.length - 4) : req.rideId}'
        : '#RN-8942';

    final initials = _getInitials(riderName);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Header: [✔ Checkmark] Trip Completed! [FINISHED]
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF86EFAC),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF10B981),
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Trip Completed!',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'FINISHED',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF15803D),
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Dropped off $riderName at $dropoffLocation',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2. Collect Cash Container (Dark Slate/Green Card)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF092926), Color(0xFF0B3B36)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF092926)
                              .withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header Row: [• COLLECT CASH FROM RIDER] & [Cash Mode]
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF59E0B),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'COLLECT CASH FROM RIDER',
                                  style: TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Text(
                                'Cash Mode',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Large Fare Number & "Exact fare due"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rs. ${fare.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const Text(
                              'Exact fare due',
                              style: TextStyle(
                                color: Color(0xFF6EE7B7),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Hand exact change tip box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: Color(0xFFFBBF24),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Hand exact change if passenger pays with Rs. 500/1000 note.',
                                  style: TextStyle(
                                    color: Color(0xFFE2E8F0),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Trip Receipt & Split Breakdown Box
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFFF8FAFC),
                  //     borderRadius: BorderRadius.circular(20),
                  //     border: Border.all(color: const Color(0xFFE2E8F0)),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       // Receipt Header: [📄 TRIP RECEIPT & SPLIT] and [ID: #RN-8942]
                  //       // Row(
                  //       //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       //   children: [
                  //       //     const Row(
                  //       //       children: [
                  //       //         Icon(
                  //       //           Icons.receipt_long_rounded,
                  //       //           size: 18,
                  //       //           color: Color(0xFF1E293B),
                  //       //         ),
                  //       //         SizedBox(width: 8),
                  //       //         Text(
                  //       //           'TRIP RECEIPT & SPLIT',
                  //       //           style: TextStyle(
                  //       //             color: Color(0xFF0F172A),
                  //       //             fontSize: 12.5,
                  //       //             fontWeight: FontWeight.w900,
                  //       //             letterSpacing: 0.5,
                  //       //           ),
                  //       //         ),
                  //       //       ],
                  //       //     ),
                  //       //     Text(
                  //       //       'ID: $tripId',
                  //       //       style: const TextStyle(
                  //       //         color: Color(0xFF64748B),
                  //       //         fontSize: 11.5,
                  //       //         fontWeight: FontWeight.w800,
                  //       //       ),
                  //       //     ),
                  //       //   ],
                  //       // ),
                  //       // const SizedBox(height: 12),
                  //       // const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  //       // const SizedBox(height: 12),

                  //       // Line items
                  //       // _buildReceiptRow('Base Fare', 'Rs. ${baseFare.toStringAsFixed(2)}'),
                  //       // const SizedBox(height: 8),
                  //       // _buildReceiptRow('Distance Rate ($distanceKm km)', 'Rs. ${distanceRate.toStringAsFixed(2)}'),
                  //       // const SizedBox(height: 8),
                  //       // _buildReceiptRow('Time Fare ($durationMin min)', 'Rs. ${timeFare.toStringAsFixed(2)}'),
                  //       // const SizedBox(height: 8),

                  //       // Peak Surge Bonus (Green)
                  //       // _buildReceiptRow(
                  //       //   '⚡ Peak Surge Bonus (1.2x)',
                  //       //   '+ Rs. ${surge.toStringAsFixed(2)}',
                  //       //   valueColor: const Color(0xFF059669),
                  //       //   labelColor: const Color(0xFF059669),
                  //       // ),
                  //       // const SizedBox(height: 8),

                  //       // Platform Fee (Red)
                  //       // _buildReceiptRow(
                  //       //   'RideNest Platform Fee (10%)',
                  //       //   '- Rs. ${platformFee.toStringAsFixed(2)}',
                  //       //   valueColor: const Color(0xFFDC2626),
                  //       //   labelColor: const Color(0xFFDC2626),
                  //       // ),
                  //       // const SizedBox(height: 12),
                  //       // const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  //       // const SizedBox(height: 12),

                  //       // NET DRIVER PAYOUT
                  //       // Row(
                  //       //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       //   crossAxisAlignment: CrossAxisAlignment.baseline,
                  //       //   textBaseline: TextBaseline.alphabetic,
                  //       //   children: [
                  //       //     const Column(
                  //       //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       //       children: [
                  //       //         Text(
                  //       //           'NET DRIVER PAYOUT',
                  //       //           style: TextStyle(
                  //       //             color: Color(0xFF475569),
                  //       //             fontSize: 11,
                  //       //             fontWeight: FontWeight.w900,
                  //       //             letterSpacing: 0.6,
                  //       //           ),
                  //       //         ),
                  //       //         SizedBox(height: 2),
                  //       //         Text(
                  //       //           'Credited to wallet',
                  //       //           style: TextStyle(
                  //       //             color: Color(0xFF94A3B8),
                  //       //             fontSize: 11,
                  //       //             fontWeight: FontWeight.w600,
                  //       //           ),
                  //       //         ),
                  //       //       ],
                  //       //     ),
                  //       //     Text(
                  //       //       'Rs. ${netDriverPayout.toStringAsFixed(2)}',
                  //       //       style: const TextStyle(
                  //       //         color: Color(0xFF059669),
                  //       //         fontSize: 20,
                  //       //         fontWeight: FontWeight.w900,
                  //       //         letterSpacing: -0.5,
                  //       //       ),
                  //       //     ),
                  //       //   ],
                  //       // ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 16),

                  // 4. Rate Rider Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Rider avatar circle with initials
                        Container(
                          width: 42,
                          height: 42,
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
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Rider info & question
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rate $riderName',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'How was your rider experience?',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Interactive Star rating selector
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            final starValue = index + 1;
                            final isSelected = starValue <= _selectedStars;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedStars = starValue;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 1.5,
                                ),
                                child: Icon(
                                  Icons.star_rounded,
                                  size: 20,
                                  color: isSelected
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Primary Return Online Button
                  ElevatedButton(
                    onPressed: () {
                      context.read<RideDispatchCubit>().dismissTripSummary();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF132A2F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'COLLECTED CASH & RETURN ONLINE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    Color? labelColor,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: labelColor ?? const Color(0xFF475569),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
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
