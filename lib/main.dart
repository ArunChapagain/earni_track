import 'package:earni_track/provider/earning_provider.dart';
import 'package:earni_track/provider/network_connection_provider.dart';
import 'package:earni_track/services/api_service.dart';
import 'package:earni_track/view/home.dart';
import 'package:earni_track/widget/no_internet_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  String apiKey = '';
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EarningsProvider(
            ApiService(apiKey),
          ),
        ),
        ChangeNotifierProvider(create: (context) => NetworkCheckerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConnectivityWrapper(child: HomePage()),
    );
  }
}
