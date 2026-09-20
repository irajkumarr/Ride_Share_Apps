import 'dart:developer';
import '../error/exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BaseBloc provides reusable helpers for Bloc event handling.
abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  BaseBloc(State initialState) : super(initialState);

  /// A reusable helper for try/catch Bloc state transitions.
  /// Usage:
  /// await safeStateCall(
  ///   emit: emit,
  ///   call: () => repo.getProfiles(),
  ///   loading: () => ProfilesLoading(),
  ///   success: (response) => ProfilesSuccess(response.data ?? []),
  ///   failure: (msg) => ProfilesFailure(msg),
  ///   label: "GetProfiles",
  /// );
  Future<void> safeStateCall<T>({
    required Emitter<State> emit,
    required Future<T> Function() call,
    required State Function() loading,
    required State Function(T result) success,
    required State Function(String error) failure,
    String? label,
  }) async {
    emit(loading());
    try {
      final res = await call();
      emit(success(res));
    } catch (e, st) {
      final msg = e is AppException ? e.message : e.toString();
      if (label != null) log('$label Exception: $msg | $st');
      emit(failure(msg));
    }
  }
}
