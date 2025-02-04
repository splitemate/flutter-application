import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:splitemate/service/ws/ws_service_contract.dart';

import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:splitemate/service/network_service.dart';
import 'package:splitemate/service/init_auth.dart';
import 'package:splitemate/exceptions/exceptions.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService.getInstance() => _instance;

  WebSocketService._internal();

  late IOWebSocketChannel _channel;
  final StreamController<String> _streamController = StreamController.broadcast();
  bool _isConnected = false;
  bool _isReconnecting = false;
  String? _lastUrl;
  Map<String, String>? _lastHeaders;
  final NetworkService _networkService = NetworkService();
  final InitAuthService _authService = InitAuthService();

  Stream<String> get stream => _streamController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect(String url, Map<String, String> headers) async {
    if (_isConnected) {
      print("WebSocket is already connected.");
      return;
    }

    print("Connecting to WebSocket...");
    _lastUrl = url;
    _lastHeaders = headers;

    if (!_networkService.isConnected) {
      print("No internet connection. Waiting to reconnect...");
      await _waitForInternet();
    }

    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(url), headers: headers);
      _isConnected = true;

      _channel.stream.listen(
            (data) {
          print('Received data: $data');
          _streamController.add(data as String);
        },
        onError: (error) async {
          print('WebSocket Error: $error');
          if (error.toString().contains("403")) {
            await _handleTokenRefreshAndReconnect();
          } else {
            _isConnected = false;
            _attemptReconnect();
          }
        },
        onDone: () {
          print('WebSocket Disconnected');
          _isConnected = false;
          _attemptReconnect();
        },
      );
    } catch (e) {
      print('Failed to connect: $e');
      _isConnected = false;
      _attemptReconnect();
    }
  }

  Future<void> disconnect() async {
    if (!_isConnected) return;
    print("Disconnecting from WebSocket...");
    await _channel.sink.close();
    _isConnected = false;
  }

  Future<void> sendMessage(String message) async {
    if (!_isConnected) {
      print("WebSocket is not connected. Cannot send message.");
      return;
    }
    _channel.sink.add(message);
  }

  void _attemptReconnect() {
    if (_isReconnecting || _lastUrl == null || _lastHeaders == null) return;

    _isReconnecting = true;
    Future.delayed(const Duration(seconds: 3), () async {
      print("Attempting to reconnect...");
      await connect(_lastUrl!, _lastHeaders!);
      _isReconnecting = false;
    });
  }

  Future<void> _handleTokenRefreshAndReconnect() async {
    print("Refreshing access token...");
    String? newToken = await _authService.refreshAccessToken();
    if (newToken != null) {
      print("New access token obtained. Reconnecting WebSocket...");
      _lastHeaders!['Authorization'] = 'Bearer $newToken';
      await connect(_lastUrl!, _lastHeaders!);
    } else {
      print("Failed to refresh token. User might need to re-login.");
    }
  }

  Future<void> _waitForInternet() async {
    Completer<void> completer = Completer<void>();

    void listener() {
      if (_networkService.isConnected) {
        completer.complete();
        _networkService.removeListener(listener);
      }
    }

    _networkService.addListener(listener);
    await completer.future;
  }
}
