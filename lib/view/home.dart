import 'package:earni_track/provider/earning_provider.dart';
import 'package:earni_track/view/earning_transcript.dart';
import 'package:earni_track/widget/earning_chart.dart';
import 'package:earni_track/widget/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    return Consumer<EarningsProvider>(
        builder: (context, earningsProvider, child) {
      return LoadingOverlay(
        isLoading: earningsProvider.isLoading,
        child: Scaffold(
          backgroundColor: const Color(0xFFE9E9E9),
          body: SafeArea(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: [
                const SizedBox(height: 40),
                TextFormField(
                  controller: _controller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a location';
                    }
                    return null; // No error if input is valid
                  },
                  decoration: InputDecoration(
                    hintText:
                        'Enter a company ticker (e.g., MSFT for Microsoft)',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFFDB1E1E),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (_controller.text.isNotEmpty) {
                      earningsProvider.fetchEarningsData(
                          _controller.text.trim().toUpperCase());
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 300,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (earningsProvider.earningsData.isNotEmpty)
                  Transform.scale(
                    scale: 1,
                    child: EarningsChart(
                      earningsData: earningsProvider.earningsData,
                      onDataPointSelected: (earningData) {
                        // Fetch transcript when a data point is clicked
                        earningsProvider
                            .fetchTranscript(
                          earningsProvider.earningsData[0].ticker,
                          DateFormat('yyyy-MM-dd')
                              .format(earningData.priceDate),
                        )
                            .then((_) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EarningTranscriptScreen(
                                earningsData: earningData,
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          )),
        ),
      );
    });
  }
}
