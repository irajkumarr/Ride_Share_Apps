import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../network/network_info.dart';

import 'package:equatable/equatable.dart';

class NetworkCubit extends Cubit<NetworkState> {
  final NetworkInfo _networkInfo;
  StreamSubscription<bool>? _subscription;

  NetworkCubit(this._networkInfo) : super(NetworkInitial()) {
    _init();
  }

  void _init() async {
    // Check initial status
    final isConnected = await _networkInfo.isConnected;
    emit(NetworkStatusChanged(isConnected));

    // Listen to stream for ongoing changes
    _subscription = _networkInfo.connectivityStream.listen((connected) {
      emit(NetworkStatusChanged(connected));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

abstract class NetworkState extends Equatable {
  const NetworkState();

  @override
  List<Object> get props => [];
}

class NetworkInitial extends NetworkState {}

class NetworkStatusChanged extends NetworkState {
  final bool isConnected;

  const NetworkStatusChanged(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}
