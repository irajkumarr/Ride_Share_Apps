import 'package:flutter/material.dart';
import 'package:driver_app/src/modules/home/blocs/driver_status_cubit.dart';

/// Top bar in Driver Home containing Profile initials avatar,
/// dark teal OFFLINE/ONLINE status pill with "TAP TO GO" hint,
/// Map layers action button, and GPS recenter button.
class DriverStatusTopBar extends StatelessWidget {
  const DriverStatusTopBar({
    super.key,
    required this.driverStatusState,
    required this.driverInitials,
    required this.onProfileTap,
    required this.onStatusTap,
    required this.onLayersTap,
    required this.onRecenterTap,
    this.isMapNormal = true,
    this.isMuted = false,
    this.onSoundToggle,
    this.isIncomingRequest = false,
  });

  final DriverStatusState driverStatusState;
  final String driverInitials;
  final VoidCallback onProfileTap;
  final VoidCallback onStatusTap;
  final VoidCallback onLayersTap;
  final VoidCallback onRecenterTap;
  final bool isMapNormal;
  final bool isMuted;
  final VoidCallback? onSoundToggle;
  final bool isIncomingRequest;

  @override
  Widget build(BuildContext context) {
    final isOnline = driverStatusState.status == DriverShiftStatus.available;
    final isOnRide = driverStatusState.status == DriverShiftStatus.onRide;
    final isUpdating = driverStatusState.isUpdating;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // 1. Left Profile Avatar Pill with notification dot
          GestureDetector(
            onTap: onProfileTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF132226),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          driverInitials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Top-right Red Alert Badge Dot
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // 2. Central Dark Teal Capsule Status Pill
          Expanded(
            child: GestureDetector(
              onTap: (isUpdating || isOnRide) ? null : onStatusTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF132A2F),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF132A2F).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Glowing Status Dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline
                            ? const Color(0xFF22C55E)
                            : (isOnRide
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFFEF4444)),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isOnline
                                        ? const Color(0xFF22C55E)
                                        : (isOnRide
                                              ? const Color(0xFF38BDF8)
                                              : const Color(0xFFEF4444)))
                                    .withValues(alpha: 0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Status Label
                    Expanded(
                      child: Text(
                        isIncomingRequest
                            ? 'ONLINE • RADAR ACTIVE'
                            : (isOnRide
                                  ? 'ON TRIP'
                                  : (isOnline ? 'ONLINE' : 'OFFLINE')),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    if (!isIncomingRequest) ...[
                      // Divider
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      const SizedBox(width: 10),

                      // Right action hint
                      if (isUpdating)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      else
                        Text(
                          isOnline ? 'TAP TO STOP' : 'TAP TO\nGO',
                          style: TextStyle(
                            color: const Color(0xFF00B4A0)
                                .withValues(alpha: 0.9),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // 3. Right Action Button (Sound Toggle if incoming request, or Map Layers normally)
          if (isIncomingRequest && onSoundToggle != null) ...[
            GestureDetector(
              onTap: onSoundToggle,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isMuted
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    color: const Color(0xFF1E293B),
                    size: 22,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Map Layers Quick Action Button
            GestureDetector(
              onTap: onLayersTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.layers_rounded,
                    color: isMapNormal
                        ? const Color(0xFF1E293B)
                        : const Color(0xFF00B4A0),
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // GPS Recenter Button
            GestureDetector(
              onTap: onRecenterTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.my_location_rounded,
                    color: Color(0xFF1E293B),
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
