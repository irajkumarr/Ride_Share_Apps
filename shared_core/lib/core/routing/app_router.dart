
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/config/global/app_global.dart';
import 'package:shared_core/core/routing/app_routes.dart';
import 'package:shared_core/core/storage/local_storage_service.dart';
import 'package:shared_core/core/ui/widgets/custom_button.dart';
import 'package:shared_core/core/ui/widgets/custom_svg_picture.dart';
import 'package:shared_core/core/utils/app_logger.dart';
import 'package:shared_core/gen/assets.gen.dart';

/// Configures and owns the application's [GoRouter] instance.
///
/// The router performs initial redirect logic to decide whether the user
/// should land on the splash/login screen or straight into the app.
class AppRouter {
  AppRouter(this._localStorageService);

  final LocalStorageService _localStorageService;

  late final GoRouter router = GoRouter(
    navigatorKey: AppGlobal.navigatorKey,
    initialLocation: AppRoutes.splash,
    // initialLocation: AppRoutes.home,
    // debugLogDiagnostics: true,
    redirect: _guard,
    routes: _routes,
    errorBuilder: (context, state) => const ErrorPage(),
    observers: [
      // AppRouterObserver(),
    ],
  );

  // ── Auth guard ────────────────────────────────────────────────────────────

  String? _guard(BuildContext context, GoRouterState state) {
    final isLoggedIn = _localStorageService.getBool(LocalStorageKeys.isLoggedIn) ?? false;

    final location = state.matchedLocation;

    if (!isLoggedIn && location == AppRoutes.home) {
      AppLogger.info('GoRouter: unauthenticated → redirect to onboarding');
      return AppRoutes.onboarding;
    }

    if (isLoggedIn && (location == AppRoutes.login || location == AppRoutes.onboarding)) {
      AppLogger.info('GoRouter: authenticated → redirect to home');
      return AppRoutes.home;
    }

    return null;
  }

  // ── Route definitions ─────────────────────────────────────────────────────

  List<RouteBase> get _routes => [
    // GoRoute(
    //   path: AppRoutes.splash,
    //   builder: (context, state) => const SplashScreen(),
    // ),

    // GoRoute(
    //   path: AppRoutes.onboarding,
    //   builder: (context, state) => const OnboardingScreen(),
    // ),
    // GoRoute(
    //   path: AppRoutes.login,
    //   builder: (context, state) => const LoginScreen(),
    // ),
    // GoRoute(
    //   path: AppRoutes.signup,
    //   builder: (context, state) => const SignupScreen(),
    // ),
    // GoRoute(
    //   path: AppRoutes.forgotPassword,
    //   builder: (context, state) => const ForgotPasswordScreen(),
    // ),
    // GoRoute(
    //   path: AppRoutes.verifyOtp,
    //   builder: (context, state) {
    //     final extra = state.extra! as Map<String, dynamic>;
    //     final email = extra['email'] as String;
    //     return VerifyOtpScreen(
    //       email: email,
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: AppRoutes.resetPassword,
    //   builder: (context, state) {
    //     final extra = state.extra! as Map<String, dynamic>;
    //     final email = extra['email'] as String;
    //     final otp = extra['otp'] as String;
    //     return ResetPasswordScreen(email: email, otp: otp);
    //   },
    // ),

    /// ShellRoute for BottomNavigation
    // ShellRoute(
    //   navigatorKey: shellNavigatorKey,
    //   builder: (context, state, child) {
    //     return BottomNavScaffold(child: child);
    //   },
    //   routes: [
    //     GoRoute(
    //       path: AppRoutes.home,
    //       name: 'home',
    //       builder: (context, state) => const HomeScreen(),
    //     ),

    //     GoRoute(
    //       path: AppRoutes.profile,
    //       name: 'profile',
    //       builder: (context, state) => const ProfileScreen(),
    //     ),
    //   ],
    // ),
  ];
}

// ── 404 error page ────────────────────────────────────────────────────────────

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),

        child: SafeArea(
          child: Column(
            children: [
              ///  Illustration (replace with your asset/lottie)
              const Spacer(),

              SizedBox(
                height: 180,
                child: CustomSvgPicture(
                  svgImage: Assets.images.pageNotFound.path,
                ),
              ),

              const SizedBox(height: 24),

              /// 😅 Title
              Text(
                'Whoops!',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              /// 📄 Subtitle
              Text(
                'Page not found',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),

              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error ?? '',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black45,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              ///  CTA Button
              CustomButton(
                text: 'Go Back to Home Page',
                onPressed: () => context.go(AppRoutes.splash),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
