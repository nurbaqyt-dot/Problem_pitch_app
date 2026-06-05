import 'package:flutter/material.dart';

import '../models/lesson_result.dart';
import '../services/progress_controller.dart';
import '../widgets/primary_button.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.result,
    required this.progressController,
  });

  final LessonResult result;
  final ProgressController progressController;

  @override
  Widget build(BuildContext context) {
    final headline = _headlineForScore(result.scoreFraction);
    final subtitle = _subtitleForScore(result.scoreFraction);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1DBA5C), Color(0xFF73DE85)],
                        ),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        children: [
                          Text(
                            headline,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            tween: Tween(begin: 0, end: result.scoreFraction),
                            builder: (context, value, child) {
                              return SizedBox(
                                width: 170,
                                height: 170,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 170,
                                      height: 170,
                                      child: CircularProgressIndicator(
                                        value: value,
                                        strokeWidth: 14,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.24),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${(value * 100).round()}%',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(color: Colors.white),
                                        ),
                                        Text(
                                          'Score',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _ResultStat(
                              label: 'Correct answers',
                              value:
                                  '${result.correctAnswers}/${result.totalQuestions}',
                              icon: Icons.quiz_rounded,
                            ),
                            const SizedBox(height: 14),
                            _ResultStat(
                              label: 'XP gained',
                              value: '${result.xpGained}',
                              icon: Icons.bolt_rounded,
                            ),
                            const SizedBox(height: 14),
                            _ResultStat(
                              label: 'Current level',
                              value: 'Level ${progressController.level}',
                              icon: Icons.workspace_premium_rounded,
                            ),
                            const SizedBox(height: 14),
                            _ResultStat(
                              label: 'Current streak',
                              value: '${progressController.streakDays} days',
                              icon: Icons.local_fire_department_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'You completed the full QTalk loop for ${result.lesson.title}: Learn, Practice, and Test. Your best quiz score is now saved on the course map so you can replay lessons anytime and keep stacking XP.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                label: 'Continue',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _headlineForScore(double score) {
    if (score >= 0.9) {
      return 'Fantastic work';
    }
    if (score >= 0.7) {
      return 'Nice progress';
    }
    return 'Good first run';
  }

  String _subtitleForScore(double score) {
    if (score >= 0.9) {
      return 'You are sounding travel-ready already.';
    }
    if (score >= 0.7) {
      return 'A few more reps and these phrases will stick fast.';
    }
    return 'You finished the lesson, and that momentum matters.';
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE9F8EE),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: const Color(0xFF22C55E)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
