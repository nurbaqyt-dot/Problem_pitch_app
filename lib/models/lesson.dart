import 'package:flutter/material.dart';

import 'question.dart';

class LearningCardData {
  const LearningCardData({
    required this.phrase,
    required this.translation,
    required this.pronunciation,
    this.tip,
  });

  final String phrase;
  final String translation;
  final String pronunciation;
  final String? tip;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.learningCards,
    required this.questions,
    this.xpPerCorrect = 12,
    this.practiceXp = 18,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<LearningCardData> learningCards;
  final List<Question> questions;
  final int xpPerCorrect;
  final int practiceXp;

  int get totalQuestions => questions.length;
}
