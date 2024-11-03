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

  final FirestoreRepository _firestoreRepository;

  UserActivityManager(this._firestoreRepository);
  static const String _lastLoginKey = 'lastLogin';
  static const String _loginTimeKey = 'loginTime';

  Future<void> recordLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String weekday = _getWeekday(now.weekday);
    String loginTime = now.toIso8601String();

    await prefs.setString(_lastLoginKey, weekday);
    await prefs.setString(_loginTimeKey, loginTime);

    // Lưu thời gian đăng nhập
    await prefs.setString(_loginTimeKey, loginTime);
  }

  Future<int> getLoginDuration() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginTimeString = prefs.getString(_loginTimeKey);

    if (loginTimeString != null) {
      DateTime loginTime = DateTime.parse(loginTimeString);
      Duration duration = DateTime.now().difference(loginTime);
      return duration.inHours; // Trả về tổng số giờ đã đăng nhập
    }
    return 0;
  }

  // Hàm lấy ngày hiện tại
  static String _getCurrentDay() {
    final DateTime today = DateTime.now();
    final List<String> daysOfWeek = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return daysOfWeek[today.weekday % 7];
  }

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

  Future<void> recordUserActivity() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accessDates = prefs.getStringList(_accessDatesKey) ?? [];
    String today = DateTime.now().toIso8601String().split('T')[0];

    if (!accessDates.contains(today)) {
      accessDates.add(today);
      await prefs.setStringList(_accessDatesKey, accessDates);

      // Update study streak
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

    // Cập nhật số giờ học hôm nay
    String? hoursMapString = prefs.getString('dailyStudyHours');
    Map<String, int> dailyStudyHours = {};

    if (hoursMapString != null) {
      dailyStudyHours = Map<String, int>.from(json.decode(hoursMapString));
    }

    // Tăng số giờ học cho ngày hôm nay
    dailyStudyHours[today] = (dailyStudyHours[today] ?? 0) + 1;

    // Lưu lại số giờ học
    await prefs.setString('dailyStudyHours', json.encode(dailyStudyHours));

    await _firestoreRepository.updateUserActivity();
  }

  Future<Map<String, dynamic>> getUserActivity() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accessDates = prefs.getStringList(_accessDatesKey) ?? [];
    int totalHours = prefs.getInt(_totalHoursKey) ?? 0;
    int studyStreak = prefs.getInt(_studyStreakKey) ?? 0;
    List<String> completedTopics =
        prefs.getStringList(_completedTopicsKey) ?? [];

    // Lấy số giờ học hôm nay
    String today = DateTime.now().toIso8601String().split('T')[0];
    String? hoursMapString = prefs.getString('dailyStudyHours');
    Map<String, int> dailyStudyHours = {};

    if (hoursMapString != null) {
      dailyStudyHours = Map<String, int>.from(json.decode(hoursMapString));
    }

    int todayStudyHours = dailyStudyHours[today] ?? 0; 
    return {
      'daysVisited': accessDates.length,
      'totalHours': totalHours,
      'studyStreak': studyStreak,
      'completedTopics': completedTopics,
      'accessDates': accessDates,
      'todayStudyHours': todayStudyHours,  
    };
  }

  Future<void> completeTask(String topicName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> completedTopics =
        prefs.getStringList(_completedTopicsKey) ?? [];
    if (!completedTopics.contains(topicName)) {
      completedTopics.add(topicName);
      await prefs.setStringList(_completedTopicsKey, completedTopics);
    }
  }
}
