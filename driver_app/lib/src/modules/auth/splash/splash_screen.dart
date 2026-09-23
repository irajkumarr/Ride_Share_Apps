import 'package:driver_app/src/data/local/auth_local_data_source.dart';
import 'package:driver_app/src/data/repo/vehicle_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

/// Driver splash screen matching the state-of-the-art reference design:
/// - Soft warm ambient background with subtle contour road tracks
/// - Glassmorphic / soft-glowing rounded card with RideNest heart-bird logo
/// - Mini floating black circular badge with car icon overlapping bottom-right
/// - "RideNest" title with "PRO" pill
/// - "DRIVER PARTNER PLATFORM" caption
/// - Motivational tagline: "Partner with freedom." & "Earn on your terms."
/// - Red circular progress ring
/// - Bottom status badge: "✔ Secure Dispatch Active • v3.4.2"
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _checkAuth();
      }
    });
  }

  Future<void> _checkAuth() async {
    final accessToken = await sl<SecureStorageService>().getAccessToken();
    final isLoggedIn =
        sl<LocalStorageService>().getBool(LocalStorageKeys.isLoggedIn) ?? false;
    final hasUserAuth =
        isLoggedIn && accessToken != null && accessToken.trim().isNotEmpty;

    if (!mounted) return;

    if (hasUserAuth) {
      final cachedDriver = await sl<AuthLocalDataSource>().getCachedDriver();
      if (cachedDriver?.role?.toUpperCase() != 'DRIVER') {
        await sl<AuthLocalDataSource>().clear();
        if (!mounted) return;
        context.go(AppRoutes.login);
        return;
      }

      bool hasVehicle = true;
      try {
        final vehicles = await sl<VehicleRepo>().getMyVehicles();
        hasVehicle = vehicles.isNotEmpty;
      } catch (_) {}

      if (!mounted) return;

      if (!hasVehicle) {
        context.go('/vehicle-setup?fromRegistration=true');
      } else {
        context.go(AppRoutes.home);
      }
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background subtle warm glow & ambient gradients
          Positioned(
            top: -120,
            left: -80,
            right: -80,
            height: 520,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.9,
                  colors: [
                    const Color(0xFFFF5252).withValues(alpha: 0.08),
                    const Color(0xFFFF8A80).withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            height: 380,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    const Color(0xFFFF3333).withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Custom Painter for subtle dashed curved contour lines
          const Positioned.fill(
            child: CustomPaint(painter: _SplashContourPainter()),
          ),

          // Main Center Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Animated Logo + Info Block
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo Card with glowing backdrop & Car Badge
                        _buildLogoContainer(),

                        const SizedBox(height: 34),

                        // RideNest Brand + PRO pill
                        _buildBrandRow(),

                        const SizedBox(height: 14),

                        // Subheading Caption
                        const Text(
                          'DRIVER PARTNER PLATFORM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Color(0xFF94A3B8),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tagline 1
                        const Text(
                          'Partner with freedom.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF475569),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Tagline 2
                        const Text(
                          'Earn on your terms.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Red Loading Spinner Ring
                SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF3333),
                    ),
                    backgroundColor: const Color(0xFFFF3333)
                        .withValues(alpha: 0.12),
                  ),
                ),

                const Spacer(flex: 2),

                // Bottom Footer: Secure Dispatch Active • v3.4.2
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: AppVersionBuilder(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoContainer() {
    return Center(
      child: SizedBox(
        width: 154,
        height: 154,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Ambient red outer glow
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(42),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3333).withValues(alpha: 0.22),
                      blurRadius: 40,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),

            // White rounded container
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(38),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.95),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/ridenest_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/icons/ridenest_logo_pro.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.navigation_rounded,
                        color: Color(0xFFFF3333),
                        size: 54,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Overlapping Bottom-Right Dark Car Badge
            Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.directions_car_rounded,
                    color: Color(0xFFFF4D4F),
                    size: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'RideNest',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4.5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4D4F), Color(0xFFFF3333)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF3333).withValues(alpha: 0.38),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            'PRO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter to draw subtle dashed route curves in the background
class _SplashContourPainter extends CustomPainter {
  const _SplashContourPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.65)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // First subtle curved track across upper-middle
    final path1 = Path();
    path1.moveTo(0, size.height * 0.28);
    path1.cubicTo(
      size.width * 0.35,
      size.height * 0.26,
      size.width * 0.65,
      size.height * 0.38,
      size.width,
      size.height * 0.33,
    );
    _drawDashedPath(canvas, path1, paint, 6, 6);

    // Second subtle curved track across lower section
    final path2 = Path();
    path2.moveTo(0, size.height * 0.67);
    path2.cubicTo(
      size.width * 0.3,
      size.height * 0.66,
      size.width * 0.7,
      size.height * 0.82,
      size.width,
      size.height * 0.84,
    );
    _drawDashedPath(canvas, path2, paint, 6, 6);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path source,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    for (final metric in source.computeMetrics()) {
      double start = 0;
      while (start < metric.length) {
        final end = (start + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        start += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
