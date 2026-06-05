import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson.dart';
import '../models/lesson_result.dart';

class ProgressController extends ChangeNotifier {
  ProgressController._(this._preferences) {
    _loadState();
  }

  static const _onboardingKey = 'onboarding_complete';
  static const _totalXpKey = 'total_xp';
  static const _lessonProgressKey = 'lesson_progress';
  static const _completedLessonsKey = 'completed_lessons';
  static const _streakKey = 'streak_days';
  static const _lastActiveDateKey = 'last_active_date';
  static const _levelThresholds = <int>[0, 100, 300, 600, 1000, 1500, 2100];

  static Future<ProgressController> create() async {
    final preferences = await SharedPreferences.getInstance();
    return ProgressController._(preferences);
  }

  factory ProgressController.fromPreferences(SharedPreferences preferences) {
    return ProgressController._(preferences);
  }

  final SharedPreferences _preferences;

  bool onboardingComplete = false;
  int totalXp = 0;
  int streakDays = 1;
  String? _lastActiveDate;
  Map<String, double> lessonProgress = <String, double>{};
  Set<String> completedLessons = <String>{};

  int get level {
    for (var index = 0; index < _levelThresholds.length - 1; index++) {
      if (totalXp < _levelThresholds[index + 1]) {
        return index + 1;
      }
    }
    final overflowXp = totalXp - _levelThresholds.last;
    return _levelThresholds.length + (overflowXp ~/ 700);
  }

  int get completedLessonsCount => completedLessons.length;

  int get levelFloorXp {
    if (level <= _levelThresholds.length) {
      return _levelThresholds[level - 1];
    }
    return _levelThresholds.last + ((level - _levelThresholds.length) * 700);
  }

  int get nextLevelXp {
    if (level < _levelThresholds.length) {
      return _levelThresholds[level];
    }
    return levelFloorXp + 700;
  }

  int get xpIntoLevel => totalXp - levelFloorXp;

  int get xpNeededForLevel => math.max(1, nextLevelXp - levelFloorXp);

  int get xpToNextLevel => math.max(0, nextLevelXp - totalXp);

  double get levelProgress => xpIntoLevel / xpNeededForLevel;

  double progressForLesson(String lessonId) => lessonProgress[lessonId] ?? 0;

  bool isLessonCompleted(String lessonId) =>
      completedLessons.contains(lessonId);

  bool isLessonUnlocked(List<Lesson> lessons, Lesson lesson) {
    final index = lessons.indexWhere((entry) => entry.id == lesson.id);
    if (index <= 0) {
      return true;
    }
    return completedLessons.contains(lessons[index - 1].id);
  }

  double overallCourseProgress(List<Lesson> lessons) {
    if (lessons.isEmpty) {
      return 0;
    }
    return completedLessons.length / lessons.length;
  }

  Future<void> markOnboardingComplete() async {
    onboardingComplete = true;
    await _preferences.setBool(_onboardingKey, true);
    notifyListeners();
  }

  Future<void> registerLessonResult(LessonResult result) async {
    totalXp += result.xpGained;
    final previousProgress = lessonProgress[result.lesson.id] ?? 0;
    lessonProgress[result.lesson.id] = math.max(
      previousProgress,
      result.scoreFraction,
    );
    completedLessons.add(result.lesson.id);
    _recordActivity();
    await _persistState();
    notifyListeners();
  }

  Future<void> awardBonusXp(int amount) async {
    if (amount <= 0) {
      return;
    }
    totalXp += amount;
    _recordActivity();
    await _persistState();
    notifyListeners();
  }

  void _loadState() {
    onboardingComplete = _preferences.getBool(_onboardingKey) ?? false;
    totalXp = _preferences.getInt(_totalXpKey) ?? 0;
    streakDays = _preferences.getInt(_streakKey) ?? 1;
    _lastActiveDate = _preferences.getString(_lastActiveDateKey);

    final rawProgress = _preferences.getString(_lessonProgressKey);
    if (rawProgress != null && rawProgress.isNotEmpty) {
      final decoded = Map<String, dynamic>.from(
        jsonDecode(rawProgress) as Map<String, dynamic>,
      );
      lessonProgress = decoded.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    }

    completedLessons = (_preferences.getStringList(_completedLessonsKey) ?? [])
        .toSet();
  }

  void _recordActivity() {
    final now = DateTime.now();
    final today = _dateKey(now);

    if (_lastActiveDate == today) {
      return;
    }

    if (_lastActiveDate == null) {
      streakDays = 1;
    } else {
      final last = DateTime.tryParse(_lastActiveDate!);
      if (last == null) {
        streakDays = 1;
      } else {
        final difference = DateTime(
          now.year,
          now.month,
          now.day,
        ).difference(DateTime(last.year, last.month, last.day)).inDays;
        if (difference == 1) {
          streakDays += 1;
        } else if (difference > 1) {
          streakDays = 1;
        }
      }
    }

    _lastActiveDate = today;
  }

  String _dateKey(DateTime date) {
    return DateTime(date.year, date.month, date.day).toIso8601String();
  }

  Future<void> _persistState() async {
    await _preferences.setInt(_totalXpKey, totalXp);
    await _preferences.setInt(_streakKey, streakDays);
    if (_lastActiveDate != null) {
      await _preferences.setString(_lastActiveDateKey, _lastActiveDate!);
    }
    await _preferences.setString(
      _lessonProgressKey,
      jsonEncode(lessonProgress),
    );
    await _preferences.setStringList(
      _completedLessonsKey,
      completedLessons.toList(),
    );
  }
}
