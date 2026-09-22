import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class RideOption {
  final String id;
  final String name;
  final String description;
  final double fareMultiplier;
  final IconData icon;
  final int etaMinutes;

  const RideOption({
    required this.id,
    required this.name,
    required this.description,
    required this.fareMultiplier,
    required this.icon,
    required this.etaMinutes,
  });
}

class RideSelectionDrawer extends StatefulWidget {
  final AddressModel pickup;
  final AddressModel destination;
  final VoidCallback onCancel;
  final void Function(RideOption selectedRide) onConfirmRide;

  const RideSelectionDrawer({
    super.key,
    required this.pickup,
    required this.destination,
    required this.onCancel,
    required this.onConfirmRide,
  });

  @override
  State<RideSelectionDrawer> createState() => _RideSelectionDrawerState();
}

class _RideSelectionDrawerState extends State<RideSelectionDrawer> {
  int _selectedOptionIndex = 0;

  static const List<RideOption> _options = [
    RideOption(
      id: 'moto',
      name: 'Rider Moto',
      description: 'Fastest single passenger ride',
      fareMultiplier: 1.0,
      icon: Icons.two_wheeler_rounded,
      etaMinutes: 3,
    ),
    RideOption(
      id: 'sedan',
      name: 'Rider Classic',
      description: 'Comfortable 4-seater car',
      fareMultiplier: 2.2,
      icon: Icons.directions_car_filled_rounded,
      etaMinutes: 5,
    ),
    RideOption(
      id: 'xl',
      name: 'Rider XL',
      description: 'Spacious 6-seater SUV',
      fareMultiplier: 3.5,
      icon: Icons.airport_shuttle_rounded,
      etaMinutes: 7,
    ),
  ];

  double _calculateFare(double multiplier) {
    // Basic estimated calculation based on distance
    const baseFare = 3.50;
    return (baseFare * multiplier * 2.8);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag indicator & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: widget.onCancel,
                  ),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColor.borderGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 48), // Balancing spacer
                ],
              ),
              const SizedBox(height: 8),

              // Route Brief Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.darkGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.navigation_rounded, size: 16, color: AppColor.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.pickup.title} → ${widget.destination.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Ride Options List
              ...List.generate(_options.length, (index) {
                final opt = _options[index];
                final isSelected = _selectedOptionIndex == index;
                final fare = _calculateFare(opt.fareMultiplier);

                return GestureDetector(
                  onTap: () => setState(() => _selectedOptionIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColor.lightPurple : AppColor.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.black : AppColor.borderGrey.withValues(alpha: 0.5),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : AppColor.darkGray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            opt.icon,
                            color: isSelected ? AppColor.primary : Colors.black87,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    opt.name,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColor.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${opt.etaMinutes} min',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                opt.description,
                                style: const TextStyle(color: AppColor.gray, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${fare.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),

              // Confirm Ride Button
              CustomButton(
                text: 'Confirm ${_options[_selectedOptionIndex].name}',
                width: double.infinity,
                height: 52,
                borderRadius: 14,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                onPressed: () {
                  widget.onConfirmRide(_options[_selectedOptionIndex]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
