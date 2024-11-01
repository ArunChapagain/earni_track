import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:earni_track/provider/earning_provider.dart';
import 'package:earni_track/view/earning_transcript.dart';
import 'package:earni_track/widget/earning_chart.dart';
import 'package:earni_track/widget/loading_overlay.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: const Color(0xFFF5F7FA),
        systemNavigationBarColor: Colors.black,
      ),
    );

    return Consumer<EarningsProvider>(
      builder: (context, earningsProvider,child) {
        return LoadingOverlay(
          isLoading: earningsProvider.isLoading,
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F7FA),
            body: SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    const SliverAppBar(
                      // elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      expandedHeight: 120,
                      floating: true,
                      pinned: true,
                      backgroundColor: Colors.white,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'EarniTrack',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black26,
                                    offset: Offset(1.0, 1.0),
                                  )
                                ],
                              ),
                            ),
                            Icon(
                              Icons.analytics_outlined,
                            ),
                          ],
                        ),
                        centerTitle: true,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 15,
                                offset: Offset(0, 8),
                              )
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Enter Company Ticker (e.g., MSFT)',
                              prefixIcon: const Icon(
                                Icons.analytics_outlined,
                                color: Colors.blueGrey,
                              ),
                              suffixIcon: Transform.scale(
                                scale: 1.15,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (_controller.text.isNotEmpty) {
                                      earningsProvider.fetchEarningsData(
                                          _controller.text
                                              .trim()
                                              .toUpperCase());
                                      _focusNode.unfocus();
                                    }
                                  },
                                  style: IconButton.styleFrom(
                                    iconSize: 25,
                                    backgroundColor: Colors.blue.shade900,
                                    // shape: const CircleBorder(),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        bottomLeft: Radius.circular(20),
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                earningsProvider.fetchEarningsData(
                                    value.trim().toUpperCase());
                                _focusNode.unfocus();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    
                      if (earningsProvider.earningsData.isEmpty)
                      SliverToBoxAdapter(
                          child: Container(
                        clipBehavior: Clip.antiAlias,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            )
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/noContent.png',
                          fit: BoxFit.cover,
                          height: 500,
                        ),
                      )),
                    if (earningsProvider.earningsData.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: EarningsComparisonChart(
                                earningsData: earningsProvider.earningsData,
                                onDataPointSelected: (earningData) {
                                  earningsProvider
                                      .fetchTranscript(
                                    earningsProvider.earningsData[0].ticker,
                                    DateFormat('yyyy-MM-dd')
                                        .format(earningData.priceDate),
                                  )
                                      .then((_) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EarningTranscriptScreen(
                                          earningsData: earningData,
                                        ),
                                      ),
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
