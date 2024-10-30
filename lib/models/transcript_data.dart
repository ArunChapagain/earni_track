import 'dart:convert';

class TranscriptData {
  final String transcript;

  TranscriptData({
    required this.transcript,
  });

  factory TranscriptData.fromJson(String str) =>
      TranscriptData.fromMap(json.decode(str));

  factory TranscriptData.fromMap(Map<String, dynamic> json) {
    return TranscriptData(
      transcript: json['transcript'],
    );
  }
}
