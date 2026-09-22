import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import '../../../data/remote/ride_api_service.dart';

class DriverSearchingView extends StatefulWidget {
  final RideBookingModel booking;
  final VoidCallback onCancel;

  const DriverSearchingView({
    super.key,
    required this.booking,
    required this.onCancel,
  });

  @override
  State<DriverSearchingView> createState() => _DriverSearchingViewState();
}

class _DriverSearchingViewState extends State<DriverSearchingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _countdownTimer;
  int _secondsLeft = 15;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _showTripDetailsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Ride Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  icon: Icons.directions_walk_rounded,
                  iconColor: const Color(0xFF0F172A),
                  title: 'Pickup',
                  subtitle: widget.booking.pickup.title,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.flag_outlined,
                  iconColor: const Color(0xFF0F172A),
                  title: 'Destination',
                  subtitle: widget.booking.destination.title,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.two_wheeler_rounded,
                  iconColor: const Color(0xFFFF4824),
                  title: 'Category',
                  subtitle: widget.booking.vehicleTier,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.payments_rounded,
                  iconColor: const Color(0xFF0D9488),
                  title: 'Estimated Fare',
                  subtitle: 'Rs. ${widget.booking.fareNpr.toStringAsFixed(0)} (${widget.booking.paymentMethod})',
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerText = _secondsLeft > 0
        ? '00 : ${_secondsLeft.toString().padLeft(2, '0')}'
        : '- - : - -';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              const SizedBox(height: 16),

              // Title Header Row: "Starting search" + Countdown Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Starting search',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Assessing how long it'll take to find a car",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Dark pill badge: - - : - - or 00:15 countdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0F1D), // Dark navy / black pill
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      timerText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Animated Progress Bar (Grey track with subtle loading fill)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 4,
                  width: double.infinity,
                  child: LinearProgressIndicator(
                    value: _secondsLeft > 0 ? (15 - _secondsLeft) / 15.0 : null,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Action Buttons Row: [X Cancel ride] and [:: Details]
              Row(
                children: [
                  // Cancel ride button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: const Color(0xFF0F172A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: widget.onCancel,
                        icon: const Icon(
                          Icons.cancel_rounded,
                          size: 19,
                          color: Color(0xFF0F172A),
                        ),
                        label: const Text(
                          'Cancel ride',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Details button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: const Color(0xFF0F172A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _showTripDetailsModal,
                        icon: const Icon(
                          Icons.dashboard_customize_rounded,
                          size: 19,
                          color: Color(0xFF0F172A),
                        ),
                        label: const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // "Can't find the place you need? Help us by adding it to our map!" row
              InkWell(
                onTap: () {
                  ToastOverlay.show(
                    'Location suggestion submitted',
                    type: ToastType.normal,
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      // Location pin icon with dark navy body and red dot
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFF1E293B),
                              size: 20,
                            ),
                            Positioned(
                              top: 7,
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF4824),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Text labels
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Can't find the place you need?",
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Help us by adding it to our map!',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right chevron arrow
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
