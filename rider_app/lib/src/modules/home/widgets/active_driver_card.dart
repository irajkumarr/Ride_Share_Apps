import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final tier = booking.vehicleTier.toLowerCase();
    if (tier.contains('bike')) {
      return 'Hero Splendor Plus';
    } else if (tier.contains('comfort') || tier.contains('premium')) {
      return 'Toyota Corolla Premium';
    }
    return 'Suzuki Swift Dzire';
  }

  bool get _isBike =>
      booking.vehicleTier.toLowerCase().contains('bike') ||
      driver.vehicleModel.toLowerCase().contains('bike');

  Future<void> _callDriver(BuildContext context, String phoneNumber) async {
    HapticFeedback.lightImpact();
    final cleanPhone = phoneNumber.isNotEmpty
        ? phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '')
        : '9801234567';
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ToastOverlay.show(
          'Calling driver partner: $cleanPhone',
          type: ToastType.normal,
        );
      }
    } catch (_) {
      ToastOverlay.show(
        'Calling driver partner: $cleanPhone',
        type: ToastType.normal,
      );
    }
  }

  Future<void> _messageDriver(BuildContext context, String phoneNumber) async {
    HapticFeedback.lightImpact();
    final cleanPhone = phoneNumber.isNotEmpty
        ? phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '')
        : '9801234567';
    final uri = Uri.parse('sms:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ToastOverlay.show(
          'Messaging driver partner: $cleanPhone',
          type: ToastType.normal,
        );
      }
    } catch (_) {
      ToastOverlay.show(
        'Messaging driver partner: $cleanPhone',
        type: ToastType.normal,
      );
    }
  }

  void _shareTrip(BuildContext context) {
    HapticFeedback.lightImpact();
    final pickup = booking.pickup.title.isNotEmpty
        ? booking.pickup.title
        : 'Pickup';
    final destination = booking.destination.title.isNotEmpty
        ? booking.destination.title
        : 'Destination';
    final plate = _formatPlate(driver.licensePlate);
    final driverName = driver.name.isNotEmpty ? driver.name : 'RideNest Driver';

    final text =
        'I am on a RideNest ride with $driverName ($plate) from $pickup to $destination.';
    Clipboard.setData(ClipboardData(text: text));
    ToastOverlay.show(
      'Live trip tracking info copied to clipboard!',
      type: ToastType.success,
    );
  }

  void _confirmCancel(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
        title: const Text(
          'Cancel Ride?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Color(0xFF0F172A),
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this ride? Your driver is already assigned and heading to you.',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Keep Ride',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onCancel();
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = booking.status;
    final isArrived = status == RideStatus.driverArriving;
    final isOnTrip = status == RideStatus.tripInProgress;

    final driverName = driver.name.isNotEmpty ? driver.name : '-';
    final vehicleDetails = _getVehicleModel(driver);
    final licensePlate = _formatPlate(driver.licensePlate);
    final rating = driver.rating >= 0 ? driver.rating : 0;
    final tripsCount = driver.totalRides >= 0 ? '${driver.totalRides}+' : '-';

    final fareDisplay = booking.fareNpr > 0
        ? 'Rs. ${booking.fareNpr.toStringAsFixed(0)}'
        : 'Rs. -';

    final paymentDisplay = booking.paymentMethod.isNotEmpty
        ? booking.paymentMethod
        : 'Cash on Dropoff';

    final pickupTitle = booking.pickup.title.isNotEmpty
        ? booking.pickup.title
        : 'Your Pickup Point';

    final destTitle = booking.destination.title.isNotEmpty
        ? booking.destination.title
        : 'Your Destination';

    final etaMinutes = isOnTrip ? 6 : (isArrived ? 0 : 3);
    final etaTime = TimeOfDay.fromDateTime(
      DateTime.now().add(Duration(minutes: etaMinutes)),
    ).format(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 28,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Drag Handle
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Status Banner Row & Boarding PIN / License Plate
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status headline with pulsating dot
                        Row(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: isArrived
                                    ? const Color(0xFFF59E0B)
                                    : (isOnTrip
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFF10B981)),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isArrived
                                                ? const Color(0xFFF59E0B)
                                                : (isOnTrip
                                                      ? const Color(0xFF3B82F6)
                                                      : const Color(
                                                          0xFF10B981,
                                                        )))
                                            .withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isArrived
                                    ? 'Driver has arrived!'
                                    : (isOnTrip
                                          ? 'Heading to Destination'
                                          : 'Driver is on the way'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),

                        // Subtitle info / ETA
                        Text(
                          isArrived
                              ? 'Waiting at your pickup location'
                              : (isOnTrip
                                    ? 'Arriving in ~$etaMinutes mins ($etaTime)'
                                    : 'Pickup in ~$etaMinutes mins ($etaTime)'),
                          style: TextStyle(
                            fontSize: 13,
                            color: isArrived
                                ? const Color(0xFFD97706)
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Embossed License Plate Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          licensePlate,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isBike
                                  ? Icons.two_wheeler_rounded
                                  : Icons.directions_car_filled_rounded,
                              size: 11,
                              color: const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              vehicleDetails,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 3. Driver Info Bar & Quick Action Controls
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    // Driver Profile Avatar with Verified Ring
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF10B981),
                              width: 2.0,
                            ),
                            color: const Color(0xFFE2E8F0),
                          ),
                          child: ClipOval(
                            child: driver.photoUrl.isNotEmpty
                                ? Image.network(
                                    driver.photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person,
                                              size: 30,
                                              color: Color(0xFF64748B),
                                            ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Color(0xFF64748B),
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
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // Driver Name & Rating stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
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
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFF59E0B),
                                size: 15,
                              ),
                              const SizedBox(width: 2),
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
                                '• $tripsCount trips',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Call Driver Button
                    InkWell(
                      onTap: () => _callDriver(context, driver.phoneNumber),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isArrived
                              ? const Color(0xFF10B981)
                              : const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.phone_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 4. Trip Route & Fare Summary Card
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    // Pickup and Dropoff indicators & text
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
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: !isOnTrip
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: !isOnTrip
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 3.5),
                            width: 1,
                            height: 10,
                            color: const Color(0xFFCBD5E1),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  destTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isOnTrip
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isOnTrip
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Vertical Divider
                    Container(
                      width: 1,
                      height: 38,
                      color: const Color(0xFFE2E8F0),
                    ),

                    const SizedBox(width: 12),

                    // Fare & Payment Method
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
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
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 5. Actions Bar: [Share Trip] and [Cancel / Safety]
              Row(
                children: [
                  // Share Trip Button
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF334155),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => _shareTrip(context),
                        icon: const Icon(Icons.share_outlined, size: 16),
                        label: const Text(
                          'Share Trip',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Cancel Ride (or Safety Assist if on trip)
                  if (!isOnTrip) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            backgroundColor: const Color(0xFFFEF2F2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => _confirmCancel(context),
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: const Text(
                            'Cancel Ride',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
