import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/progress_controller.dart';
import '../widgets/lesson_card.dart';
import 'learning_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.progressController,
    required this.lessons,
  });

  final ProgressController progressController;
  final List<Lesson> lessons;

  @override
  Widget build(BuildContext context) {
    final overallProgress = progressController.overallCourseProgress(lessons);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F8A5F), Color(0xFF25C685)],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x220F8A5F),
                    blurRadius: 28,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -26,
                    top: -18,
                    child: Container(
                      width: 126,
                      height: 126,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -34,
                    bottom: -38,
                    child: Container(
                      width: 144,
                      height: 144,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QTalk',
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Learn Kazakh with a clear rhythm: study the phrase, practice with a local, then test what stuck.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          _StatPill(
                            label: 'Level ${progressController.level}',
                            icon: Icons.workspace_premium_rounded,
                          ),
                          const SizedBox(width: 10),
                          _StatPill(
                            label: '${progressController.totalXp} XP',
                            icon: Icons.bolt_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _AnimatedLinearBar(
                        value: overallProgress,
                        color: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${(overallProgress * 100).round()}% course complete',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: const [
                    Expanded(
                      child: _FlowStep(
                        icon: Icons.menu_book_rounded,
                        title: 'Learn',
                        subtitle: 'Cards + pronunciation',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _FlowStep(
                        icon: Icons.forum_rounded,
                        title: 'Practice',
                        subtitle: 'Reply in dialogue mode',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _FlowStep(
                        icon: Icons.fact_check_rounded,
                        title: 'Test',
                        subtitle: 'Keep the quiz system',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your lessons',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Finish each lesson path to unlock the next one.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            for (var index = 0; index < lessons.length; index++) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LessonCard(
                  lesson: lessons[index],
                  progress: progressController.progressForLesson(
                    lessons[index].id,
                  ),
                  isUnlocked: progressController.isLessonUnlocked(
                    lessons,
                    lessons[index],
                  ),
                  isCompleted: progressController.isLessonCompleted(
                    lessons[index].id,
                  ),
                  onTap:
                      progressController.isLessonUnlocked(
                        lessons,
                        lessons[index],
                      )
                      ? () => _openLesson(context, lessons[index])
                      : null,
                ),
              ),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5EB),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.flag_rounded,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next level in ${progressController.xpToNextLevel} XP',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: const Color(0xFF17321E)),
                          ),
                          const SizedBox(height: 8),
                          _AnimatedLinearBar(
                            value: progressController.levelProgress,
                            color: const Color(0xFF22C55E),
                            backgroundColor: const Color(0xFFE2EFE4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLesson(BuildContext context, Lesson lesson) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LearningScreen(
          lesson: lesson,
          progressController: progressController,
        ),
      ),
    );
  }
}

class _AnimatedLinearBar extends StatelessWidget {
  const _AnimatedLinearBar({
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  final double value;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: value),
      builder: (context, animatedValue, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: animatedValue,
            minHeight: 12,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      },
    );
  }
}

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF22C55E)),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
