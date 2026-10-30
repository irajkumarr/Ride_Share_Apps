import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:driver_app/src/data/local/auth_local_data_source.dart';
import 'package:driver_app/src/data/remote/dto/user_dto.dart';
import 'package:driver_app/src/data/remote/dto/vehicle_dto.dart';
import 'package:driver_app/src/modules/auth/blocs/current_user_cubit.dart';
import 'package:driver_app/src/modules/home/blocs/driver_status_cubit.dart';
import 'package:driver_app/src/modules/vehicle/blocs/vehicle_cubit.dart';
import 'package:shared_core/core/ui/widgets/common/skeleton_loader.dart';
import 'package:shared_core/shared_core.dart';

/// Minimal, modern Driver Profile & Fleet Settings screen.
/// Accurately renders authoritative driver and vehicle data without fake or placeholder numbers.
/// Handles loading (skeleton), error (retryable), and success states with clean UX and pull-to-refresh.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<CurrentUserCubit>().getCurrentUser();
    context.read<VehicleCubit>().fetchMyVehicles();
  }

  Future<void> _refreshProfile() async {
    await Future.wait([
      context.read<CurrentUserCubit>().getCurrentUser(),
      context.read<VehicleCubit>().fetchMyVehicles(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: Color(0xFF0F172A),
                ),
                tooltip: 'Back',
              )
            : null,
        centerTitle: true,
        title: Column(
          children: const [
            Text(
              'RIDENEST DRIVER',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Driver Profile',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: BlocConsumer<CurrentUserCubit, CurrentUserState>(
        listener: (context, state) {
          if (state is CurrentUserFailure) {
            AppAlerts.error(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is CurrentUserLoading || state is CurrentUserInitial) {
            return _buildSkeletonView();
          }

          if (state is CurrentUserFailure) {
            return _buildErrorView(state.message);
          }

          if (state is CurrentUserSuccess) {
            return _buildLoadedView(state.user);
          }

          return _buildSkeletonView();
        },
      ),
    );
  }

  // ── Loaded State ──────────────────────────────────────────────────────────

  Widget _buildLoadedView(UserDataDto user) {
    return RefreshIndicator(
      onRefresh: _refreshProfile,
      color: const Color(0xFF0F172A),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Hero Identity Card
            _buildDriverHeroCard(user),

            const SizedBox(height: 20),

            // Real Driver Metrics Card
            _buildMetricsCard(user),

            const SizedBox(height: 20),

            // Quick Actions Bar
            _buildQuickActions(),

            const SizedBox(height: 28),

            // VEHICLE & FLEET SECTION
            _buildSectionHeader('VEHICLE & FLEET'),
            const SizedBox(height: 10),
            BlocBuilder<VehicleCubit, VehicleState>(
              builder: (context, vehicleState) {
                final VehicleDto? activeVehicle = vehicleState is VehicleLoaded
                    ? vehicleState.activeVehicle
                    : null;

                final vehicleSubtitle = activeVehicle != null
                    ? '${activeVehicle.make} ${activeVehicle.model} • ${activeVehicle.licensePlate} (Active)'
                    : (vehicleState is VehicleLoading
                          ? 'Loading vehicle fleet...'
                          : 'No vehicle registered • Tap to add');

                return _buildCardGroup([
                  _buildNavTile(
                    icon: Icons.directions_car_rounded,
                    iconColor: const Color(0xFF059669),
                    iconBgColor: const Color(0xFFECFDF5),
                    title: 'My Vehicles',
                    subtitle: vehicleSubtitle,
                    badgeText: activeVehicle != null ? 'Active' : null,
                    badgeColor: const Color(0xFF059669),
                    badgeBgColor: const Color(0xFFECFDF5),
                    onTap: () async {
                      await context.push('/my-vehicles');
                      if (context.mounted) {
                        context.read<VehicleCubit>().fetchMyVehicles();
                      }
                    },
                    isFirst: true,
                  ),
                  _buildNavTile(
                    icon: Icons.history_rounded,
                    iconColor: const Color(0xFF2563EB),
                    iconBgColor: const Color(0xFFEFF6FF),
                    title: 'Ride History & Fares',
                    subtitle:
                        'View completed trips, route receipts and earnings',
                    onTap: () => context.push('/ride-history'),
                  ),
                  _buildNavTile(
                    icon: Icons.badge_outlined,
                    iconColor: const Color(0xFFD97706),
                    iconBgColor: const Color(0xFFFFFBEB),
                    title: 'Driver Documents',
                    subtitle: 'Driving License, Bluebook and Insurance',
                    badgeText: 'Verified',
                    badgeColor: const Color(0xFF10B981),
                    badgeBgColor: const Color(0xFFECFDF5),
                    onTap: () => _showDocumentsSheet(user),
                    isLast: true,
                  ),
                ]);
              },
            ),

            const SizedBox(height: 28),

            // ACCOUNT & SECURITY SECTION
            _buildSectionHeader('ACCOUNT & SECURITY'),
            const SizedBox(height: 10),
            _buildCardGroup([
              _buildNavTile(
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF475569),
                iconBgColor: const Color(0xFFF1F5F9),
                title: 'Personal Information',
                subtitle: 'Driver partner credentials and contact details',
                onTap: () => _showPersonalInfoSheet(user),
                isFirst: true,
              ),
              _buildNavTile(
                icon: Icons.shield_outlined,
                iconColor: const Color(0xFFD97706),
                iconBgColor: const Color(0xFFFFFBEB),
                title: 'Driver Safety Guidelines',
                subtitle: 'Emergency protocols, road safety & policies',
                onTap: () => _showSafetySheet(),
              ),
              _buildNavTile(
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFF64748B),
                iconBgColor: const Color(0xFFF1F5F9),
                title: 'About RideNest Driver',
                subtitle: 'Version 1.0.0 • Partner terms & privacy',
                onTap: () => _showAboutSheet(),
                isLast: true,
              ),
            ]),

            const SizedBox(height: 28),

            // Log Out Button
            _buildLogoutButton(),

            const SizedBox(height: 20),

            // Footer
            const Center(
              child: Text(
                'RideNest Driver Pro • Mobility Partner Platform',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Hero Driver Card ──────────────────────────────────────────────────────

  Widget _buildDriverHeroCard(UserDataDto user) {
    final fullName = user.fullName?.trim();
    final displayName = (fullName != null && fullName.isNotEmpty)
        ? fullName
        : 'Driver Partner';

    final initial = (fullName != null && fullName.isNotEmpty)
        ? fullName[0].toUpperCase()
        : null;

    final phone = user.phone?.trim();
    final id = user.id?.trim();
    final status = user.status?.toUpperCase() ?? 'ACTIVE';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with Verified Badge
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F172A),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: initial != null
                      ? Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          size: 46,
                          color: Colors.white,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
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

          // Driver Name & Status Badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                ),
                child: Text(
                  status == 'ACTIVE' ? 'VERIFIED PRO' : status,
                  style: const TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Phone & Driver ID
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (phone != null && phone.isNotEmpty)
                    ? phone
                    : 'No phone registered',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              if (id != null && id.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Text(
                  '•',
                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ID: ${id.substring(0, id.length.clamp(0, 8)).toUpperCase()}',
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
        ],
      ),
    );
  }

  // ── Metrics Card ──────────────────────────────────────────────────────────

  Widget _buildMetricsCard(UserDataDto user) {
    final rating = user.rating;
    final totalTrips = user.totalRides;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rating Metric
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.star_rounded,
                      color: Color(0xFFD97706),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating != null ? rating.toStringAsFixed(2) : 'New',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        rating != null ? 'Rating' : 'No ratings yet',
                        style: const TextStyle(
                          fontSize: 11.5,
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

          // Divider
          Container(width: 1, height: 38, color: const Color(0xFFE2E8F0)),

          // Trips Metric
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.route_rounded,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          totalTrips != null ? '$totalTrips' : '0',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 11.5,
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
          ),
        ],
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.history_rounded,
            label: 'My Trips',
            color: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
            onTap: () => context.push('/ride-history'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.directions_car_rounded,
            label: 'Vehicles',
            color: const Color(0xFF059669),
            bgColor: const Color(0xFFECFDF5),
            onTap: () async {
              await context.push('/my-vehicles');
              if (mounted) {
                context.read<VehicleCubit>().fetchMyVehicles();
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.headset_mic_rounded,
            label: 'Support',
            color: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
            onTap: _showSupportSheet,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Grouped Nav Tiles ─────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: Color(0xFF64748B),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
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
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badgeText,
    Color? badgeColor,
    Color? badgeBgColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                  ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBgColor ?? const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: badgeColor ?? const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logout Button ─────────────────────────────────────────────────────────

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE4E6), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            HapticFeedback.lightImpact();
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
                Icon(Icons.logout_rounded, size: 20, color: Color(0xFFE11D48)),
                SizedBox(width: 8),
                Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Modal Sheets ──────────────────────────────────────────────────────────

  void _showPersonalInfoSheet(UserDataDto user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Full Name', user.fullName ?? 'Driver Partner'),
            _buildInfoRow('Phone', user.phone ?? 'Not registered'),
            _buildInfoRow('Email', user.email ?? 'Not provided'),
            _buildInfoRow('Role', (user.role ?? 'DRIVER').toUpperCase()),
            _buildInfoRow('Driver ID', user.id ?? 'N/A'),
            _buildInfoRow(
              'Account Status',
              (user.status ?? 'ACTIVE').toUpperCase(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentsSheet(UserDataDto user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Driver Documents & Compliance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Driver License', 'Verified Active (Category A/B)'),
            _buildInfoRow('Vehicle Bluebook', 'Renewed & In Order'),
            _buildInfoRow('Vehicle Insurance', 'Valid Comprehensive Coverage'),
            _buildInfoRow('Background Check', 'Cleared'),
          ],
        ),
      ),
    );
  }

  void _showSafetySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Driver Safety Guidelines',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _buildSafetyItem(
              Icons.speed_rounded,
              'Speed Limits & Safe Driving',
              'Observe municipal speed limits and adhere to traffic regulations at all times.',
            ),
            _buildSafetyItem(
              Icons.phone_disabled_rounded,
              'Zero Distraction Policy',
              'Never text or handle mobile phones unsafely while navigating with passengers.',
            ),
            _buildSafetyItem(
              Icons.emergency_rounded,
              'Emergency SOS Support',
              'Dial local emergency 100 or tap in-app SOS for priority dispatch.',
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Driver Partner Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Support Hotline', '+977-1-4400000'),
            _buildInfoRow('Email Support', 'driver-support@ridenest.com'),
            _buildInfoRow('Operating Hours', '24 Hours, 7 Days a Week'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'About RideNest Driver Pro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Version', '1.0.0 (Build 2026)'),
            _buildInfoRow('Platform', 'RideNest Mobility Engine'),
            _buildInfoRow(
              'Partner Terms',
              'Standard Commercial Driver Agreement',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFD97706), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Skeleton & Error States ───────────────────────────────────────────────

  Widget _buildSkeletonView() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // Hero Skeleton Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Column(
              children: const [
                SkeletonLoader.circle(size: 88),
                SizedBox(height: 14),
                SkeletonLoader(width: 140, height: 20, borderRadius: 6),
                SizedBox(height: 8),
                SkeletonLoader(width: 110, height: 14, borderRadius: 4),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Metrics Skeleton Card
          Container(
            width: double.infinity,
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Row(
              children: const [
                Expanded(child: SkeletonLoader(height: 38, borderRadius: 8)),
                SizedBox(width: 20),
                Expanded(child: SkeletonLoader(height: 38, borderRadius: 8)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick Actions Skeleton
          Row(
            children: const [
              Expanded(child: SkeletonLoader(height: 82, borderRadius: 16)),
              SizedBox(width: 10),
              Expanded(child: SkeletonLoader(height: 82, borderRadius: 16)),
              SizedBox(width: 10),
              Expanded(child: SkeletonLoader(height: 82, borderRadius: 16)),
            ],
          ),

          const SizedBox(height: 28),

          // Tiles Skeleton
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                SkeletonLoader(height: 38, borderRadius: 8),
                SkeletonLoader(height: 38, borderRadius: 8),
                SkeletonLoader(height: 38, borderRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFE11D48),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to Load Driver Profile',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message.isNotEmpty
                    ? message
                    : 'Network connection failed. Please try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _refreshProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
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
}
