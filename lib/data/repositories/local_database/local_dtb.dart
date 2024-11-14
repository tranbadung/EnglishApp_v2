import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_up/data/repositories/firestore/firestore_repository.dart';

class UserActivityManager {
  static const String _daysVisitedKey = 'daysVisited';
  static const String _totalHoursKey = 'totalHours';
  static const String _accessDatesKey = 'accessDates';
  static const String _studyStreakKey = 'studyStreak';
  static const String _lastStudyDateKey = 'lastStudyDate';
  static const String _completedTopicsKey = 'completedTopics';
  static const String _lastActivityUpdateKey = 'lastActivityUpdate';
  static const String _lastLoginKey = 'lastLogin';
  static const String _loginTimeKey = 'loginTime';
  static const String _dailyStudyTimeKey = 'dailyStudyTime';

  final FirestoreRepository _firestoreRepository;

  UserActivityManager(this._firestoreRepository);

  // Ghi lại thời gian đăng nhập
  Future<void> recordLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String weekday = _getWeekday(now.weekday);
    String loginTime = now.toIso8601String();

    await prefs.setString(_lastLoginKey, weekday);
    await prefs.setString(_loginTimeKey, loginTime);
  }

  // Lấy thời gian đăng nhập
  Future<int> getLoginDuration() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginTimeString = prefs.getString(_loginTimeKey);

    if (loginTimeString != null) {
      DateTime loginTime = DateTime.parse(loginTimeString);
      Duration duration = DateTime.now().difference(loginTime);
      return duration.inSeconds;
    }
    return 0;
  }

  // Chuyển đổi số thứ tự ngày trong tuần sang text
  String _getWeekday(int weekdayNumber) {
    const weekdays = [
      'Chủ nhật',
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy'
    ];
    return weekdays[weekdayNumber % 7];
  }

  // Lấy ngày hiện tại dạng T2, T3,...
  static String _getCurrentDay() {
    final DateTime today = DateTime.now();
    final List<String> daysOfWeek = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return daysOfWeek[today.weekday % 7];
  }

  // Ghi lại hoạt động người dùng
  Future<void> recordUserActivity() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastUpdateString = prefs.getString(_lastActivityUpdateKey);
    DateTime now = DateTime.now();

    // Kiểm tra xem đã quá 1 phút kể từ lần cập nhật cuối chưa
    if (lastUpdateString != null) {
      DateTime lastUpdate = DateTime.parse(lastUpdateString);
      if (now.difference(lastUpdate).inMinutes < 1) {
        return;
      }
    }

    // Cập nhật ngày truy cập
    List<String> accessDates = prefs.getStringList(_accessDatesKey) ?? [];
    String today = now.toIso8601String().split('T')[0];

    if (!accessDates.contains(today)) {
      accessDates.add(today);
      await prefs.setStringList(_accessDatesKey, accessDates);

      // Cập nhật study streak
      String? lastStudyDate = prefs.getString(_lastStudyDateKey);
      int currentStreak = prefs.getInt(_studyStreakKey) ?? 0;

      if (lastStudyDate != null) {
        final yesterday = DateTime.now()
            .subtract(Duration(days: 1))
            .toIso8601String()
            .split('T')[0];
        if (lastStudyDate == yesterday) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      } else {
        currentStreak = 1;
      }

      await prefs.setInt(_studyStreakKey, currentStreak);
      await prefs.setString(_lastStudyDateKey, today);
    }

    // Cập nhật thời gian học (tính bằng giây)
    String? studyTimeString = prefs.getString(_dailyStudyTimeKey);
    Map<String, int> dailyStudySeconds = {};

    if (studyTimeString != null) {
      dailyStudySeconds = Map<String, int>.from(json.decode(studyTimeString));
    }

    // Tăng 60 giây (1 phút) cho mỗi lần ghi
    dailyStudySeconds[today] = (dailyStudySeconds[today] ?? 0) + 60;

    // Lưu lại thời gian học và thời gian cập nhật cuối
    await prefs.setString(_dailyStudyTimeKey, json.encode(dailyStudySeconds));
    await prefs.setString(_lastActivityUpdateKey, now.toIso8601String());

    // Cập nhật lên Firestore
    await _firestoreRepository.updateUserActivity();
  }

  // Lấy thông tin hoạt động người dùng
  Future<Map<String, dynamic>> getUserActivity() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accessDates = prefs.getStringList(_accessDatesKey) ?? [];
    int studyStreak = prefs.getInt(_studyStreakKey) ?? 0;
    List<String> completedTopics =
        prefs.getStringList(_completedTopicsKey) ?? [];

    // Lấy thời gian học hôm nay
    String today = DateTime.now().toIso8601String().split('T')[0];
    String? studyTimeString = prefs.getString(_dailyStudyTimeKey);
    Map<String, int> dailyStudySeconds = {};

    if (studyTimeString != null) {
      dailyStudySeconds = Map<String, int>.from(json.decode(studyTimeString));
    }

    int todayStudySeconds = dailyStudySeconds[today] ?? 0;

    // Format thời gian học
    String formattedStudyTime = _formatStudyTime(todayStudySeconds);

    return {
      'daysVisited': accessDates.length,
      'studyStreak': studyStreak,
      'completedTopics': completedTopics,
      'accessDates': accessDates,
      'todayStudySeconds': todayStudySeconds,
      'formattedStudyTime': formattedStudyTime,
    };
  }

  // Format thời gian học thành dạng dễ đọc
  String _formatStudyTime(int seconds) {
    if (seconds < 60) {
      return '$seconds giây';
    } else if (seconds < 3600) {
      int minutes = seconds ~/ 60;
      int remainingSeconds = seconds % 60;
      return '$minutes phút ${remainingSeconds > 0 ? "$remainingSeconds giây" : ""}';
    } else {
      int hours = seconds ~/ 3600;
      int remainingMinutes = (seconds % 3600) ~/ 60;
      int remainingSeconds = seconds % 60;
      return '$hours giờ ${remainingMinutes > 0 ? "$remainingMinutes phút" : ""} ${remainingSeconds > 0 ? "$remainingSeconds giây" : ""}';
    }
  }

  // Đánh dấu hoàn thành một chủ đề
  Future<void> completeTask(String topicName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> completedTopics =
        prefs.getStringList(_completedTopicsKey) ?? [];
    if (!completedTopics.contains(topicName)) {
      completedTopics.add(topicName);
      await prefs.setStringList(_completedTopicsKey, completedTopics);
    }
  }

  // Reset thời gian học hàng ngày
  Future<void> resetDailyStudyTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyStudyTimeKey, json.encode({}));
  }
}
