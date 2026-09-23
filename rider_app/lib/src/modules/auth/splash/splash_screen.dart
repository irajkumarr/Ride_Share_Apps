import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

/// Rider splash screen matching the reference design:
/// - Light clean background with delicate grid dot matrix & flowing gradient waves
/// - Glowing rounded white card featuring RideNest heart-bird logo
/// - Bold brand: "Ride" in dark charcoal + "Nest" in vibrant brand red
/// - Subtitle tagline: "Move with confidence"
/// - Pulsing glowing red indicator dot in the center
/// - Bottom capsule security badge: "🛡 Instant Rides Across Nepal • v3.4.2"
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _dotPulseAnimation;

  @override
  void initState() {
    super.initState();

    // Entrance animation
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

    // Pulsing indicator dot animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _dotPulseAnimation = Tween<double>(begin: 0.82, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Authentication verification & screen routing
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
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Delicate Dot Matrix & Fluid Ambient Ribbon Wave
          const Positioned.fill(
            child: CustomPaint(
              painter: _RiderSplashBackgroundPainter(),
            ),
          ),

          // 2. Soft Ambient Radial Glow Behind Card
          Positioned(
            top: MediaQuery.of(context).size.height * 0.22,
            left: 0,
            right: 0,
            height: 320,
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF5252).withValues(alpha: 0.12),
                      const Color(0xFFFF8A80).withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Main Center Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 7),

                // Animated Logo + Typography
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo Card with glowing backdrop
                        _buildLogoCard(),

                        const SizedBox(height: 32),

                        // RideNest Brand: "Ride" (dark) + "Nest" (red)
                        _buildBrandTitle(),

                        const SizedBox(height: 12),

                        // Subtitle: "Move with confidence"
                        const Text(
                          'Move with confidence',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Pulsing glowing red dot indicator
                ScaleTransition(
                  scale: _dotPulseAnimation,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF3B30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF3B30).withValues(alpha: 0.45),
                          blurRadius: 16,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 6),

                // Bottom security badge: "🛡 Instant Rides Across Nepal • v3.4.2"
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFF1F5F9),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 15,
                          color: Color(0xFFFF4D4F),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Instant Rides Across Nepal',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3.5,
                          height: 3.5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // const Text(
                        //   'v3.4.2',
                        //   style: TextStyle(
                        //     fontSize: 12.5,
                        //     fontWeight: FontWeight.w500,
                        //     color: Color(0xFF94A3B8),
                        //   ),
                        // ),
                        AppVersionBuilder(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoCard() {
    return Container(
      width: 148,
      height: 148,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(38),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.95),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3333).withValues(alpha: 0.20),
            blurRadius: 38,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          'assets/icons/ridenest_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/icons/ridenest_logo.png',
            package: 'shared_core',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.location_on_rounded,
              color: Color(0xFFFF3B30),
              size: 56,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandTitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
        children: [
          TextSpan(
            text: 'Ride',
            style: TextStyle(color: Color(0xFF0F172A)),
          ),
          TextSpan(
            text: 'Nest',
            style: TextStyle(color: Color(0xFFFF3B30)),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for dot matrix pattern and soft fluid contour ribbons
class _RiderSplashBackgroundPainter extends CustomPainter {
  const _RiderSplashBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Subtle dotted grid pattern across the canvas
    final dotPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    for (double x = 14; x < size.width; x += spacing) {
      for (double y = 14; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }

    // 2. Upper sweeping soft wave band
    final wave1Paint = Paint()
      ..color = const Color(0xFFFF5252).withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26.0
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    path1.moveTo(-40, size.height * 0.28);
    path1.cubicTo(
      size.width * 0.35,
      size.height * 0.22,
      size.width * 0.70,
      size.height * 0.36,
      size.width + 40,
      size.height * 0.30,
    );
    canvas.drawPath(path1, wave1Paint);

    // 3. Lower sweeping soft wave band
    final wave2Paint = Paint()
      ..color = const Color(0xFFFF5252).withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32.0
      ..strokeCap = StrokeCap.round;

    final path2 = Path();
    path2.moveTo(-40, size.height * 0.70);
    path2.cubicTo(
      size.width * 0.25,
      size.height * 0.64,
      size.width * 0.75,
      size.height * 0.84,
      size.width + 40,
      size.height * 0.78,
    );
    canvas.drawPath(path2, wave2Paint);

    // 4. Subtle dashed navigation track curve
    final dashedPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dashedPath = Path();
    dashedPath.moveTo(-20, size.height * 0.40);
    dashedPath.cubicTo(
      size.width * 0.4,
      size.height * 0.35,
      size.width * 0.6,
      size.height * 0.55,
      size.width + 20,
      size.height * 0.48,
    );

    for (final metric in dashedPath.computeMetrics()) {
      double start = 0;
      while (start < metric.length) {
        final end = (start + 5).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(start, end), dashedPaint);
        start += 5 + 6;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

