import 'dart:math';

import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../models/lesson_result.dart';
import '../models/question.dart';
import '../services/progress_controller.dart';
import '../widgets/feedback_banner.dart';
import '../widgets/primary_button.dart';
import 'result_screen.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.lesson,
    required this.progressController,
  });

  final Lesson lesson;
  final ProgressController progressController;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final TextEditingController _textController;

  int _questionIndex = 0;
  int _correctAnswers = 0;
  int _xpGained = 0;

  bool _isChecked = false;
  bool _isCurrentCorrect = false;
  bool _showListeningText = false;

  String _feedbackMessage = '';
  String? _selectedOption;
  List<String> _matchOptions = const [];
  final Map<String, String> _matchSelections = <String, String>{};

  Question get _currentQuestion => widget.lesson.questions[_questionIndex];

  bool get _isLastQuestion =>
      _questionIndex == widget.lesson.questions.length - 1;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController()
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    _resetQuestionState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _resetQuestionState() {
    _textController.clear();
    _selectedOption = null;
    _showListeningText = false;
    _isChecked = false;
    _isCurrentCorrect = false;
    _feedbackMessage = '';
    _matchSelections.clear();

    if (_currentQuestion.type == QuestionType.match) {
      _matchOptions = _currentQuestion.pairs.map((pair) => pair.right).toList()
        ..shuffle(Random(_questionIndex + 7));
    } else {
      _matchOptions = const [];
    }
  }

  bool _hasAnswer(Question question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.listening:
        return _selectedOption != null;
      case QuestionType.translate:
        return _textController.text.trim().isNotEmpty;
      case QuestionType.match:
        return _matchSelections.length == question.pairs.length &&
            !_matchSelections.values.any((value) => value.isEmpty);
    }
  }

  Future<void> _handlePrimaryAction() async {
    if (!_isChecked) {
      _checkAnswer();
      return;
    }

    if (_isLastQuestion) {
      final result = LessonResult(
        lesson: widget.lesson,
        correctAnswers: _correctAnswers,
        totalQuestions: widget.lesson.totalQuestions,
        xpGained: _xpGained,
      );

      await widget.progressController.registerLessonResult(result);
      if (!mounted) {
        return;
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(
            result: result,
            progressController: widget.progressController,
          ),
        ),
      );
      return;
    }

    setState(() {
      _questionIndex += 1;
      _resetQuestionState();
    });
  }

  void _checkAnswer() {
    if (_isChecked) {
      return;
    }

    final question = _currentQuestion;
    final isCorrect = _evaluateAnswer(question);
    final feedbackMessage = isCorrect
        ? 'Correct! ${question.explanation ?? 'Nice work.'}'
        : 'Not quite. ${_correctAnswerCopy(question)}'
              '${question.explanation == null ? '' : ' ${question.explanation}'}';

    setState(() {
      _isChecked = true;
      _isCurrentCorrect = isCorrect;
      _feedbackMessage = feedbackMessage;
      if (isCorrect) {
        _correctAnswers += 1;
        _xpGained += widget.lesson.xpPerCorrect;
      }
    });
  }

  bool _evaluateAnswer(Question question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.listening:
        return _selectedOption == question.correctAnswer;
      case QuestionType.translate:
        return question.matchesTypedAnswer(_textController.text);
      case QuestionType.match:
        return question.pairs.every(
          (pair) => _matchSelections[pair.left] == pair.right,
        );
    }
  }

  String _correctAnswerCopy(Question question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.listening:
      case QuestionType.translate:
        return 'The correct answer is "${question.correctAnswer}".';
      case QuestionType.match:
        final pairs = question.pairs
            .map((pair) => '${pair.left} -> ${pair.right}')
            .join(' | ');
        return 'The correct matches are $pairs.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final progressValue = (_questionIndex + 1) / widget.lesson.totalQuestions;

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
                      duration: const Duration(milliseconds: 350),
                      tween: Tween(begin: 0, end: progressValue),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Test',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.lesson.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_questionIndex + 1}/${widget.lesson.totalQuestions}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  _LessonHeader(lesson: widget.lesson),
                  const SizedBox(height: 20),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Card(
                      key: ValueKey(question.id),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
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
                                _labelForType(question.type),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF17321E),
                                    ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              question.prompt,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            if (question.context != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                question.context!,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                            const SizedBox(height: 22),
                            _QuestionBody(
                              question: question,
                              lessonColor: widget.lesson.color,
                              isChecked: _isChecked,
                              selectedOption: _selectedOption,
                              typedAnswerController: _textController,
                              matchOptions: _matchOptions,
                              matchSelections: _matchSelections,
                              showListeningText: _showListeningText,
                              onOptionSelected: (value) {
                                setState(() {
                                  _selectedOption = value;
                                });
                              },
                              onMatchSelected: (key, value) {
                                setState(() {
                                  _matchSelections[key] = value;
                                });
                              },
                              onPlayAudio: () {
                                setState(() {
                                  _showListeningText = true;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _isChecked
                        ? FeedbackBanner(
                            key: ValueKey('${question.id}-feedback'),
                            isCorrect: _isCurrentCorrect,
                            message: _feedbackMessage,
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5EB),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'XP earned in this lesson: $_xpGained',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: const Color(0xFF17321E),
                                    fontWeight: FontWeight.w700,
                                  ),
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
              child: PrimaryButton(
                label: _isChecked
                    ? (_isLastQuestion ? 'See Results' : 'Continue')
                    : 'Check',
                icon: _isChecked
                    ? Icons.arrow_forward_rounded
                    : Icons.check_rounded,
                onPressed: _isChecked || _hasAnswer(question)
                    ? _handlePrimaryAction
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelForType(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Multiple choice';
      case QuestionType.translate:
        return 'Translate';
      case QuestionType.match:
        return 'Match';
      case QuestionType.listening:
        return 'Listening';
    }
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lesson.color, lesson.color.withValues(alpha: 0.76)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'lesson-badge-${lesson.id}',
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(lesson.icon, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Step 3 of 3',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({
    required this.question,
    required this.lessonColor,
    required this.isChecked,
    required this.selectedOption,
    required this.typedAnswerController,
    required this.matchOptions,
    required this.matchSelections,
    required this.showListeningText,
    required this.onOptionSelected,
    required this.onMatchSelected,
    required this.onPlayAudio,
  });

  final Question question;
  final Color lessonColor;
  final bool isChecked;
  final String? selectedOption;
  final TextEditingController typedAnswerController;
  final List<String> matchOptions;
  final Map<String, String> matchSelections;
  final bool showListeningText;
  final ValueChanged<String> onOptionSelected;
  final void Function(String key, String value) onMatchSelected;
  final VoidCallback onPlayAudio;

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _buildOptionList(context, question.options);
      case QuestionType.translate:
        return _buildTranslateInput(context);
      case QuestionType.match:
        return _buildMatchRows(context);
      case QuestionType.listening:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: isChecked ? null : onPlayAudio,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Play Audio'),
            ),
            if (showListeningText) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lessonColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  question.audioText ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 18),
            ],
            _buildOptionList(context, question.options),
          ],
        );
    }
  }

  Widget _buildTranslateInput(BuildContext context) {
    final borderColor = !isChecked
        ? const Color(0xFFD8E9DB)
        : question.matchesTypedAnswer(typedAnswerController.text)
        ? const Color(0xFF1F9D53)
        : const Color(0xFFE15D4A);

    return TextField(
      controller: typedAnswerController,
      readOnly: isChecked,
      decoration: InputDecoration(
        hintText: 'Type your answer here',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
        suffixIcon: isChecked
            ? Icon(
                question.matchesTypedAnswer(typedAnswerController.text)
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: question.matchesTypedAnswer(typedAnswerController.text)
                    ? const Color(0xFF1F9D53)
                    : const Color(0xFFE15D4A),
              )
            : null,
      ),
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildMatchRows(BuildContext context) {
    return Column(
      children: [
        for (final pair in question.pairs) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _matchRowColor(pair),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _matchBorderColor(pair)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pair.left, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey('${pair.left}-${matchSelections[pair.left]}'),
                  initialValue: matchSelections[pair.left],
                  items: matchOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: isChecked
                      ? null
                      : (value) {
                          if (value != null) {
                            onMatchSelected(pair.left, value);
                          }
                        },
                  decoration: const InputDecoration(
                    hintText: 'Choose the match',
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _matchRowColor(MatchPair pair) {
    if (!isChecked) {
      return const Color(0xFFF9FCF9);
    }
    return matchSelections[pair.left] == pair.right
        ? const Color(0xFFE6F8EC)
        : const Color(0xFFFFE8E6);
  }

  Color _matchBorderColor(MatchPair pair) {
    if (!isChecked) {
      return const Color(0xFFDCEBDD);
    }
    return matchSelections[pair.left] == pair.right
        ? const Color(0xFF1F9D53)
        : const Color(0xFFE15D4A);
  }

  Widget _buildOptionList(BuildContext context, List<String> options) {
    return Column(
      children: options
          .map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OptionTile(
                label: option,
                isChecked: isChecked,
                isSelected: selectedOption == option,
                isCorrect: question.correctAnswer == option,
                onTap: isChecked ? null : () => onOptionSelected(option),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.isChecked,
    required this.isSelected,
    required this.isCorrect,
    this.onTap,
  });

  final String label;
  final bool isChecked;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color background = Colors.white;
    Color border = const Color(0xFFD7E9DA);
    IconData? icon;

    if (isChecked && isCorrect) {
      background = const Color(0xFFE6F8EC);
      border = const Color(0xFF1F9D53);
      icon = Icons.check_circle_rounded;
    } else if (isChecked && isSelected && !isCorrect) {
      background = const Color(0xFFFFE8E6);
      border = const Color(0xFFE15D4A);
      icon = Icons.cancel_rounded;
    } else if (isSelected) {
      background = const Color(0xFFE9F8EE);
      border = const Color(0xFF22C55E);
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF17321E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (icon != null)
                  Icon(
                    icon,
                    color: isCorrect
                        ? const Color(0xFF1F9D53)
                        : const Color(0xFFE15D4A),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
