import 'package:earni_track/provider/network_connection_provider.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

class NoInternetDialog extends StatelessWidget {
  const NoInternetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.signal_wifi_off, color: Colors.blue[900]),
          const SizedBox(width: 8),
          const Text('No Internet Connection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Dismiss',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () async {
            final networkProvider =
                Provider.of<NetworkCheckerProvider>(context, listen: false);
            if (networkProvider.status == InternetStatus.connected) {
              Navigator.of(context).pop();
            }
          },
          child: Text('Retry',
              style: TextStyle(
                  color: Colors.blue[900], fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const NoInternetDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkCheckerProvider>(
      builder: (context, networkProvider, _) {
        if (!networkProvider.isConnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showNoInternetDialog(context);
          });
        }
        return child;
      },
    );
  }
}
