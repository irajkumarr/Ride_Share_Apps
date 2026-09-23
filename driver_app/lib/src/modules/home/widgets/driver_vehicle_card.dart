import 'package:flutter/material.dart';
import 'package:driver_app/src/data/remote/dto/vehicle_dto.dart';
import 'package:go_router/go_router.dart';

/// Vehicle card displayed inside the Driver Dashboard bottom sheet
/// Displays active vehicle details, license plate, category & fuel level with switch button.
class DriverVehicleCard extends StatelessWidget {
  const DriverVehicleCard({
    super.key,
    required this.activeVehicle,
    this.vehicles = const [],
    this.onVehicleSelected,
    this.fuelPercentage = 82,
  });

  final VehicleDto? activeVehicle;
  final List<VehicleDto> vehicles;
  final ValueChanged<VehicleDto>? onVehicleSelected;
  final int fuelPercentage;

  void _showSwitchVehicleModal(BuildContext context) {
    if (vehicles.isEmpty) {
      context.push('/vehicle-setup');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Vehicle',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.push('/vehicle-setup');
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add New'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...vehicles.map((v) {
                    final isSelected = activeVehicle?.id == v.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: isSelected
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFF8FAFC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.directions_car_filled_rounded,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          title: Text(
                            '${v.make} ${v.model}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text('${v.type} • ${v.licensePlate}'),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF22C55E),
                                )
                              : null,
                          onTap: () {
                            onVehicleSelected?.call(v);
                            Navigator.pop(ctx);
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Left Car Outline Icon Container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.directions_car_rounded,
                color: Color(0xFF0F172A),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Vehicle Title & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        activeVehicle != null
                            ? '${activeVehicle!.make} ${activeVehicle!.model}'
                            : 'No Vehicle Registered',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (activeVehicle?.licensePlate != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          activeVehicle!.licensePlate,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      activeVehicle != null
                          ? activeVehicle!.type.toUpperCase()
                          : 'Tap Switch to add',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right "Switch >" Button
          GestureDetector(
            onTap: () => _showSwitchVehicleModal(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Switch',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
