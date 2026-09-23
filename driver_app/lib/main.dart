import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:driver_app/firebase_options.dart';
import 'package:shared_core/shared_core.dart';

import 'app.dart';
import 'src/core/di/injection.dart';

Future<void> main() async {
  await bootstrap(AppFlavor.dev);
}

Future<void> bootstrap(AppFlavor flavor) async {
  AppConfig.setFlavor(flavor);
  await runZonedGuarded(
    () async {
      await _bootstrap(flavor);
    },
    (error, stack) {
      log('Uncaught error: $error, stackTrace: $stack');
    },
  );
}

Future<void> _bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.init(flavor: flavor);
  AppLogger.info('🚀 Driver App starting in  mode');

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await Future.wait([dotenv.load(fileName: '.env'), Hive.initFlutter()]);

    await configureDependencies(flavor);
    await configureDriverDependencies();

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

    runApp(App(flavor: flavor));

    _initBackgroundServices(flavor);
  } catch (e, stack) {
    AppLogger.error(
      'Driver App critical initialization failed: $e',
      stackTrace: stack,
    );
  }
}

Future<void> _initBackgroundServices(AppFlavor flavor) async {
  try {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger.error(
        'Flutter framework error: ${details.exceptionAsString()}',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    if (AppConfig.isDev) {
      Bloc.observer = AppBlocObserver();
    }

    await Future.wait([sl<PushNotificationService>().init()]);
    AppLogger.info('✅ Driver App background services ready');
  } catch (e, stack) {
    AppLogger.error('Background init error: $e', stackTrace: stack);
  }
}
