import 'dart:math';

import 'package:earni_track/models/earnings_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EarningsComparisonChart extends StatefulWidget {
  final List<EarningsData> earningsData;
  final Function(EarningsData) onDataPointSelected;

  const EarningsComparisonChart({
    super.key,
    required this.earningsData,
    required this.onDataPointSelected,
  });

  @override
  State<EarningsComparisonChart> createState() =>
      _EarningsComparisonChartState();
}

class _EarningsComparisonChartState extends State<EarningsComparisonChart> {
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      format: 'EPS: \$point.y',
      color: Colors.white,
      textStyle: const TextStyle(color: Colors.black),
    );
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enableDoubleTapZooming: true,
      // enableSelectionZooming: true,
      // selectionRectBorderColor: Colors.blue,
      // selectionRectBorderWidth: 1,
      // selectionRectColor: Colors.blue.withOpacity(0.1),
      enablePanning: true,
    );

    // Initialize TrackballBehavior to show a vertical line and details at each point
    _trackballBehavior = TrackballBehavior(
      enable: true,
      tooltipSettings: const InteractiveTooltip(
        enable: true,
        color: Colors.white,
        textStyle: TextStyle(color: Colors.black),
      ),
      activationMode: ActivationMode.singleTap,
      lineColor: const Color(0xBA9D9D9D),
      lineWidth: 1,
      markerSettings: const TrackballMarkerSettings(
        markerVisibility: TrackballVisibilityMode.visible,
        height: 8,
        width: 8,
        borderWidth: 2,
      ),
      builder: (context, details) {
        if (details.pointIndex != null && details.pointIndex! >= 0) {
          widget.onDataPointSelected(widget.earningsData[details.pointIndex!]);
        }
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x539E9E9E),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            'Date: ${DateFormat.yMMM().format(details.point!.x)}\nEPS: \$${details.point!.y}',
            style: const TextStyle(color: Colors.black),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      // padding: const EdgeInsets.all(16),
      child: SfCartesianChart(
        title: const ChartTitle(
          // text: 'EPS Comparison',
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        // legend: const Legend(
        //   isVisible: true,
        //   position: LegendPosition.bottom,
        //   overflowMode: LegendItemOverflowMode.wrap,
        // ),
        tooltipBehavior: _tooltipBehavior,
        zoomPanBehavior: _zoomPanBehavior,
        trackballBehavior: _trackballBehavior,
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat('MMM yy'),
          labelStyle: const TextStyle(
            color: Color(0xC5000000),
            fontWeight: FontWeight.bold,
          ),
          majorGridLines: const MajorGridLines(width: 0.5),
          intervalType: DateTimeIntervalType.months,
          // labelRotation: -45,
        ),
        primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.currency(symbol: '\$', decimalDigits: 2),
          majorGridLines: const MajorGridLines(width: 0.5),
          // title: const AxisTitle(text: 'Earnings Per Share (EPS)'),
        ),
        series: [
          // Actual EPS Line
          LineSeries<EarningsData, DateTime>(
            name: 'Actual EPS',
            dataSource: widget.earningsData,
            xValueMapper: (EarningsData data, _) => data.priceDate,
            yValueMapper: (EarningsData data, _) => data.actualEps,
            width: 2.5,
            color: Colors.blue,
            markerSettings: const MarkerSettings(
              shape: DataMarkerType.circle,
              isVisible: true,
              height: 5,
              width: 5,
              borderWidth: 6,
              borderColor: Colors.blue,
            ),
            onPointTap: (ChartPointDetails details) {
              if (details.pointIndex != null && details.pointIndex! >= 0) {
                widget.onDataPointSelected(
                    widget.earningsData[details.pointIndex!]);
              }
            },
          ),
          // Estimated EPS Line
          LineSeries<EarningsData, DateTime>(
            name: 'Estimated EPS',
            width: 2.5,
            dataSource: widget.earningsData,
            xValueMapper: (EarningsData data, _) => data.priceDate,
            yValueMapper: (EarningsData data, _) => data.estimatedEps,
            color: Colors.red,
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 5,
              width: 5,
              borderWidth: 5,
              borderColor: Colors.red,
            ),
            onPointTap: (ChartPointDetails details) {
              if (details.pointIndex != null && details.pointIndex! >= 0) {
                widget.onDataPointSelected(
                    widget.earningsData[details.pointIndex!]);
              }
            },
          ),
        ],
      ),
    );
  }
}


enum Tab { eps, revenue }

class EarningsChart extends StatefulWidget {
  final List<EarningsData> earningsData;
  final Function(EarningsData earningData) onDataPointSelected;

  const EarningsChart({
    super.key,
    required this.earningsData,
    required this.onDataPointSelected,
  });

  @override
  State<EarningsChart> createState() => _EarningsChartState();
}

class _EarningsChartState extends State<EarningsChart> {
  int? touchedIndex;
  List<EarningsData> get earningsData => widget.earningsData.reversed.toList();
  Tab activeTab = Tab.eps;
  @override
  void initState() {
    super.initState();
  }

  void updateTab(Tab tab) {
    setState(() {
      activeTab = tab;
    });
  }

  bool isSelected(Tab tab) => tab == activeTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TabChanger(
                  tabChanger: () {
                    updateTab(Tab.eps);
                  },
                  title: 'EPS',
                  isEpsTabSelected: isSelected(Tab.eps),
                ),
                TabChanger(
                  tabChanger: () {
                    updateTab(Tab.revenue);
                  },
                  title: 'Revenue',
                  isEpsTabSelected: isSelected(Tab.revenue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildLegendItem('Actual EPS', Colors.blue),
              const SizedBox(width: 16),
              _buildLegendItem('Estimated EPS', Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: LineChart(
              mainData(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              print(value);
              int index = value.toInt();
              if (index >= 0 && index <= earningsData.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MMM yy').format(earningsData[index].priceDate),
                    style: const TextStyle(
                      // color: Color(0xff68737d),
                      color: Color(0xff68737d),

                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                '\$${value.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xff68737d),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
            reservedSize: 42,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 0,
      maxX: (earningsData.length - 1).toDouble(),
      minY: _getMinY(),
      maxY: _getMaxY(),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final index = barSpot.x.toInt();
              final data = earningsData[index];
              final isActual = barSpot.barIndex == 0;

              return LineTooltipItem(
                '${isActual ? 'Actual' : 'Estimated'}: \$${barSpot.y.toStringAsFixed(2)}\n'
                '${DateFormat('MMM dd, yyyy').format(data.priceDate)}',
                const TextStyle(color: Colors.black),
              );
            }).toList();
          },
        ),
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          if (event is FlTapUpEvent && touchResponse?.lineBarSpots != null) {
            final index = touchResponse!.lineBarSpots![0].x.toInt();
            if (index >= 0 && index < earningsData.length) {
              widget.onDataPointSelected(earningsData[index]);
            }
          }
        },
        handleBuiltInTouches: true,
      ),
      lineBarsData: [
        // Actual EPS Line
        LineChartBarData(
          spots: List.generate(earningsData.length, (index) {
            return FlSpot(index.toDouble(), earningsData[index].actualEps);
          }),
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 6,
                color: Colors.blue,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
        // Estimated EPS Line
        LineChartBarData(
          spots: List.generate(earningsData.length, (index) {
            return FlSpot(index.toDouble(), earningsData[index].estimatedEps);
          }),
          isCurved: true,
          color: Colors.red,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 6,
                color: Colors.red,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
      ],
    );
  }

  double _getMinY() {
    double minActual =
        earningsData.map((e) => e.actualEps).reduce((a, b) => a < b ? a : b);
    double minEstimated =
        earningsData.map((e) => e.estimatedEps).reduce((a, b) => a < b ? a : b);
    return (min(minActual, minEstimated) * 0.9);
  }

  double _getMaxY() {
    double maxActual =
        earningsData.map((e) => e.actualEps).reduce((a, b) => a > b ? a : b);
    double maxEstimated =
        earningsData.map((e) => e.estimatedEps).reduce((a, b) => a > b ? a : b);
    return (max(maxActual, maxEstimated) * 1.1);
  }
}

class TabChanger extends StatefulWidget {
  final String title;
  final bool isEpsTabSelected;
  final VoidCallback tabChanger;
  const TabChanger(
      {super.key,
      required this.tabChanger,
      required this.title,
      required this.isEpsTabSelected});

  @override
  State<TabChanger> createState() => _TabChangerState();
}

class _TabChangerState extends State<TabChanger> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.tabChanger(); // Update the selected mode
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color:
                (widget.isEpsTabSelected) ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color:
                      (widget.isEpsTabSelected) ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
