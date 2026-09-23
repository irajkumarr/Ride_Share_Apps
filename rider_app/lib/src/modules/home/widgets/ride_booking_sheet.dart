import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'ridenest_illustrations.dart';

class VehicleTier {
  final String id;
  final String name;
  final String description;
  final double baseFareNpr;
  final double perKmRate;
  final Widget illustration;
  final int etaMins;
  final int capacity;
  final bool hasLightning;

  const VehicleTier({
    required this.id,
    required this.name,
    required this.description,
    required this.baseFareNpr,
    required this.perKmRate,
    required this.illustration,
    required this.etaMins,
    required this.capacity,
    this.hasLightning = false,
  });
}

class RideBookingSheet extends StatefulWidget {
  final AddressModel pickup;
  final AddressModel destination;
  final RouteModel route;
  final double distanceKm;
  final int durationMins;
  final VoidCallback onCancel;
  final void Function({
    required VehicleTier selectedTier,
    required double fareNpr,
    required String paymentMethod,
    String? promoCode,
  })
  onConfirmBooking;

  const RideBookingSheet({
    super.key,
    required this.pickup,
    required this.destination,
    required this.route,
    required this.distanceKm,
    required this.durationMins,
    required this.onCancel,
    required this.onConfirmBooking,
  });

  @override
  State<RideBookingSheet> createState() => _RideBookingSheetState();
}

class _RideBookingSheetState extends State<RideBookingSheet> {
  int _selectedTierIndex = 1; // Default to 'Bike' as selected in screenshot
  int _selectedTab = 0; // 0: Rides, 1: Delivery and Cargo
  String _selectedPaymentMethod = 'Cash';

  late final List<VehicleTier> _tiers = [
    VehicleTier(
      id: 'fastest',
      name: 'Fastest',
      description: 'Quickest pickup nearby',
      baseFareNpr: 46.0,
      perKmRate: 18.0,
      illustration: const Icon(
        Icons.directions_car_filled_rounded,
        size: 46,
        color: Color(0xFF94A3B8),
      ),
      etaMins: 5,
      capacity: 3,
    ),
    VehicleTier(
      id: 'bike',
      name: 'Bike',
      description: 'Fastest through traffic',
      baseFareNpr: 46.0,
      perKmRate: 16.0,
      illustration: const BikeIllustration(size: 68),
      etaMins: 5,
      capacity: 1,
      hasLightning: true,
    ),
    VehicleTier(
      id: 'economy',
      name: 'Economy',
      description: 'Budget-friendly ride',
      baseFareNpr: 120.0,
      perKmRate: 35.0,
      illustration: const Icon(
        Icons.directions_car_filled_rounded,
        size: 46,
        color: Color(0xFF94A3B8),
      ),
      etaMins: 6,
      capacity: 4,
    ),
    VehicleTier(
      id: 'comfort',
      name: 'Comfort',
      description: 'Spacious & Air-conditioned',
      baseFareNpr: 180.0,
      perKmRate: 48.0,
      illustration: const Icon(
        Icons.local_taxi_rounded,
        size: 46,
        color: Color(0xFF94A3B8),
      ),
      etaMins: 8,
      capacity: 4,
    ),
  ];

  double _calculateFare(VehicleTier tier) {
    if (tier.id == 'bike' || tier.id == 'fastest') {
      return 46.0;
    }
    final raw = tier.baseFareNpr + (widget.distanceKm * tier.perKmRate);
    return raw.clamp(46.0, 9999.0);
  }

  void _showPaymentSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.money_rounded, color: Colors.green),
                  title: const Text('Cash on Delivery / Dropoff'),
                  trailing: _selectedPaymentMethod == 'Cash'
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.black,
                        )
                      : null,
                  onTap: () {
                    setState(() => _selectedPaymentMethod = 'Cash');
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Color(0xFF5C2D91),
                  ),
                  title: const Text('Khalti Digital Wallet'),
                  trailing: _selectedPaymentMethod == 'Khalti'
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.black,
                        )
                      : null,
                  onTap: () {
                    setState(() => _selectedPaymentMethod = 'Khalti');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedTier = _tiers[_selectedTierIndex];
    final fareNpr = _calculateFare(selectedTier);

    final pickupText =
        widget.pickup.title.isNotEmpty &&
            widget.pickup.title != 'Your location' &&
            widget.pickup.title != 'Current Location'
        ? widget.pickup.title
        : 'Udaypur fresh butcher shop';

    final destText = widget.destination.title.isNotEmpty
        ? widget.destination.title
        : 'sirjana nagar busstand';

    final durationMin = widget.durationMins > 0 ? widget.durationMins : 6;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Drag Handle
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 8),
                child: Container(
                  width: 46,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            // 2. Pickup & Destination Summary with Stops Pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Column(
                children: [
                  // Pickup row
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_walk_rounded,
                        color: Color(0xFF0F172A),
                        size: 20,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          pickupText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Destination row + Stops Button
                  Row(
                    children: [
                      const Icon(
                        Icons.flag_outlined,
                        color: Color(0xFF0F172A),
                        size: 20,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            text: destText,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                            children: [
                              const TextSpan(
                                text: '  •  ',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: '$durationMin min',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // "Stops" rounded button
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 14,
                      //     vertical: 6,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: const Color(0xFFF1F5F9),
                      //     borderRadius: BorderRadius.circular(16),
                      //   ),
                      //   child: const Text(
                      //     'Stops',
                      //     style: TextStyle(
                      //       fontSize: 12.5,
                      //       fontWeight: FontWeight.w800,
                      //       color: Color(0xFF334155),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            // 3. Tab Switcher: [Rides] [Delivery and Cargo]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? const Color(0xFFF1F5F9)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Rides',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _selectedTab == 0
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // GestureDetector(
                  //   onTap: () => setState(() => _selectedTab = 1),
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 12,
                  //       vertical: 7,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: _selectedTab == 1
                  //           ? const Color(0xFFF1F5F9)
                  //           : Colors.transparent,
                  //       borderRadius: BorderRadius.circular(16),
                  //     ),
                  //     child: Text(
                  //       'Delivery and Cargo',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w800,
                  //         color: _selectedTab == 1
                  //             ? const Color(0xFF0F172A)
                  //             : const Color(0xFF94A3B8),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Horizontal Scrollable Vehicle Category Cards
            SizedBox(
              height: 136,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tiers.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final tier = _tiers[index];
                  final isSelected = index == _selectedTierIndex;
                  final fare = _calculateFare(tier);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedTierIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 114,
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF1F5F9)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFCBD5E1)
                              : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Graphic / Illustration
                          Center(
                            child: SizedBox(
                              height: 48,
                              child: Center(child: tier.illustration),
                            ),
                          ),
                          const Spacer(),

                          // ETA tag (e.g. 5 min)
                          Text(
                            '${tier.etaMins} min',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 1),

                          // Tier Name (e.g. Bike / Fastest)
                          Text(
                            tier.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Price row with lightning icon if active
                          Row(
                            children: [
                              if (tier.hasLightning) ...[
                                const Icon(
                                  Icons.bolt_rounded,
                                  color: Color(0xFFFFB300),
                                  size: 14,
                                ),
                                const SizedBox(width: 1),
                              ],
                              Text(
                                tier.id == 'fastest'
                                    ? 'from Rs. ${fare.toStringAsFixed(0)}'
                                    : 'Rs. ${fare.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // 5. Bottom Action Bar (Payment Icon, Request Button, Settings/Filters Icon)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Teal Payment Card / Cash Stack Icon Button
                  InkWell(
                    onTap: _showPaymentSelection,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Container(
                          width: 28,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488), // Vibrant teal
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 7,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Vibrant Orange "Request" Button
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFFF4824,
                          ), // Vibrant Orange Red
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          widget.onConfirmBooking(
                            selectedTier: selectedTier,
                            fareNpr: fareNpr,
                            paymentMethod: _selectedPaymentMethod,
                          );
                        },
                        child: const Text(
                          'Request',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
