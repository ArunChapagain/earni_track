import 'package:earni_track/models/earnings_data.dart';
import 'package:earni_track/provider/earning_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EarningTranscriptScreen extends StatefulWidget {
  final EarningsData earningsData;
  const EarningTranscriptScreen({super.key, required this.earningsData});

  @override
  State<EarningTranscriptScreen> createState() =>
      _EarningTranscriptScreenState();
}

class _EarningTranscriptScreenState extends State<EarningTranscriptScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Soft background color
      body: SafeArea(
        child: Consumer<EarningsProvider>(
          builder: (context, earningProvider, child) {
            final data = earningProvider.transcriptData!;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: const Color(0xFFF5F7FA),
                  elevation: 0,
                  leading: IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.black87,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text(
                    'Earnings Transcript',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  centerTitle: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEarningsOverviewCard(widget.earningsData),
                        const SizedBox(height: 16),
                        _buildTranscriptSection(data.transcript),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEarningsOverviewCard(EarningsData earningsData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              icon: Icons.calendar_today_rounded,
              label: 'Date',
              value: DateFormat.yMMMMd().format(
                  DateTime.parse(earningsData.priceDate.toIso8601String())),
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.attach_money_rounded,
              label: 'Ticker',
              value: earningsData.ticker,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.pie_chart_rounded,
              label: 'Quarter',
              value: DateFormat.QQQ().format(
                  DateTime.parse(earningsData.priceDate.toIso8601String())),
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCompactDetailCard(
                    label: 'Actual EPS',
                    value: '\$${earningsData.actualEps.toStringAsFixed(2)}',
                    color: Colors.blue.shade100,
                    textColor: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCompactDetailCard(
                    label: 'Est. EPS',
                    value: '\$${earningsData.estimatedEps.toStringAsFixed(2)}',
                    color: Colors.green.shade100,
                    textColor: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactDetailCard({
    required String label,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptSection(String transcript) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Full Transcript',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            height: 380, // Fixed height for the scrollable area
            child: Scrollbar(
              controller: _scrollController,
              interactive: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  transcript,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //   child: SliderTheme(
          //     data: SliderThemeData(
          //       activeTrackColor: Colors.blue.shade300,
          //       inactiveTrackColor: Colors.blue.shade100,
          //       thumbColor: Colors.blue.shade500,
          //       thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          //       overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          //     ),
          //     child: Slider(
          //       value: _scrollPosition,
          //       onChanged: (value) {
          //         setState(() {
          //           _scrollPosition = value;
          //           _scrollController.animateTo(
          //             value * (_scrollController.position.maxScrollExtent),
          //             duration: const Duration(milliseconds: 200),
          //             curve: Curves.easeInOut,
          //           );
          //         });
          //       },
          //       min: 0.0,
          //       max: 1.0,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
// class EarningTranscriptScreen extends StatelessWidget {
//   final EarningsData earningsData;
//   const EarningTranscriptScreen({super.key, required this.earningsData});

//   String formatDate(String date) {
//     final parsedDate = DateTime.parse(date);
//     return DateFormat('MMM dd, yyyy').format(parsedDate);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       body: SafeArea(
//         child: Consumer<EarningsProvider>(
//           builder: (context, earningProvider, child) {
//             final data = earningProvider.transcriptData!;
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.arrow_back,
//                               color: Colors.black87),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                         const SizedBox(width: 20),
//                         const Text(
//                           'Earnings Transcript',
//                           style: TextStyle(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       margin: const EdgeInsets.symmetric(vertical: 12),
//                       color: Colors.white,
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _buildInfoRow(
//                                 'Date:',
//                                 DateFormat.yMMMMd().format(DateTime.parse(
//                                     earningsData.priceDate.toIso8601String()))),
//                             _buildInfoRow('Ticker:', earningsData.ticker),
//                             _buildInfoRow(
//                                 'Quarter:',
//                                 DateFormat.QQQ().format(DateTime.parse(
//                                     earningsData.priceDate.toIso8601String()))),
//                             _buildInfoRow('Actual EPS:',
//                                 '\$${earningsData.actualEps.toStringAsFixed(2)}'),
//                             _buildInfoRow('Estimated EPS:',
//                                 '\$${earningsData.estimatedEps.toStringAsFixed(2)}'),
//                             _buildInfoRow('Actual Revenue:',
//                                 '\$${NumberFormat.compact().format(earningsData.actualRevenue)}'),
//                             _buildInfoRow('Estimated Revenue:',
//                                 '\$${NumberFormat.compact().format(earningsData.estimatedRevenue)}'),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     const Text(
//                       'Transcript',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Text(
//                         data.transcript,
//                         textAlign: TextAlign.justify,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           height: 1.6,
//                           fontWeight: FontWeight.w400,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black54,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// import 'package:earni_track/models/earnings_data.dart';
// import 'package:earni_track/models/transcript_data.dart';
// import 'package:earni_track/provider/earning_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';

// class EarningTranscriptScreen extends StatelessWidget {
//   final EarningsData earningsData;
//   const EarningTranscriptScreen({super.key, required this.earningsData});

//   String formatDate(String date) {
//     // Parse the date string to DateTime and format it
//     final parsedDate = DateTime.parse(date);
//     return DateFormat('MMM dd, yyyy').format(parsedDate);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Consumer<EarningsProvider>(
//           builder: (context, earningProvider, child) {
//             final data = earningProvider.transcriptData!;
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.arrow_back),
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                         ),
//                         SizedBox(width: 30),
//                         const Text(
//                           'Earnings Transcript',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Card(
//                       elevation: 4,
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Date: ${DateFormat.yMMMMd().format(DateTime.parse(earningsData.priceDate.toIso8601String()))}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             Text(
//                               'Ticker: ${earningsData.ticker}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             Text(
//                               'Quater: ${DateFormat.QQQ().format(DateTime.parse(earningsData.priceDate.toIso8601String()))}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             Text(
//                               'Actual EPS: ${earningsData.actualEps}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             Text(
//                               'Estimated EPS: ${earningsData.estimatedEps}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             Text(
//                               //add comma to the actual revenue
//                               'Actual Revenue: \$${earningsData.actualRevenue.toString()}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             Text(
//                               'Estimated Revenue: \$${earningsData.estimatedRevenue.toString()}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       data.transcript,
//                       textAlign: TextAlign.justify,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         height: 1.5,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
