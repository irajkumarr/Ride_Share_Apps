import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/config/global/app_global.dart';
import 'package:shared_core/core/routing/app_route_observer.dart';
import 'package:shared_core/core/routing/app_routes.dart';
import 'package:shared_core/core/storage/local_storage_service.dart';
import 'package:shared_core/core/ui/widgets/custom_button.dart';
import 'package:shared_core/core/ui/widgets/custom_svg_picture.dart';
import 'package:shared_core/gen/assets.gen.dart';

import '../../modules/home/bottom_nav_scaffold.dart';
import '../../modules/home/home_screen.dart';
import '../../modules/home/profile_screen.dart';

/// Configures and owns the application's [GoRouter] instance.
class AppRouter {
  AppRouter(this._localStorageService);

  final LocalStorageService _localStorageService;

  late final GoRouter router = GoRouter(
    navigatorKey: AppGlobal.navigatorKey,
    initialLocation: AppRoutes.home,
    redirect: _guard,
    routes: _routes,
    errorBuilder: (context, state) => const ErrorPage(),
    observers: [AppRouterObserver()],
  );

  // ── Auth guard ────────────────────────────────────────────────────────────

  String? _guard(BuildContext context, GoRouterState state) {
    final _ =
        _localStorageService.getBool(LocalStorageKeys.isLoggedIn) ?? false;
    return null;
  }

  // ── Route definitions ─────────────────────────────────────────────────────

  List<RouteBase> get _routes => [
    /// ShellRoute for BottomNavigation
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return BottomNavScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
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
