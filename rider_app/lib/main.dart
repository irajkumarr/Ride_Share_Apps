import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rider_app/firebase_options.dart';
import 'package:shared_core/shared_core.dart';

import 'app.dart';
import 'src/core/di/injection.dart';

/// Application entry points per flavor.
/// Run via: flutter run --dart-define=FLAVOR=development
///
/// Build APK:
/// flutter build apk --dart-define=FLAVOR=production --release

Future<void> main() async {
  await bootstrap(AppFlavor.dev);
}

/// ------------------------------------------------------------
/// APPLICATION BOOTSTRAP
/// ------------------------------------------------------------

Future<void> bootstrap(AppFlavor flavor) async {
  AppConfig.setFlavor(flavor);
  await runZonedGuarded(
    () async {
      await _bootstrap(flavor);
    },
    (error, stack) {
      log('Uncaught error: error: $error, stackTrace: $stack');
    },
  );
}

/// ------------------------------------------------------------
/// INTERNAL INITIALIZATION
/// ------------------------------------------------------------

Future<void> _bootstrap(AppFlavor flavor) async {
  // 1. Core Bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Logger (fast, sync)
  AppLogger.init(flavor: flavor);
  AppLogger.info('🚀 App starting in ${flavor.name} mode');

  try {
    // 4. Parallelize Critical Initialization
    // These must be ready BEFORE the UI starts.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await Future.wait([
      dotenv.load(fileName: ".env"),
      Hive.initFlutter(),
    ]);

    // 5. Post-Critical Initialization
    await _registerHiveAdapters();

    // 6. Dependency Injection (Must be awaited before runApp)
    await configureDependencies(flavor);
    await configureRiderDependencies();

    // 8. System UI customization
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // 9. Start the UI
    runApp(App(flavor: flavor));

    // 10. Background Initialization (Non-blocking)
    _initBackgroundServices(flavor);
  } catch (e, stack) {
    AppLogger.error('Critical initialization failed: $e', stackTrace: stack);
  }
}

/// ------------------------------------------------------------
/// BACKGROUND SERVICES INITIALIZATION
/// ------------------------------------------------------------

/// Services that can initialize after the UI is visible to improve startup time.
Future<void> _initBackgroundServices(AppFlavor flavor) async {
  try {
    // Setup global Flutter framework error handling & custom fallback widget
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.error(
        'Flutter framework error: ${details.exceptionAsString()}',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    // ErrorWidget.builder = (FlutterErrorDetails details) {
    //   return Material(
    //     color: Colors.transparent,
    //     child: GlobalErrorView(
    //       title: 'Rendering Error',
    //       message: AppConfig.isDev ? details.exceptionAsString() : 'An unexpected display error occurred. Please refresh or restart the application.',
    //       isCompact: false,
    //     ),
    //   );
    // };

    // Bloc observer for development state transitions
    if (AppConfig.isDev) {
      Bloc.observer = AppBlocObserver();
    }

    // Parallel background services
    await Future.wait([sl<PushNotificationService>().init()]);

    AppLogger.info('✅ Background initialization complete');
  } catch (e, stack) {
    AppLogger.error('Background init error: $e', stackTrace: stack);
  }
}

/// ------------------------------------------------------------
/// HIVE ADAPTER REGISTRATION
/// ------------------------------------------------------------

Future<void> _registerHiveAdapters() async {
  // Hive adapters go here
  // Hive.registerAdapter(UserModelAdapter());
}
