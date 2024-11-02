import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkCheckerProvider extends ChangeNotifier {
  InternetStatus _status = InternetStatus.connected;
  Timer? _debounceTimer;

  NetworkCheckerProvider(bool hasInternetAccess) {
    hasInternetAccess
        ? _status = InternetStatus.connected
        : _status = InternetStatus.disconnected;

    _listenNetworkChanges();
  }

  InternetStatus get status => _status;
  bool get isConnected => _status == InternetStatus.connected;

   // Listen to network changes with debounce
  void _listenNetworkChanges([VoidCallback? function]) {
    InternetConnection().onStatusChange.listen((status) {
      // Cancel any existing debounce timer
      _debounceTimer?.cancel();

      // Applying debounce to prevent rapid toggling
      _debounceTimer = Timer(const Duration(seconds: 1), () {
        _status = status;
        if ((status == InternetStatus.connected) && (function != null)) {
          function();
        }
        notifyListeners();
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
