import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

/// Splash screen that inspects authentication status and transitions
/// to the appropriate initial screen (Home or Login) with a sleek animated aesthetic.
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
      duration: const Duration(milliseconds: 1200),
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

    // Check auth after brief splash presentation
    Future.delayed(const Duration(milliseconds: 1800), () {
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

    if (mounted) {
      if (hasUserAuth) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.login);
      }
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Subtle ambient neon gradient backdrop
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.primary.withValues(alpha: 0.15),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Modern ride share icon badge
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primary.withValues(alpha: 0.35),
                            blurRadius: 36,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_taxi_rounded,
                          size: 56,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'RIDER',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4.0,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Move with confidence',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: Colors.white70, letterSpacing: 0.8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
