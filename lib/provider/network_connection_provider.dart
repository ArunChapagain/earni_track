// network_checker_provider.dart
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class NetworkCheckerProvider extends ChangeNotifier {
  InternetStatus _status = InternetStatus.disconnected;
  bool _hasShownDialog = false;

  NetworkCheckerProvider() {
    _initializeNetworkStatus();
    _listenNetworkChanges();
  }

  InternetStatus get status => _status;
  bool get isConnected => _status == InternetStatus.connected;
  bool get hasShownDialog => _hasShownDialog;

  void setDialogShown(bool value) {
    _hasShownDialog = value;
    notifyListeners();
  }

  Future<void> _initializeNetworkStatus() async {
    bool isConnected = await InternetConnection().hasInternetAccess;
    _status = isConnected ? InternetStatus.connected : InternetStatus.disconnected;
    notifyListeners();
  }

  void _listenNetworkChanges([VoidCallback? function]) {
    InternetConnection().onStatusChange.listen((status) {
      _status = status;
      if ((status == InternetStatus.connected) && (function != null)) {
        function();
      }
      notifyListeners();
    });
  }
}


class NoInternetDialog extends StatelessWidget {
  const NoInternetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.signal_wifi_off, color: Colors.red),
          SizedBox(width: 8),
          Text('No Internet Connection'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Please check your internet connection and try again.'),
          SizedBox(height: 16),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final networkProvider =
                Provider.of<NetworkCheckerProvider>(context, listen: false);
            if (networkProvider.isConnected) {
              Navigator.of(context).pop();
              networkProvider.setDialogShown(false);
            }
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
