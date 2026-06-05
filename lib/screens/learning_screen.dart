import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/progress_controller.dart';
import '../widgets/primary_button.dart';
import 'chat_screen.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({
    super.key,
    required this.lesson,
    required this.progressController,
  });

  final Lesson lesson;
  final ProgressController progressController;

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  int _cardIndex = 0;

  bool get _isLastCard => _cardIndex == widget.lesson.learningCards.length - 1;

  @override
  Widget build(BuildContext context) {
    final card = widget.lesson.learningCards[_cardIndex];
    final progress = (_cardIndex + 1) / widget.lesson.learningCards.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 450),
                      tween: Tween(begin: 0, end: progress),
                      builder: (context, value, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 12,
                            backgroundColor: const Color(0xFFE2EFE4),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.lesson.color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Learn', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  _LessonBanner(lesson: widget.lesson),
                  const SizedBox(height: 18),
                  Text(
                    'Step 1 of 3',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: widget.lesson.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Study the phrase before you practice it in a conversation.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Card(
                      key: ValueKey('${widget.lesson.id}-${card.phrase}'),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: widget.lesson.color.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Phrase ${_cardIndex + 1}/${widget.lesson.learningCards.length}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: const Color(0xFF17321E),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              card.phrase,
                              style: Theme.of(
                                context,
                              ).textTheme.displaySmall?.copyWith(fontSize: 36),
                            ),
                            const SizedBox(height: 18),
                            _InfoRow(label: 'Meaning', value: card.translation),
                            const SizedBox(height: 14),
                            _InfoRow(
                              label: 'Pronunciation',
                              value: card.pronunciation,
                            ),
                            if (card.tip != null) ...[
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7FBF8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  card.tip!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            OutlinedButton.icon(
                              onPressed: () => _playAudioPreview(context, card),
                              icon: const Icon(Icons.volume_up_rounded),
                              label: const Text('Play audio'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: widget.lesson.color.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.lightbulb_rounded,
                              color: widget.lesson.color,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Tap through the cards until the phrase feels familiar, then you will use it in a guided chat.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: 'Back',
                      icon: Icons.arrow_back_rounded,
                      outlined: true,
                      onPressed: _cardIndex == 0
                          ? null
                          : () {
                              setState(() {
                                _cardIndex -= 1;
                              });
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: _isLastCard ? 'Start Practice' : 'Next',
                      icon: _isLastCard
                          ? Icons.forum_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: () {
                        if (_isLastCard) {
                          _openPractice(context);
                          return;
                        }
                        setState(() {
                          _cardIndex += 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playAudioPreview(BuildContext context, LearningCardData card) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Audio preview: ${card.phrase} (${card.pronunciation})'),
      ),
    );
  }

  Future<void> _openPractice(BuildContext context) {
    return Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => DialoguePracticeScreen(
          lesson: widget.lesson,
          progressController: widget.progressController,
          continueToQuiz: true,
        ),
      ),
    );
  }
}

class _LessonBanner extends StatelessWidget {
  const _LessonBanner({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lesson.color, lesson.color.withValues(alpha: 0.72)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(lesson.icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  lesson.subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: const Color(0xFF17321E)),
          ),
        ),
      ],
    );
  }
}
