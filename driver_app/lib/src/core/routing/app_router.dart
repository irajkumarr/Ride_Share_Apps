import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/config/global/app_global.dart';
import 'package:shared_core/core/routing/app_route_observer.dart';
import 'package:shared_core/core/routing/app_routes.dart';
import 'package:shared_core/core/storage/local_storage_service.dart';
import 'package:shared_core/core/ui/widgets/custom_button.dart';

import '../../modules/auth/login/login_screen.dart';
import '../../modules/auth/register/register_screen.dart';
import '../../modules/auth/splash/splash_screen.dart';
import '../../modules/home/views/home_screen.dart';
import '../../modules/home/views/profile_screen.dart';
import '../../modules/ride_history/views/ride_history_screen.dart';
import '../../modules/vehicle/views/my_vehicles_screen.dart';
import '../../modules/vehicle/views/vehicle_register_screen.dart';

class AppRouter {
  AppRouter(this._localStorageService);

  final LocalStorageService _localStorageService;

  late final GoRouter router = GoRouter(
    navigatorKey: AppGlobal.navigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: _guard,
    routes: _routes,
    errorBuilder: (context, state) => const ErrorPage(),
    observers: [AppRouterObserver()],
  );

  String? _guard(BuildContext context, GoRouterState state) {
    final _ = _localStorageService.getBool(LocalStorageKeys.isLoggedIn);
    return null;
  }

  List<RouteBase> get _routes => [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/my-vehicles',
      name: 'my-vehicles',
      builder: (context, state) => const MyVehiclesScreen(),
    ),
    GoRoute(
      path: '/ride-history',
      name: 'ride-history',
      builder: (context, state) => const RideHistoryScreen(),
    ),
    GoRoute(
      path: '/vehicle-setup',
      name: 'vehicle-setup',
      builder: (context, state) {
        final fromReg = state.uri.queryParameters['fromRegistration'] == 'true' ||
            state.extra == 'fromRegistration';
        return VehicleRegisterScreen(showBackButton: !fromReg);
      },
    ),

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
  ];
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Go to Home',
                onPressed: () => context.go(AppRoutes.splash),
              ),
            ],
          ),
        ),
      ),
    );
  }
}