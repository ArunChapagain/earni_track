import 'dart:convert';

class EarningsData {
  final DateTime priceDate;
  final String ticker;
  final double actualEps;
  final double estimatedEps;
  final int actualRevenue;
  final int estimatedRevenue;

  EarningsData({
    required this.priceDate,
    required this.ticker,
    required this.actualEps,
    required this.estimatedEps,
    required this.actualRevenue,
    required this.estimatedRevenue,
  });
  factory EarningsData.fromJson(String str) =>
      EarningsData.fromMap(json.decode(str));

  factory EarningsData.fromMap(Map<String, dynamic> json) {
    return EarningsData(
      priceDate: DateTime.parse(json['pricedate']),
      ticker: json['ticker'],
      actualEps: json['actual_eps']?.toDouble() ?? 0.0,
      estimatedEps: json['estimated_eps']?.toDouble() ?? 0.0,
      actualRevenue: json['actual_revenue'] ?? 0,
      estimatedRevenue: json['estimated_revenue'] ?? 0,
    );
  }
}
