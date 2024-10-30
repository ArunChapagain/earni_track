import 'package:dio/dio.dart';
import '../models/earnings_data.dart';
import '../models/transcript_data.dart';

class ApiService {
  final Dio _dio;
  final String _apiKey; // Your API Ninjas API key

  ApiService(this._apiKey) : _dio = Dio() {
    _dio.options.baseUrl = 'https://api.api-ninjas.com/v1/';
    _dio.options.headers = {
      'X-Api-Key': _apiKey,
      'Content-Type': 'application/json',
    };
  }

  Future<List<EarningsData>> getEarningsData(String ticker) async {
    try {
      final response = await _dio.get(
        'earningscalendar',
        queryParameters: {'ticker': ticker},
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => EarningsData.fromJson(item))
            .toList();
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: 'Failed to fetch earnings data',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Error: ${e.toString()}',
      );
    }
  }

  Future<TranscriptData> getTranscript(String ticker, String date) async {
    try {
      final response = await _dio.get(
        'earningscalltranscript',
        queryParameters: {
          'ticker': ticker,
          'date': date,
        },
      );

      if (response.statusCode == 200) {
        return TranscriptData.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: ''),
          error: 'Failed to fetch transcript',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Error: ${e.toString()}',
      );
    }
  }
}