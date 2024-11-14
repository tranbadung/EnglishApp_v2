import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SpeakingScoreService {
  static const String _scoreKey = 'speaking_score';
  static const String _feedbackKey = 'speaking_feedback';
  static const String _durationsKey = 'speaking_durations';

  static Future<void> saveTestResults({
    required String feedback,
    required Map<String, Duration> partDurations,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_feedbackKey, feedback);

    final durationsMap = partDurations.map(
      (key, value) => MapEntry(key, value.inSeconds),
    );
    await prefs.setString(_durationsKey, jsonEncode(durationsMap));
  }

  // Get saved speaking test results
  static Future<Map<String, dynamic>> getTestResults() async {
    final prefs = await SharedPreferences.getInstance();

    final feedback = prefs.getString(_feedbackKey) ?? '';
    final durationsString = prefs.getString(_durationsKey) ?? '{}';

    final durationsMap = jsonDecode(durationsString) as Map<String, dynamic>;
    final partDurations = durationsMap.map(
      (key, value) => MapEntry(key, Duration(seconds: value as int)),
    );

    return {
      'feedback': feedback,
      'partDurations': partDurations,
    };
  }

  static Future<void> clearTestResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scoreKey);
    await prefs.remove(_feedbackKey);
    await prefs.remove(_durationsKey);
  }
}
