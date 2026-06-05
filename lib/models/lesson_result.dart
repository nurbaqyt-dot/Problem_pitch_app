import 'lesson.dart';

class LessonResult {
  const LessonResult({
    required this.lesson,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.xpGained,
  });

  final Lesson lesson;
  final int correctAnswers;
  final int totalQuestions;
  final int xpGained;

  double get scoreFraction {
    if (totalQuestions == 0) {
      return 0;
    }
    return correctAnswers / totalQuestions;
  }

  int get scorePercent => (scoreFraction * 100).round();
}
