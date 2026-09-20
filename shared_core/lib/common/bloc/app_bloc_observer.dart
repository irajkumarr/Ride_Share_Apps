import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../core/utils/app_logger.dart';

/// Global [BlocObserver] that logs all BLoC/Cubit transitions and errors.
///
/// Register once during app bootstrap:
/// ```dart
/// Bloc.observer = AppBlocObserver();
/// ```
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    AppLogger.debug('BLoC created: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.debug('BLoC event: ${bloc.runtimeType} → $event');
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'BLoC event: ${bloc.runtimeType}',
        category: 'bloc.event',
        data: {'event': event.toString()},
      ),
    );
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.trace(
      'BLoC change: ${bloc.runtimeType}\n'
      '  current : ${change.currentState}\n'
      '  next    : ${change.nextState}',
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    AppLogger.debug(
      'BLoC transition: ${bloc.runtimeType} '
      '[${transition.event}] '
      '${transition.currentState.runtimeType} '
      '→ ${transition.nextState.runtimeType}',
    );
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'BLoC transition: ${bloc.runtimeType}',
        category: 'bloc.transition',
        data: {
          'event': transition.event.toString(),
          'currentState': transition.currentState.toString(),
          'nextState': transition.nextState.toString(),
        },
      ),
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.error(
      'BLoC error in ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'BLoC error in ${bloc.runtimeType}',
        category: 'bloc.error',
        level: SentryLevel.error,
        data: {'error': error.toString()},
      ),
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    AppLogger.debug('BLoC closed: ${bloc.runtimeType}');
  }
}
