import 'package:earni_track/provider/network_connection_provider.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

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
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Dismiss'),
        ),
        TextButton(
          onPressed: () async {
            final networkProvider =
                Provider.of<NetworkCheckerProvider>(context, listen: false);
            if (networkProvider.status == InternetStatus.connected) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  

  void _showNoInternetDialog(BuildContext context) {
    final networkProvider =
        Provider.of<NetworkCheckerProvider>(context, listen: false);
    if (!networkProvider.hasShownDialog) {
      networkProvider.setDialogShown(true);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const NoInternetDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkCheckerProvider>(context);

    return AnimatedBuilder(
      animation: networkProvider,
      builder: (context, _) {
        if (networkProvider.status == InternetStatus.disconnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showNoInternetDialog(context);
          });
        }
        return child;
      },
    );
  }
}