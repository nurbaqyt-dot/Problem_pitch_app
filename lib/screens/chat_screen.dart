import 'package:flutter/material.dart';

import '../data/dialogue_data.dart';
import '../models/dialogue.dart';
import '../models/lesson.dart';
import '../services/progress_controller.dart';
import '../widgets/feedback_banner.dart';
import '../widgets/primary_button.dart';
import 'lesson_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.progressController,
    required this.lessons,
  });

  final ProgressController progressController;
  final List<Lesson> lessons;

  @override
  Widget build(BuildContext context) {
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
                  colors: [Color(0xFF134E72), Color(0xFF1C8BC4)],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat With Locals',
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Choose replies instead of typing, learn from mistakes instantly, and build confidence before real conversations.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _ChatPill(
                        icon: Icons.auto_awesome_rounded,
                        label: '${dialogueCatalog.length} practice chats',
                      ),
                      _ChatPill(icon: Icons.bolt_rounded, label: '+18 XP each'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Practice scenarios',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Unlocked lessons can be replayed anytime for extra practice.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            for (final scenario in dialogueCatalog) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ScenarioCard(
                  lesson: _lessonForScenario(scenario),
                  scenario: scenario,
                  isUnlocked: progressController.isLessonUnlocked(
                    lessons,
                    _lessonForScenario(scenario),
                  ),
                  isCompleted: progressController.isLessonCompleted(
                    scenario.lessonId,
                  ),
                  onTap: () => _openScenario(context, scenario),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Lesson _lessonForScenario(DialogueScenario scenario) {
    return lessons.firstWhere((lesson) => lesson.id == scenario.lessonId);
  }

  Future<void> _openScenario(BuildContext context, DialogueScenario scenario) {
    final lesson = _lessonForScenario(scenario);
    if (!progressController.isLessonUnlocked(lessons, lesson)) {
      return Future<void>.value();
    }

    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DialoguePracticeScreen(
          lesson: lesson,
          progressController: progressController,
          continueToQuiz: false,
        ),
      ),
    );
  }
}

class DialoguePracticeScreen extends StatefulWidget {
  const DialoguePracticeScreen({
    super.key,
    required this.lesson,
    required this.progressController,
    required this.continueToQuiz,
  });

  final Lesson lesson;
  final ProgressController progressController;
  final bool continueToQuiz;

  @override
  State<DialoguePracticeScreen> createState() => _DialoguePracticeScreenState();
}

class _DialoguePracticeScreenState extends State<DialoguePracticeScreen> {
  late final DialogueScenario? _scenario;
  late String _currentNodeId;
  final List<_TranscriptEntry> _transcript = <_TranscriptEntry>[];

  DialogueChoice? _selectedChoice;
  int _correctSteps = 0;
  bool _xpAwarded = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _scenario = dialogueForLesson(widget.lesson.id);
    if (_scenario != null) {
      _currentNodeId = _scenario.startNodeId;
      final startNode = _scenario.nodeById(_currentNodeId);
      _transcript.add(
        _TranscriptEntry(
          speaker: startNode.speaker,
          text: startNode.text,
          translation: startNode.translation,
        ),
      );
    } else {
      _currentNodeId = '';
    }
  }

  DialogueNode get _currentNode => _scenario!.nodeById(_currentNodeId);

  bool get _isTerminal =>
      _scenario != null &&
      !_currentNode.hasChoices &&
      _currentNode.nextNodeId == null;

  double get _progressValue {
    if (_scenario == null || _scenario.interactiveStepCount == 0) {
      return 0;
    }
    if (_isTerminal) {
      return 1;
    }
    return _correctSteps / _scenario.interactiveStepCount;
  }

  @override
  Widget build(BuildContext context) {
    if (_scenario == null) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  'No dialogue found for this lesson yet.',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'You can still return home and use the quiz while the practice path is being filled in.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Back',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                      tween: Tween(begin: 0, end: _progressValue),
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
                  Text(
                    widget.continueToQuiz ? 'Practice' : 'Chat',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  _DialogueHeader(
                    lesson: widget.lesson,
                    scenario: _scenario,
                    continueToQuiz: widget.continueToQuiz,
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final item in _transcript) ...[
                            _TranscriptBubble(entry: item),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_currentNode.hasChoices) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Choose your reply',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    for (final choice in _currentNode.choices) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ChoiceCard(
                          choice: choice,
                          selectedChoice: _selectedChoice,
                          onTap: () {
                            setState(() {
                              _selectedChoice = choice;
                            });
                          },
                        ),
                      ),
                    ],
                  ],
                  if (_selectedChoice != null) ...[
                    const SizedBox(height: 8),
                    FeedbackBanner(
                      isCorrect: _selectedChoice!.isCorrect,
                      message: _selectedChoice!.isCorrect
                          ? 'Nice reply. The conversation can continue.'
                          : (_selectedChoice!.feedback ??
                                'Not quite. Choose a stronger reply next.'),
                    ),
                  ] else if (_isTerminal && _xpAwarded) ...[
                    const SizedBox(height: 8),
                    FeedbackBanner(
                      isCorrect: true,
                      message:
                          'Practice complete. You earned +${widget.lesson.practiceXp} XP.',
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: PrimaryButton(
                label: _buttonLabel,
                icon: _buttonIcon,
                onPressed: _buttonEnabled ? _handlePrimaryAction : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _buttonLabel {
    if (_isTerminal) {
      return widget.continueToQuiz ? 'Start Test' : 'Back to Chat';
    }
    if (_currentNode.hasChoices) {
      if (_selectedChoice == null) {
        return 'Choose a reply';
      }
      return _selectedChoice!.isCorrect ? 'Continue' : 'See reply';
    }
    return _currentNode.actionLabel ?? 'Continue';
  }

  IconData get _buttonIcon {
    if (_isTerminal) {
      return widget.continueToQuiz
          ? Icons.fact_check_rounded
          : Icons.arrow_back_rounded;
    }
    if (_currentNode.hasChoices && _selectedChoice != null) {
      return _selectedChoice!.isCorrect
          ? Icons.arrow_forward_rounded
          : Icons.refresh_rounded;
    }
    return Icons.arrow_forward_rounded;
  }

  bool get _buttonEnabled {
    if (_isSaving) {
      return false;
    }
    if (_isTerminal) {
      return true;
    }
    if (_currentNode.hasChoices) {
      return _selectedChoice != null;
    }
    return _currentNode.nextNodeId != null;
  }

  Future<void> _handlePrimaryAction() async {
    if (_isTerminal) {
      if (widget.continueToQuiz) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => LessonScreen(
              lesson: widget.lesson,
              progressController: widget.progressController,
            ),
          ),
        );
        return;
      }
      Navigator.of(context).pop();
      return;
    }

    if (_currentNode.hasChoices) {
      await _applyChoice();
      return;
    }

    _advanceNode(_currentNode.nextNodeId!);
  }

  Future<void> _applyChoice() async {
    final choice = _selectedChoice;
    if (choice == null) {
      return;
    }

    setState(() {
      _transcript.add(
        _TranscriptEntry(
          speaker: DialogueSpeaker.learner,
          text: choice.label,
          translation: choice.translation,
        ),
      );
      _selectedChoice = null;
      if (choice.isCorrect) {
        _correctSteps += 1;
      }
    });

    _advanceNode(choice.nextNodeId);
  }

  void _advanceNode(String nodeId) {
    final nextNode = _scenario!.nodeById(nodeId);
    setState(() {
      _currentNodeId = nodeId;
      _transcript.add(
        _TranscriptEntry(
          speaker: nextNode.speaker,
          text: nextNode.text,
          translation: nextNode.translation,
        ),
      );
    });

    if (_isTerminal) {
      _awardPracticeXp();
    }
  }

  Future<void> _awardPracticeXp() async {
    if (_xpAwarded) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    await widget.progressController.awardBonusXp(widget.lesson.practiceXp);
    if (!mounted) {
      return;
    }
    setState(() {
      _xpAwarded = true;
      _isSaving = false;
    });
  }
}

class _DialogueHeader extends StatelessWidget {
  const _DialogueHeader({
    required this.lesson,
    required this.scenario,
    required this.continueToQuiz,
  });

  final Lesson lesson;
  final DialogueScenario scenario;
  final bool continueToQuiz;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lesson.color, lesson.color.withValues(alpha: 0.72)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            continueToQuiz ? 'Step 2 of 3' : 'Dialogue mode',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            scenario.title,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            scenario.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.lesson,
    required this.scenario,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
  });

  final Lesson lesson;
  final DialogueScenario scenario;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = isUnlocked ? lesson.color : const Color(0xFFB4C3B6);

    return Opacity(
      opacity: isUnlocked ? 1 : 0.72,
      child: Card(
        child: InkWell(
          onTap: isUnlocked ? onTap : null,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    isUnlocked ? Icons.record_voice_over_rounded : Icons.lock,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scenario.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.title,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scenario.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isUnlocked ? 'Open' : 'Locked',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF17321E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCompleted ? 'Lesson done' : '+18 XP',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TranscriptBubble extends StatelessWidget {
  const _TranscriptBubble({required this.entry});

  final _TranscriptEntry entry;

  @override
  Widget build(BuildContext context) {
    final isLearner = entry.speaker == DialogueSpeaker.learner;
    final bubbleColor = isLearner
        ? const Color(0xFFDCF4E6)
        : const Color(0xFFF4F8FB);

    return Align(
      alignment: isLearner ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isLearner
                ? const Color(0xFF22C55E).withValues(alpha: 0.28)
                : const Color(0xFFCCDCE6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLearner ? 'You' : 'Local',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isLearner
                    ? const Color(0xFF1F7A44)
                    : const Color(0xFF355167),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.text,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: const Color(0xFF17321E)),
            ),
            if (entry.translation != null) ...[
              const SizedBox(height: 6),
              Text(
                entry.translation!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.choice,
    required this.selectedChoice,
    required this.onTap,
  });

  final DialogueChoice choice;
  final DialogueChoice? selectedChoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedChoice?.id == choice.id;
    Color background = Colors.white;
    Color border = const Color(0xFFD8E9DB);

    if (isSelected) {
      background = choice.isCorrect
          ? const Color(0xFFE6F8EC)
          : const Color(0xFFFFE8E6);
      border = choice.isCorrect
          ? const Color(0xFF1F9D53)
          : const Color(0xFFE15D4A);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  choice.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF17321E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  choice.translation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatPill extends StatelessWidget {
  const _ChatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

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

class _TranscriptEntry {
  const _TranscriptEntry({
    required this.speaker,
    required this.text,
    this.translation,
  });

  final DialogueSpeaker speaker;
  final String text;
  final String? translation;
}
