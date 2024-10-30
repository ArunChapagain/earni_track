import 'package:earni_track/provider/earning_provider.dart';
import 'package:earni_track/services/api_service.dart';
import 'package:earni_track/view/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  String apiKey = 'f6loeisbutFwIp6YK1vHLw==dKjmYXO4wG5nXy9Y';
  runApp(
    MultiProvider(
      providers: [
         ChangeNotifierProvider(
          create: (_) => EarningsProvider(
            ApiService(apiKey),
          ),
        ),
      ],
      child:const  MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
