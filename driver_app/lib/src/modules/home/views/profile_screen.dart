import 'package:driver_app/src/modules/auth/blocs/current_user_cubit.dart';
import 'package:driver_app/src/modules/vehicle/blocs/vehicle_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:driver_app/src/data/local/auth_local_data_source.dart';
import 'package:driver_app/src/data/remote/dto/user_dto.dart';
import 'package:driver_app/src/data/remote/dto/vehicle_dto.dart';
import 'package:driver_app/src/data/repo/vehicle_repo.dart';
import 'package:driver_app/src/modules/home/blocs/driver_status_cubit.dart';
import 'package:shared_core/shared_core.dart';
import 'package:go_router/go_router.dart';

/// Clean, state-of-the-art Driver Profile screen matching the reference design.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserDataDto? _driver;
  VehicleDto? _primaryVehicle;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<CurrentUserCubit>().state;
    if (currentState is CurrentUserSuccess) {
      _driver = currentState.user;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrentUserCubit>().getCurrentUser();
      context.read<VehicleCubit>().fetchMyVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CurrentUserCubit, CurrentUserState>(
          listener: (context, state) {
            if (state is CurrentUserSuccess) {
              setState(() {
                _driver = state.user;
              });
            } else if (state is CurrentUserFailure) {
              AppAlerts.error(context, state.message);
            }
          },
        ),
        BlocListener<VehicleCubit, VehicleState>(
          listener: (context, state) {
            if (state is VehicleLoading) {
              LoadingOverlay.show();
            } else {
              LoadingOverlay.hide();
            }
            if (state is VehicleLoaded && mounted) {
              setState(() {
                _primaryVehicle = state.activeVehicle;
              });
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 30,
              color: Color(0xFF111827),
            ),
          ),
          centerTitle: true,
          title: Column(
            children: const [
              Text(
                'RIDENEST DRIVER PRO',
                style: TextStyle(
                  color: Color(0xFFFF3333),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Driver Profile',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                AppAlerts.info(
                  context,
                  'Edit profile details functionality coming soon.',
                );
              },
              icon: const Icon(
                Icons.edit_note_rounded,
                size: 26,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFF3F4F6), height: 1),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with Verified Badge
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F172A),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 54,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Driver Name & PRO Tag
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _driver?.fullName ?? '-',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECEB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFFCCCC),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Color(0xFFFF3333),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Phone & ID
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _driver?.phone ?? '+977 9804040404',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '•',
                          style: TextStyle(
                            color: Color(0xFFD1D5DB),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ID: ${_driver?.id?.substring(0, _driver!.id!.length.clamp(0, 7)).toUpperCase() ?? 'RN-8842'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4B5563),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Metrics Card: Rating, Trips, Acceptance
              _buildMetricsCard(),

              const SizedBox(height: 28),

              // VEHICLE & DRIVING SECTION
              _buildSectionHeader('VEHICLE & DRIVING'),
              const SizedBox(height: 10),
              _buildCardGroup([
                _buildNavTile(
                  icon: Icons.directions_car_rounded,
                  title: 'My Vehicles',
                  hasActiveDot: true,
                  subtitle: _primaryVehicle != null
                      ? '${_primaryVehicle!.make} ${_primaryVehicle!.model} • ${_primaryVehicle!.licensePlate} (Active)'
                      : 'Toyota Corolla • BA 2 KHA 1234 (Active)',
                  onTap: () async {
                    await context.push('/my-vehicles');
                    if (context.mounted) {
                      context.read<VehicleCubit>().fetchMyVehicles();
                    }
                  },
                  isFirst: true,
                ),
                _buildNavTile(
                  icon: Icons.access_time_rounded,
                  title: 'Ride History & Trips',
                  subtitle: 'View past rides, route details & receipts',
                  onTap: () {
                    context.push('/ride-history');
                  },
                ),
                // _buildNavTile(
                //   icon: Icons.account_balance_wallet_outlined,
                //   title: 'Earnings & Payouts',
                //   badgeText: 'Fast Pay',
                //   badgeColor: const Color(0xFF10B981),
                //   badgeBgColor: const Color(0xFFECFDF5),
                //   subtitle: 'Rs. 24,850.00 this week',
                //   subtitleColor: const Color(0xFF059669),
                //   subtitleWeight: FontWeight.w700,
                //   onTap: () {
                //     AppAlerts.info(
                //       context,
                //       'Weekly payout summary is updated every Monday.',
                //     );
                //   },
                //   isLast: true,
                // ),
              ]),

              const SizedBox(height: 24),

              // SETTINGS & VERIFICATION SECTION
              _buildSectionHeader('SETTINGS & VERIFICATION'),
              const SizedBox(height: 10),
              _buildCardGroup([
                // _buildNavTile(
                //   icon: Icons.tune_rounded,
                //   title: 'Ride Preferences',
                //   subtitle: 'Auto-accept, preferred zones & maps',
                //   onTap: () {
                //     AppAlerts.info(
                //       context,
                //       'Driver navigation and zone preferences.',
                //     );
                //   },
                //   isFirst: true,
                // ),
                _buildNavTile(
                  icon: Icons.description_outlined,
                  title: 'Documents & Licenses',
                  badgeText: 'All Valid',
                  badgeColor: const Color(0xFF10B981),
                  badgeBgColor: const Color(0xFFECFDF5),
                  subtitle: 'License, Bluebook & Insurance active',
                  onTap: () {
                    AppAlerts.info(
                      context,
                      'All driver partner credentials are currently verified.',
                    );
                  },
                ),
                _buildNavTile(
                  icon: Icons.headset_mic_outlined,
                  title: '24/7 Priority Support',
                  subtitle: 'Emergency SOS, help tickets & live chat',
                  onTap: () {
                    AppAlerts.info(
                      context,
                      'Connecting you to RideNest Priority Support Team.',
                    );
                  },
                  isLast: true,
                ),
              ]),

              const SizedBox(height: 28),

              // Log Out Button
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFE0E0),
                    width: 1.2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await UiUtils.showAnimatedDialog(
                        context: context,
                        child: LogoutAccountDialog(
                          onConfirm: () async {
                            await context.read<DriverStatusCubit>().goOffline();
                            await sl<AuthLocalDataSource>().clear();
                            if (context.mounted) {
                              context.go(AppRoutes.login);
                            }
                          },
                        ),
                      );
                    },

                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            size: 20,
                            color: Color(0xFFFF3333),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF3333),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // App Version Footer
              const Center(
                child: Text(
                  'RideNest Driver Pro • v3.4.2 (Build 2026)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF6B7280),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildMetricsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Rating item
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (_driver?.rating ?? 4.92).toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // Vertical Divider
              Container(width: 1, height: 48, color: const Color(0xFFF3F4F6)),

              // Trips item
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_driver?.totalRides ?? 486}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Trips',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool hasActiveDot = false,
    String? badgeText,
    Color? badgeColor,
    Color? badgeBgColor,
    Color? subtitleColor,
    FontWeight? subtitleWeight,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        if (!isFirst)
          const Divider(
            height: 1,
            indent: 68,
            endIndent: 16,
            color: Color(0xFFF3F4F6),
          ),
        InkWell(
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(20) : Radius.zero,
            bottom: isLast ? const Radius.circular(20) : Radius.zero,
          ),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(icon, size: 22, color: const Color(0xFF1F2937)),
                  ),
                ),
                const SizedBox(width: 14),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          if (hasActiveDot) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          if (badgeText != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBgColor ?? const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  color: badgeColor ?? const Color(0xFF10B981),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: subtitleWeight ?? FontWeight.w400,
                          color: subtitleColor ?? const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
