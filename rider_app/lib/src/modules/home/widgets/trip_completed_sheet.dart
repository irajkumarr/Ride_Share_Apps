import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import '../../../data/remote/ride_api_service.dart';

class TripCompletedSheet extends StatefulWidget {
  final RideBookingModel booking;
  final DriverModel? driver;
  final String? message;
  final VoidCallback onDismiss;

  const TripCompletedSheet({
    super.key,
    required this.booking,
    this.driver,
    this.message,
    required this.onDismiss,
  });

  @override
  State<TripCompletedSheet> createState() => _TripCompletedSheetState();
}

class _TripCompletedSheetState extends State<TripCompletedSheet> {
  int _selectedRating = 5;
  final Set<String> _selectedCompliments = {'Great driving 🛵', 'On time ⏱️'};
  int _selectedTipAmount = 0; // 0 = No tip, 10, 20, 50, -1 = custom

  final List<String> _compliments = [
    'Great driving 🛵',
    'On time ⏱️',
    'Polite & friendly 😊',
    'Safe ride 🛡️',
    'Clean helmet 🪖',
  ];

  @override
  Widget build(BuildContext context) {
    final driverName = widget.driver?.name.isNotEmpty == true
        ? widget.driver!.name
        : (widget.booking.driver?.name.isNotEmpty == true
              ? widget.booking.driver!.name
              : 'Bikash Sharma');

    final driverFirstName = driverName.split(' ').first;

    final vehicleModel = widget.driver?.vehicleModel.isNotEmpty == true
        ? widget.driver!.vehicleModel
        : 'Red Honda Shine';

    final licensePlate = widget.driver?.licensePlate.isNotEmpty == true
        ? widget.driver!.licensePlate
        : 'BA 2 PA 4092';

    final rating = (widget.driver != null && widget.driver!.rating > 0)
        ? widget.driver!.rating
        : 4.9;

    final fareDisplay = widget.booking.fareNpr > 0
        ? 'Rs. ${widget.booking.fareNpr.toStringAsFixed(0)}'
        : 'Rs. 46';

    final pickupTitle = widget.booking.pickup.title.isNotEmpty
        ? widget.booking.pickup.title
        : 'Udaypur fresh butcher shop';

    final destTitle = widget.booking.destination.title.isNotEmpty
        ? widget.booking.destination.title
        : 'Sirjana nagar busstand';

    final paymentDisplay = widget.booking.paymentMethod.isNotEmpty
        ? widget.booking.paymentMethod
        : 'eSewa digital wallet';

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      snap: true,
      builder: (context, scrollController) {
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
          child: Column(
            children: [
              // Top drag handle
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    // 1. "You have arrived!" Arrival Banner Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFECFDF5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle_outline_rounded,
                                color: Color(0xFF10B981),
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.message?.isNotEmpty == true
                                      ? widget.message!
                                      : 'You have arrived!',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Dropped off at $destTitle',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. TOTAL FARE PAID Card with Receipt button
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'TOTAL FARE PAID',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Paid',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  ToastOverlay.show(
                                    'Receipt downloaded to device',
                                    type: ToastType.success,
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Receipt',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.receipt_long_rounded,
                                        size: 15,
                                        color: Color(0xFF64748B),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                fareDisplay,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '(Standard Nest Tier)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_user_rounded,
                                color: Color(0xFF10B981),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Settled via $paymentDisplay',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Driver Info & Feedback Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Driver Row
                          Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFF1F5F9),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child:
                                          widget.driver?.photoUrl.isNotEmpty ==
                                              true
                                          ? Image.network(
                                              widget.driver!.photoUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Center(
                                                    child: Text(
                                                      driverFirstName.substring(
                                                        0,
                                                        1,
                                                      ),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 18,
                                                        color: Color(
                                                          0xFF475569,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                            )
                                          : Center(
                                              child: Text(
                                                driverFirstName.substring(0, 1),
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driverName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F172A),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$vehicleModel • $licensePlate',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.two_wheeler_rounded,
                                            size: 12,
                                            color: Color(0xFF0D9488),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Certified Nest Pilot',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0D9488),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFFDE68A),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFFF59E0B),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // "How was your ride with Bikash?"
                          Text(
                            'How was your ride with $driverFirstName?',
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap stars to share feedback',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 5 Golden Stars
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final starIndex = index + 1;
                              return IconButton(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() => _selectedRating = starIndex);
                                },
                                icon: Icon(
                                  starIndex <= _selectedRating
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 34,
                                  color: const Color(
                                    0xFFF59E0B,
                                  ), // Vibrant Amber
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 16),

                          // "WHAT WENT REMARKABLY WELL?" Tag Chips
                          Align(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'WHAT WENT REMARKABLY WELL?',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _compliments.map((compliment) {
                              final isSelected = _selectedCompliments.contains(
                                compliment,
                              );
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedCompliments.remove(compliment);
                                    } else {
                                      _selectedCompliments.add(compliment);
                                    }
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(
                                            0xFF0F172A,
                                          ) // Dark slate selected
                                        : const Color(0xFFF1F5F9), // Light grey
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    compliment,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),

                          // "ADD A TIP FOR BIKASH (100% TO PILOT)"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ADD A TIP FOR $driverFirstName (100% TO PILOT)',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              Text(
                                _selectedTipAmount == 0
                                    ? 'No tip'
                                    : 'Rs. $_selectedTipAmount',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFF97316),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Tip Selection Row: [No tip] [+ Rs. 10] [+ Rs. 20] [+ Rs. 50] [Custom]
                          Row(
                            children: [
                              _buildTipChip(label: 'No tip', amount: 0),
                              const SizedBox(width: 6),
                              _buildTipChip(label: '+ Rs. 10', amount: 10),
                              const SizedBox(width: 6),
                              _buildTipChip(label: '+ Rs. 20', amount: 20),
                              const SizedBox(width: 6),
                              _buildTipChip(label: '+ Rs. 50', amount: 50),
                              const SizedBox(width: 6),
                              _buildTipChip(label: 'Custom', amount: -1),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. TRIP TRAJECTORY Timeline Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TRIP TRAJECTORY',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '2.4 km • 6 min transit',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Pickup Point
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F172A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '6:26 PM • PICKUP',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      pickupTitle,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Vertical connecting line
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Container(
                              width: 2,
                              height: 20,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),

                          // Destination Point
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.only(top: 2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF9800), // Orange dot
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '6:32 PM • DESTINATION',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      destTitle,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
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
                    const SizedBox(height: 14),

                    // 5. Secondary Options Row: [Report an issue] and [Find lost item]
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                ToastOverlay.show(
                                  'Support ticket opened',
                                  type: ToastType.normal,
                                );
                              },
                              icon: const Icon(
                                Icons.support_agent_rounded,
                                size: 17,
                                color: Color(0xFF0F172A),
                              ),
                              label: const Text(
                                'Report an issue',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                ToastOverlay.show(
                                  'Driver alerted about lost item request',
                                  type: ToastType.normal,
                                );
                              },
                              icon: const Icon(
                                Icons.inventory_2_outlined,
                                size: 17,
                                color: Color(0xFF0F172A),
                              ),
                              label: const Text(
                                'Find lost item',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 6. Main Action: "Submit & Return to Home →"
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF062828,
                          ), // Dark spruce navy
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          AppAlerts.success(
                            context,
                            'Thank you for riding with us',
                          );
                          widget.onDismiss();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Submit & Return to Home',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Footer: "Your receipt has been sent to your registered email."
                    const Center(
                      child: Text(
                        'Your receipt has been sent to your registered email.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipChip({required String label, required int amount}) {
    final isSelected = _selectedTipAmount == amount;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (amount == -1) {
            ToastOverlay.show(
              'Enter custom tip amount',
              type: ToastType.normal,
            );
          }
          setState(() => _selectedTipAmount = amount);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0F172A)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
