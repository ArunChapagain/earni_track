import 'package:flutter/foundation.dart';
import '../models/earnings_data.dart';
import '../models/transcript_data.dart';
import '../services/api_service.dart';

class EarningsProvider with ChangeNotifier {
  final ApiService _apiService;
  List<EarningsData> _earningsData = [];
  TranscriptData? _transcriptData;
  bool _isLoading = false;
  String? _error;

  EarningsProvider(this._apiService);

  List<EarningsData> get earningsData => _earningsData;
  TranscriptData? get transcriptData => _transcriptData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEarningsData(String ticker) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _earningsData = await _apiService.getEarningsData(ticker);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchTranscript(String ticker, String date) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _transcriptData = await _apiService.getTranscript(ticker, date);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}