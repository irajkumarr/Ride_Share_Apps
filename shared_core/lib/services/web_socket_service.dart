import 'dart:async';
import 'dart:convert';
import 'package:shared_core/core/utils/app_logger.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

abstract class WebSocketService {
  void connect({
    required String url,
    String? authToken,
    void Function()? onConnected,
    void Function(dynamic error)? onError,
  });
  void disconnect();
  bool get isConnected;
  void subscribe({
    required String destination,
    required void Function(Map<String, dynamic> data) onMessage,
  });
  void unsubscribe(String destination);
  void send({
    required String destination,
    required Map<String, dynamic> body,
  });
}

class WebSocketServiceImpl implements WebSocketService {
  StompClient? _client;
  final Map<String, StompUnsubscribe> _subscriptions = {};
  final Map<String, void Function(Map<String, dynamic> data)> _pendingSubscriptions = {};
  bool _connected = false;

  @override
  bool get isConnected => _connected;

  @override
  void connect({
    required String url,
    String? authToken,
    void Function()? onConnected,
    void Function(dynamic error)? onError,
  }) {
    if (_client != null && _connected) {
      onConnected?.call();
      return;
    }

    _client = StompClient(
      config: StompConfig(
        url: url,
        onConnect: (frame) {
          _connected = true;
          AppLogger.info('STOMP WebSocket connected successfully to $url');
          onConnected?.call();

          // Resubscribe any pending subscriptions
          final copyPending = Map<String, void Function(Map<String, dynamic>)>.from(_pendingSubscriptions);
          for (final entry in copyPending.entries) {
            _subscribeInternal(entry.key, entry.value);
          }
        },
        onWebSocketError: (dynamic error) {
          AppLogger.error('STOMP WebSocket error: $error');
          onError?.call(error);
        },
        onDisconnect: (frame) {
          _connected = false;
          AppLogger.info('STOMP WebSocket disconnected');
        },
        stompConnectHeaders: {
          if (authToken != null && authToken.isNotEmpty)
            'Authorization': 'Bearer $authToken',
        },
        webSocketConnectHeaders: {
          if (authToken != null && authToken.isNotEmpty)
            'Authorization': 'Bearer $authToken',
        },
      ),
    );

    _client?.activate();
  }

  @override
  void disconnect() {
    _subscriptions.clear();
    _pendingSubscriptions.clear();
    _client?.deactivate();
    _client = null;
    _connected = false;
  }

  void _subscribeInternal(
    String destination,
    void Function(Map<String, dynamic> data) onMessage,
  ) {
    try {
      // Unsubscribe any prior active subscription on this destination to prevent duplicate frames
      _subscriptions[destination]?.call();
      _subscriptions.remove(destination);

      final unsubscribeFn = _client?.subscribe(
        destination: destination,
        callback: (frame) {
          if (frame.body != null) {
            try {
              final json = jsonDecode(frame.body!) as Map<String, dynamic>;
              onMessage(json);
            } catch (e) {
              AppLogger.error('Error decoding WebSocket frame: $e');
            }
          }
        },
      );

      if (unsubscribeFn != null) {
        _subscriptions[destination] = unsubscribeFn;
      }
    } catch (e) {
      AppLogger.error('Failed subscribing to $destination: $e');
    }
  }

  @override
  void subscribe({
    required String destination,
    required void Function(Map<String, dynamic> data) onMessage,
  }) {
    _pendingSubscriptions[destination] = onMessage;
    if (_client != null && _connected) {
      _subscribeInternal(destination, onMessage);
    }
  }

  @override
  void unsubscribe(String destination) {
    _subscriptions[destination]?.call();
    _subscriptions.remove(destination);
    _pendingSubscriptions.remove(destination);
  }

  @override
  void send({
    required String destination,
    required Map<String, dynamic> body,
  }) {
    if (_client != null && _connected) {
      _client?.send(
        destination: destination,
        body: jsonEncode(body),
      );
    }
  }
}

