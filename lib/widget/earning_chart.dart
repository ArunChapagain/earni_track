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
    if (activeTab == Tab.revenue) {
      return 'Revenue';
    } else {
      return 'EPS';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
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
                  isactiveTab: isSelected(Tab.eps),
                ),
                TabChanger(
                  tabChanger: () {
                    updateTab(Tab.revenue);
                  },
                  title: 'Revenue',
                  isactiveTab: isSelected(Tab.revenue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '$getSubject Comparison',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildLegendItem('Actual $getSubject', Colors.blue),
              const SizedBox(width: 16),
              _buildLegendItem('Estimated $getSubject', Colors.red),
            ],
          ),
          const SizedBox(height: 10),
          SfCartesianChart(
            margin: const EdgeInsets.all(0),
            key: ValueKey(activeTab),
            tooltipBehavior: _tooltipBehavior,
            zoomPanBehavior: _zoomPanBehavior,
            plotAreaBorderColor: Colors.black,
            plotAreaBorderWidth: 1.1,
            primaryXAxis: DateTimeAxis(
              axisLine: const AxisLine(
                color: Colors.black,
                width: 1,
              ),
              plotOffset: 8,
              dateFormat: DateFormat('MMM yy'),
              labelStyle: const TextStyle(
                color: Color(0xAA000000),
                fontWeight: FontWeight.bold,
              ),
              majorGridLines: const MajorGridLines(width: 0.5),
              intervalType: DateTimeIntervalType.months,
            ),
            primaryYAxis: NumericAxis(
              axisLine: const AxisLine(
                color: Color(0xAA000000),
                width: 1.1,
              ),
              //convert Large number to K, M, B
              numberFormat: activeTab == Tab.revenue
                  ? NumberFormat.compact()
                  : NumberFormat.currency(symbol: '\$', decimalDigits: 1),
              labelStyle: const TextStyle(
                color: Color(0xC5000000),
                fontWeight: FontWeight.bold,
              ),
              majorGridLines: const MajorGridLines(width: 0.5),
              desiredIntervals: 5,
              minimum: _getMinY(),
            ),
            series: [
              // Actual  Line
              LineSeries<EarningsData, DateTime>(
                name: 'Actual $getSubject',
                dataSource: widget.earningsData,
                xValueMapper: (EarningsData data, _) => data.priceDate,
                yValueMapper: (EarningsData data, _) {
                  if (activeTab == Tab.revenue) {
                    return data.actualRevenue;
                  }
                  return data.actualEps;
                },
                width: 2.5,
                color: Colors.blue,
                markerSettings: const MarkerSettings(
                  shape: DataMarkerType.circle,
                  isVisible: true,
                  height: 5,
                  width: 5,
                  borderWidth: 7,
                  borderColor: Colors.blue,
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
              // Estimated  Line
              LineSeries<EarningsData, DateTime>(
                  name: 'Estimated $getSubject',
                  width: 2.5,
                  dataSource: widget.earningsData,
                  xValueMapper: (EarningsData data, _) => data.priceDate,
                  yValueMapper: (EarningsData data, _) {
                    if (activeTab == Tab.revenue) {
                      return data.estimatedRevenue;
                    }
                    return data.estimatedEps;
                  },
                  color: Colors.red,
                  markerSettings: const MarkerSettings(
                    shape: DataMarkerType.circle,
                    isVisible: true,
                    height: 5,
                    width: 5,
                    borderWidth: 7,
                    borderColor: Colors.red,
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
                  }),
            ],
          ),
        ],
      ),
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
        onTap: () {
          widget.tabChanger(); // Update the selected mode
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: (widget.isactiveTab) ? Colors.black : Colors.transparent,
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
                  color: (widget.isactiveTab) ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
