import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkService with ChangeNotifier {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;

  NetworkService._internal() {
    _monitorNetworkStatus();
  }

  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  void _monitorNetworkStatus() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      bool newStatus = results.any((result) => result != ConnectivityResult.none);
      if (_isConnected != newStatus) {
        _isConnected = newStatus;
        notifyListeners();
      }
    });
  }
}