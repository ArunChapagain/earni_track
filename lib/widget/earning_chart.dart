import 'dart:math';

import 'package:earni_track/models/earnings_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum Tab { eps, revenue }

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
  final Set<int> tappedPoints = {};
  Tab activeTab = Tab.revenue;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(
      activationMode: ActivationMode.longPress,
      enable: true,
      format: '$getSubject: point.y',
      color: Colors.white,
      textStyle: const TextStyle(color: Colors.black),
    );
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
    );
  }

  void updateTab(Tab tab) {
    setState(() {
      activeTab = tab;
    });
  }

  bool isSelected(Tab tab) => tab == activeTab;

  String get getSubject {
    return activeTab == Tab.revenue ? 'Revenue' : 'EPS';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            children: [
              // Tab Selector
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade100,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TabChanger(
                      tabChanger: () => updateTab(Tab.eps),
                      title: 'EPS',
                      isactiveTab: isSelected(Tab.eps),
                    ),
                    TabChanger(
                      tabChanger: () => updateTab(Tab.revenue),
                      title: 'Revenue',
                      isactiveTab: isSelected(Tab.revenue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Chart Title
              Text(
                '$getSubject Comparison',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              // Legend
              Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Actual $getSubject', Colors.blue.shade700),
                  const SizedBox(width: 16),
                  _buildLegendItem('Estimated $getSubject', Colors.red),
                ],
              ),
              const SizedBox(height: 10),

              // Chart
              _getChart(),
            ],
          ),
        ),
        const SizedBox(height: 15),

        // User Guide
        userGuide(),
      ],
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
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _getChart() {
    return SfCartesianChart(
      margin: const EdgeInsets.all(0),
      key: ValueKey(activeTab),
      tooltipBehavior: _tooltipBehavior,
      zoomPanBehavior: _zoomPanBehavior,
      plotAreaBorderColor: Colors.black12,
      plotAreaBorderWidth: 1.1,
      primaryXAxis: DateTimeAxis(
        axisLine: const AxisLine(
          color: Colors.black26,
          width: 1,
        ),
        plotOffset: 8,
        dateFormat: DateFormat('MMM yy'),
        labelStyle: const TextStyle(
          color: Color(0xAA000000),
          fontWeight: FontWeight.bold,
        ),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.black12),
        intervalType: DateTimeIntervalType.months,
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(
          color: Color(0xAA000000),
          width: 1.1,
        ),
        numberFormat: activeTab == Tab.revenue
            ? NumberFormat.compact()
            : NumberFormat.currency(symbol: '\$', decimalDigits: 1),
        labelStyle: const TextStyle(
          color: Color(0xC5000000),
          fontWeight: FontWeight.bold,
        ),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.black12),
        desiredIntervals: 5,
        minimum: _getMinY(),
      ),
      series: [
        // Actual Line
        LineSeries<EarningsData, DateTime>(
          name: 'Actual $getSubject',
          dataSource: widget.earningsData,
          xValueMapper: (EarningsData data, _) => data.priceDate,
          yValueMapper: (EarningsData data, _) {
            return activeTab == Tab.revenue
                ? data.actualRevenue
                : data.actualEps;
          },
          width: 3,
          color: Colors.blue.shade700,
          markerSettings: MarkerSettings(
            shape: DataMarkerType.circle,
            isVisible: true,
            height: 8,
            width: 8,
            borderWidth: 2,
            borderColor: Colors.blue.shade900,
            color: Colors.white,
          ),
          onPointTap: (ChartPointDetails details) {
            if (details.pointIndex != null &&
                !tappedPoints.contains(details.pointIndex)) {
              tappedPoints.add(details.pointIndex!);
              widget.onDataPointSelected(
                  widget.earningsData[details.pointIndex!]);
              Future.delayed(const Duration(milliseconds: 500),
                  () => tappedPoints.remove(details.pointIndex));
            }
          },
        ),
        // Estimated Line
        LineSeries<EarningsData, DateTime>(
          name: 'Estimated $getSubject',
          width: 3,
          dataSource: widget.earningsData,
          xValueMapper: (EarningsData data, _) => data.priceDate,
          yValueMapper: (EarningsData data, _) {
            return activeTab == Tab.revenue
                ? data.estimatedRevenue
                : data.estimatedEps;
          },
          color: Colors.red.shade700,
          markerSettings: MarkerSettings(
            shape: DataMarkerType.circle,
            isVisible: true,
            height: 8,
            width: 8,
            borderWidth: 2,
            borderColor: Colors.red.shade900,
            color: Colors.white,
          ),
          onPointTap: (ChartPointDetails details) {
            if (details.pointIndex != null &&
                !tappedPoints.contains(details.pointIndex)) {
              tappedPoints.add(details.pointIndex!);
              widget.onDataPointSelected(
                  widget.earningsData[details.pointIndex!]);
              Future.delayed(const Duration(milliseconds: 500),
                  () => tappedPoints.remove(details.pointIndex));
            }
          },
        ),
      ],
    );
  }

  double _getMinY() {
    if (activeTab == Tab.revenue) {
      double minActual = widget.earningsData
          .map((e) => e.actualRevenue)
          .reduce(min)
          .toDouble();
      double minEstimated = widget.earningsData
          .map((e) => e.estimatedRevenue)
          .reduce(min)
          .toDouble();
      return (min(minActual, minEstimated) * 1).floorToDouble();
    } else {
      double minActual =
          widget.earningsData.map((e) => e.actualEps).reduce(min);
      double minEstimated =
          widget.earningsData.map((e) => e.estimatedEps).reduce(min);
      return (min(minActual, minEstimated) * 0.8).floorToDouble();
    }
  }

  Widget userGuide() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade800, size: 24),
              const SizedBox(width: 10),
              Text(
                'How to Use the Chart',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '• Pinch to zoom in and out for a closer look at specific data points.\n'
            '• Tap on any data point to view detailed earnings information for that quarter.\n'
            '• Long press on a data point to get additional details.',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class TabChanger extends StatefulWidget {
  final String title;
  final bool isactiveTab;
  final VoidCallback tabChanger;
  const TabChanger({
    super.key,
    required this.tabChanger,
    required this.title,
    required this.isactiveTab,
  });

  @override
  State<TabChanger> createState() => _TabChangerState();
}

class _TabChangerState extends State<TabChanger> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.tabChanger,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color:
                widget.isactiveTab ? Colors.blue.shade900 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: widget.isactiveTab
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: widget.isactiveTab ? Colors.white : Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
