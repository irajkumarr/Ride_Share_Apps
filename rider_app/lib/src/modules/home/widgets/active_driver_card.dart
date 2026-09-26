import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import '../../../data/remote/ride_api_service.dart';

class ActiveDriverCard extends StatelessWidget {
  final RideBookingModel booking;
  final DriverModel driver;
  final String statusText;
  final VoidCallback onCancel;

  const ActiveDriverCard({
    super.key,
    required this.booking,
    required this.driver,
    required this.statusText,
    required this.onCancel,
  });

  String _formatPlate(String plate) {
    if (plate.isEmpty) {
      return 'BA  2  PA  4092';
    }
    return plate;
  }

  String _getVehicleModel(DriverModel driver) {
    if (driver.vehicleModel.isNotEmpty &&
        driver.vehicleModel.toLowerCase() != 'bike' &&
        driver.vehicleModel.toLowerCase() != 'rides') {
      final color = driver.vehicleColor.isNotEmpty
          ? '${driver.vehicleColor} '
          : '';
      return '$color${driver.vehicleModel}';
    }
    return 'Red Honda Shine';
  }

  @override
  Widget build(BuildContext context) {
    if (booking.status == RideStatus.driverArriving) {
      return _buildDriverArrivedView(context);
    } else if (booking.status == RideStatus.tripInProgress) {
      return _buildOnTripView(context);
    } else {
      return _buildDriverAcceptedView(context);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // UI #1: DRIVER ACCEPTED / ON THE WAY (Screenshot 2)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildDriverAcceptedView(BuildContext context) {
    final driverName = driver.name.isNotEmpty ? driver.name : 'Bikash Sharma';
    final vehicleDetails = _getVehicleModel(driver);
    final licensePlate = _formatPlate(driver.licensePlate);
    final rating = driver.rating > 0 ? driver.rating : 4.9;
    final tripsCount = driver.totalRides > 0
        ? '${driver.totalRides}+'
        : '1,240+';

    final etaTime = TimeOfDay.fromDateTime(
      DateTime.now().add(const Duration(minutes: 3)),
    ).format(context);

    final pinCode = booking.id.length >= 4
        ? booking.id.substring(booking.id.length - 4)
        : '5824';

    final fareDisplay = booking.fareNpr > 0
        ? 'Rs. ${booking.fareNpr.toStringAsFixed(0)}'
        : 'Rs. 46';

    final paymentDisplay = booking.paymentMethod.isNotEmpty
        ? (booking.paymentMethod.toLowerCase() == 'cash'
              ? 'Cash / eSewa'
              : booking.paymentMethod)
        : 'Cash / eSewa';

    final pickupTitle = booking.pickup.title.isNotEmpty
        ? booking.pickup.title
        : 'Udaypur fresh butcher shop';

    final destTitle = booking.destination.title.isNotEmpty
        ? booking.destination.title
        : 'Sirjana nagar busstand';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 26,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 1. Status Header Row: "🟢 Driver is on the way" + License Plate Box
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: Color(0xFF10B981), // Vibrant Green
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Driver is on the way',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              const TextSpan(text: 'Arriving in '),
                              const TextSpan(
                                text: '3 mins',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              TextSpan(text: ' ($etaTime)'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // License Plate Pill Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          licensePlate,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vehicleDetails,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Driver Info Row (Avatar with green check, Name & rating, START PIN, Call, Chat with unread dot)
              Row(
                children: [
                  // Driver Avatar with teal-green ring & verified checkmark
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF10B981),
                            width: 2.2,
                          ),
                          color: const Color(0xFFF1F5F9),
                        ),
                        child: ClipOval(
                          child: driver.photoUrl.isNotEmpty
                              ? Image.network(
                                  driver.photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 32,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 32,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: -2,
                        child: Container(
                          width: 17,
                          height: 17,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Driver Name, Star Rating & Total Trips
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Row(
                        //   children: [
                        //     const Icon(
                        //       Icons.star_rounded,
                        //       color: Color(0xFFFF9800),
                        //       size: 16,
                        //     ),
                        //     const SizedBox(width: 3),
                        //     Text(
                        //       rating.toStringAsFixed(1),
                        //       style: const TextStyle(
                        //         fontSize: 13,
                        //         fontWeight: FontWeight.w800,
                        //         color: Color(0xFF0F172A),
                        //       ),
                        //     ),
                        //     const SizedBox(width: 4),
                        //     Text(
                        //       '($tripsCount trips)',
                        //       style: const TextStyle(
                        //         fontSize: 12.5,
                        //         fontWeight: FontWeight.w500,
                        //         color: Color(0xFF94A3B8),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // START PIN Badge (Cream background with yellow border)
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 14,
                  //     vertical: 6,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFFFFFBEB),
                  //     borderRadius: BorderRadius.circular(14),
                  //     border: Border.all(
                  //       color: const Color(0xFFFDE68A),
                  //       width: 1.2,
                  //     ),
                  //   ),
                  //   child: Column(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       const Text(
                  //         'START PIN',
                  //         style: TextStyle(
                  //           fontSize: 9.5,
                  //           fontWeight: FontWeight.w800,
                  //           color: Color(0xFFD97706),
                  //           letterSpacing: 0.5,
                  //         ),
                  //       ),
                  //       const SizedBox(height: 1),
                  //       Text(
                  //         pinCode,
                  //         style: const TextStyle(
                  //           fontSize: 16,
                  //           fontWeight: FontWeight.w900,
                  //           color: Color(0xFF0F172A),
                  //           letterSpacing: 1.8,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(width: 8),

                  // Circular Call Button
                  InkWell(
                    onTap: () {
                      final phone = driver.phoneNumber.isNotEmpty
                          ? driver.phoneNumber
                          : '9801234567';
                      ToastOverlay.show(
                        'Calling driver: $phone',
                        type: ToastType.normal,
                      );
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone_rounded,
                        color: Color(0xFF334155),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Route & Fare Container Card (Pickup orange dot, Dest dark dot, vertical divider, fare)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Pickup and Destination
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5722),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  pickupTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F172A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  destTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Vertical subtle divider line
                    Container(
                      width: 1,
                      height: 38,
                      color: const Color(0xFFE2E8F0),
                    ),
                    const SizedBox(width: 14),

                    // Fare & Payment type
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fareDisplay,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          paymentDisplay,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10B981), // Vibrant Green
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4. Dual Bottom Pill Buttons: [🛡️ Safety Kit] and [🔗 Share Trip]
              // Row(
              //   children: [
              //     Expanded(
              //       child: SizedBox(
              //         height: 48,
              //         child: ElevatedButton.icon(
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: const Color(0xFFF1F5F9),
              //             foregroundColor: const Color(0xFF0F172A),
              //             elevation: 0,
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(16),
              //             ),
              //           ),
              //           onPressed: () {
              //             ToastOverlay.show(
              //               'Emergency contacts & Police 100 notified',
              //               type: ToastType.warning,
              //             );
              //           },
              //           icon: const Icon(
              //             Icons.shield_rounded,
              //             color: Color(0xFF475569),
              //             size: 18,
              //           ),
              //           label: const Text(
              //             'Safety Kit',
              //             style: TextStyle(
              //               fontSize: 14,
              //               fontWeight: FontWeight.w800,
              //               color: Color(0xFF0F172A),
              //               letterSpacing: -0.2,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: SizedBox(
              //         height: 48,
              //         child: ElevatedButton.icon(
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: const Color(0xFFF1F5F9),
              //             foregroundColor: const Color(0xFF0F172A),
              //             elevation: 0,
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(16),
              //             ),
              //           ),
              //           onPressed: () {
              //             ToastOverlay.show(
              //               'Live trip tracking link copied to clipboard!',
              //               type: ToastType.success,
              //             );
              //           },
              //           icon: const Icon(
              //             Icons.share_rounded,
              //             color: Color(0xFF475569),
              //             size: 18,
              //           ),
              //           label: const Text(
              //             'Share Trip',
              //             style: TextStyle(
              //               fontSize: 14,
              //               fontWeight: FontWeight.w800,
              //               color: Color(0xFF0F172A),
              //               letterSpacing: -0.2,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 14),

              // 5. Red "Cancel ride" text button
              Center(
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444), // Soft bright red
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                  ),
                  child: const Text(
                    'Cancel ride',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // UI #2: DRIVER ARRIVED AT PICKUP
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildDriverArrivedView(BuildContext context) {
    final driverName = driver.name.isNotEmpty ? driver.name : 'Bikash Sharma';
    final vehicleDetails = _getVehicleModel(driver);
    final licensePlate = _formatPlate(driver.licensePlate);
    final rating = driver.rating > 0 ? driver.rating : 4.9;
    final tripsCount = driver.totalRides > 0
        ? '${driver.totalRides}+'
        : '1,240+';

    final pinCode = booking.id.length >= 4
        ? booking.id.substring(booking.id.length - 4)
        : '5824';

    final fareDisplay = booking.fareNpr > 0
        ? 'Rs. ${booking.fareNpr.toStringAsFixed(0)}'
        : 'Rs. 46';

    final paymentDisplay = booking.paymentMethod.isNotEmpty
        ? (booking.paymentMethod.toLowerCase() == 'cash'
              ? 'Cash / eSewa'
              : booking.paymentMethod)
        : 'Cash / eSewa';

    final pickupTitle = booking.pickup.title.isNotEmpty
        ? booking.pickup.title
        : 'Your Pickup Point';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 26,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 1. Status Header Row: "🟢 Driver has arrived" + Vehicle License Plate
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981), // Vibrant Green
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Driver has arrived!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Waiting at your pickup location',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // License Plate Pill Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          licensePlate,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vehicleDetails,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Prominent START PIN Card to share with driver
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 16,
              //     vertical: 12,
              //   ),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFFFFBEB), // Amber soft tint
              //     borderRadius: BorderRadius.circular(18),
              //     border: Border.all(
              //       color: const Color(0xFFFDE68A),
              //       width: 1.4,
              //     ),
              //   ),
              //   child: Row(
              //     children: [
              //       Container(
              //         width: 42,
              //         height: 42,
              //         decoration: const BoxDecoration(
              //           color: Color(0xFFFEF3C7),
              //           shape: BoxShape.circle,
              //         ),
              //         child: const Center(
              //           child: Icon(
              //             Icons.pin_rounded,
              //             color: Color(0xFFD97706),
              //             size: 22,
              //           ),
              //         ),
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: const [
              //             Text(
              //               'SHARE PIN TO START TRIP',
              //               style: TextStyle(
              //                 fontSize: 10.5,
              //                 fontWeight: FontWeight.w800,
              //                 color: Color(0xFFD97706),
              //                 letterSpacing: 0.5,
              //               ),
              //             ),
              //             SizedBox(height: 2),
              //             Text(
              //               'Show this PIN to your driver',
              //               style: TextStyle(
              //                 fontSize: 12,
              //                 color: Color(0xFF78350F),
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //       Container(
              //         padding: const EdgeInsets.symmetric(
              //           horizontal: 14,
              //           vertical: 6,
              //         ),
              //         decoration: BoxDecoration(
              //           color: const Color(0xFF0F172A),
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //         child: Text(
              //           pinCode,
              //           style: const TextStyle(
              //             fontSize: 19,
              //             fontWeight: FontWeight.w900,
              //             color: Color(0xFFFBBF24),
              //             letterSpacing: 2.5,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 16),

              // 3. Driver Info Row (Avatar with green check, Name & rating, Call, Chat)
              Row(
                children: [
                  // Driver Avatar with teal-green ring & verified checkmark
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF10B981),
                            width: 2.2,
                          ),
                          color: const Color(0xFFF1F5F9),
                        ),
                        child: ClipOval(
                          child: driver.photoUrl.isNotEmpty
                              ? Image.network(
                                  driver.photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: -2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Driver Name & Rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFF9800),
                              size: 15,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($tripsCount rides)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Circular Call Button
                  InkWell(
                    onTap: () {
                      final phone = driver.phoneNumber.isNotEmpty
                          ? driver.phoneNumber
                          : '9801234567';
                      ToastOverlay.show(
                        'Calling driver: $phone',
                        type: ToastType.normal,
                      );
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone_rounded,
                        color: Color(0xFF334155),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Pickup Location & Fare Container Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pickupTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 1,
                      height: 28,
                      color: const Color(0xFFE2E8F0),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fareDisplay,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          paymentDisplay,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 5. Red "Cancel ride" text button
              Center(
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                  ),
                  child: const Text(
                    'Cancel ride',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // UI #3: START TRIP / TRIP IN PROGRESS (Screenshot 1)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildOnTripView(BuildContext context) {
    final driverName = driver.name.isNotEmpty ? driver.name : 'Bikash Sharma';
    final vehicleDetails = _getVehicleModel(driver);
    final licensePlate = _formatPlate(driver.licensePlate);
    final rating = driver.rating;
    final tripsCount = driver.totalRides >= 0
        ? '${driver.totalRides}+'
        : '1,240+';

    final etaTime = TimeOfDay.fromDateTime(
      DateTime.now().add(const Duration(minutes: 6)),
    ).format(context);

    final pinCode = booking.id.length >= 4
        ? booking.id.substring(booking.id.length - 4)
        : '5824';

    final fareDisplay = booking.fareNpr > 0
        ? 'Rs. ${booking.fareNpr.toStringAsFixed(0)}'
        : 'Rs. 46';

    final paymentDisplay = booking.paymentMethod.isNotEmpty
        ? (booking.paymentMethod.toLowerCase() == 'cash'
              ? 'Cash / eSewa'
              : booking.paymentMethod)
        : 'Cash / eSewa';

    final pickupTitle = booking.pickup.title.isNotEmpty
        ? booking.pickup.title
        : 'Udaypur fresh butcher shop';

    final destTitle = booking.destination.title.isNotEmpty
        ? booking.destination.title
        : 'Sirjana nagar busstand';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 26,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 1. Status Header Row: "🟢 Heading to Destination" + PIN Verified Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: Color(0xFF10B981), // Vibrant Green
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Heading to Destination',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              const TextSpan(text: 'Arriving in '),
                              const TextSpan(
                                text: '6 mins',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              TextSpan(text: ' ($etaTime)'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // PIN Verified Badge
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 10,
                  //     vertical: 6,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFFECFDF5),
                  //     borderRadius: BorderRadius.circular(14),
                  //     border: Border.all(
                  //       color: const Color(0xFFA7F3D0),
                  //       width: 1.0,
                  //     ),
                  //   ),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       const Icon(
                  //         Icons.verified_outlined,
                  //         color: Color(0xFF059669),
                  //         size: 14,
                  //       ),
                  //       const SizedBox(width: 4),
                  //       Text(
                  //         'PIN $pinCode Verified ✓',
                  //         style: const TextStyle(
                  //           fontSize: 11.5,
                  //           fontWeight: FontWeight.w800,
                  //           color: Color(0xFF059669),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Driver Card Box with White Pill background
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // Driver Avatar with verified check badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF1F5F9),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: driver.photoUrl.isNotEmpty
                                ? Image.network(
                                    driver.photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                        driverName.substring(0, 1),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      driverName.substring(0, 1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: -1,
                          right: -1,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Driver Name, Rating, Vehicle and License Plate
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  driverName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFFDE68A),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.star_outline_rounded,
                                      color: Color(0xFFF59E0B),
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$vehicleDetails • ($tripsCount)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            licensePlate,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Circular Call Button
                    InkWell(
                      onTap: () {
                        final phone = driver.phoneNumber.isNotEmpty
                            ? driver.phoneNumber
                            : '9801234567';
                        ToastOverlay.show(
                          'Calling driver: $phone',
                          type: ToastType.normal,
                        );
                      },
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.phone_outlined,
                          color: Color(0xFF334155),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Circular Message Button
                    // InkWell(
                    //   onTap: () {
                    //     ToastOverlay.show(
                    //       'Chat with $driverName',
                    //       type: ToastType.normal,
                    //     );
                    //   },
                    //   borderRadius: BorderRadius.circular(22),
                    //   child: Container(
                    //     width: 44,
                    //     height: 44,
                    //     decoration: const BoxDecoration(
                    //       color: Colors.white,
                    //       shape: BoxShape.circle,
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.black12,
                    //           blurRadius: 4,
                    //           offset: Offset(0, 1),
                    //         ),
                    //       ],
                    //     ),
                    //     child: const Icon(
                    //       Icons.chat_bubble_outline_rounded,
                    //       color: Color(0xFF334155),
                    //       size: 19,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Route Stepper Card (Pickup [Done] & Destination [~6 mins away] + Rs. 46 Cash / eSewa)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Stepper timeline
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step 1: Pickup point
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Green circle with checkmark
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD1FAE5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Color(0xFF059669),
                                    size: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pickupTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    const Text(
                                      'Picked up at 6:26 PM • Completed',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Connecting vertical line
                          Padding(
                            padding: const EdgeInsets.only(left: 9),
                            child: Container(
                              width: 1.5,
                              height: 14,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          // Step 2: Destination drop-off
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F172A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      destTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    const Text(
                                      'Drop-off • ~6 mins away',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Fare column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fareDisplay,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          paymentDisplay,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4. Dual Action Buttons: [🛡️ Safety Kit] and [🎯 Share Live Trip]
              // Row(
              //   children: [
              //     Expanded(
              //       child: SizedBox(
              //         height: 48,
              //         child: ElevatedButton.icon(
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: const Color(0xFFF8FAFC),
              //             foregroundColor: const Color(0xFF0F172A),
              //             elevation: 0,
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(16),
              //             ),
              //           ),
              //           onPressed: () {
              //             ToastOverlay.show(
              //               'Emergency contacts & Police 100 notified',
              //               type: ToastType.warning,
              //             );
              //           },
              //           icon: const Icon(
              //             Icons.shield_outlined,
              //             color: Color(0xFFF59E0B),
              //             size: 19,
              //           ),
              //           label: const Text(
              //             'Safety Kit',
              //             style: TextStyle(
              //               fontSize: 14,
              //               fontWeight: FontWeight.w800,
              //               color: Color(0xFF0F172A),
              //               letterSpacing: -0.2,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: SizedBox(
              //         height: 48,
              //         child: ElevatedButton.icon(
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: const Color(0xFFF8FAFC),
              //             foregroundColor: const Color(0xFF0F172A),
              //             elevation: 0,
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(16),
              //             ),
              //           ),
              //           onPressed: () {
              //             ToastOverlay.show(
              //               'Live trip tracking link copied to clipboard!',
              //               type: ToastType.success,
              //             );
              //           },
              //           icon: const Icon(
              //             Icons.track_changes_rounded,
              //             color: Color(0xFF0F172A),
              //             size: 19,
              //           ),
              //           label: const Text(
              //             'Share Live Trip',
              //             style: TextStyle(
              //               fontSize: 14,
              //               fontWeight: FontWeight.w800,
              //               color: Color(0xFF0F172A),
              //               letterSpacing: -0.2,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 12),

              // // 5. Emergency Assist Banner with Red Star Icon & Instant Response ->
              // InkWell(
              //   onTap: () {
              //     ToastOverlay.show(
              //       'Connecting to RideNest Emergency Hotline 100 / SOS',
              //       type: ToastType.warning,
              //     );
              //   },
              //   borderRadius: BorderRadius.circular(16),
              //   child: Container(
              //     width: double.infinity,
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 12,
              //     ),
              //     decoration: BoxDecoration(
              //       color: const Color(0xFFFEF2F2), // Soft pink-red
              //       borderRadius: BorderRadius.circular(16),
              //       border: Border.all(
              //         color: const Color(0xFFFECACA),
              //         width: 1.0,
              //       ),
              //     ),
              //     child: Row(
              //       children: const [
              //         Icon(
              //           Icons.emergency_rounded,
              //           color: Color(0xFFDC2626),
              //           size: 20,
              //         ),
              //         SizedBox(width: 10),
              //         Text(
              //           'Emergency Assist',
              //           style: TextStyle(
              //             fontSize: 14,
              //             fontWeight: FontWeight.w800,
              //             color: Color(0xFFDC2626),
              //           ),
              //         ),
              //         Spacer(),
              //         Text(
              //           'Instant Response →',
              //           style: TextStyle(
              //             fontSize: 13,
              //             fontWeight: FontWeight.w700,
              //             color: Color(0xFFDC2626),
              //           ),
              //         ),
              //       ],
              //     ),
              // ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
