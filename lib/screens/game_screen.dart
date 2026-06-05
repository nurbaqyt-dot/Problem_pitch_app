import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/progress_controller.dart';
import '../widgets/feedback_banner.dart';
import '../widgets/primary_button.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.progressController,
    required this.lessons,
  });

  final ProgressController progressController;
  final List<Lesson> lessons;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _random = Random();

  Timer? _timer;
  List<_GamePair> _pairs = <_GamePair>[];
  List<_GamePair> _rightOptions = <_GamePair>[];
  Set<String> _matchedIds = <String>{};

  String? _selectedLeftId;
  String? _wrongLeftId;
  String? _wrongRightId;

  int _timeLeft = 18;
  int _score = 0;
  int _xpEarned = 0;
  bool _roundOver = false;
  bool _rewardClaimed = false;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
                  colors: [Color(0xFFF97316), Color(0xFFFACC15)],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Speed Match',
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Match the English meaning to the Kazakh phrase before time runs out.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _GamePill(
                        icon: Icons.timer_rounded,
                        label: '${_timeLeft}s',
                      ),
                      const SizedBox(width: 10),
                      _GamePill(
                        icon: Icons.stars_rounded,
                        label: 'Score $_score',
                      ),
                      const SizedBox(width: 10),
                      _GamePill(
                        icon: Icons.bolt_rounded,
                        label: 'XP $_xpEarned',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _roundOver
                            ? 'Round complete. Replay for a fresh set of word pairs.'
                            : 'Tap a meaning on the left, then match it to the correct Kazakh phrase on the right.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: PrimaryButton(
                        label: _roundOver ? 'Replay' : 'Restart',
                        icon: Icons.refresh_rounded,
                        outlined: true,
                        onPressed: _startRound,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_roundOver)
              FeedbackBanner(
                isCorrect: true,
                message:
                    'You matched $_score pairs and earned +$_xpEarned XP this round.',
              ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _WordColumn(
                    title: 'English',
                    items: _pairs,
                    matchedIds: _matchedIds,
                    selectedId: _selectedLeftId,
                    wrongId: _wrongLeftId,
                    labelBuilder: (pair) => pair.translation,
                    onTap: _roundOver
                        ? null
                        : (pair) {
                            setState(() {
                              _selectedLeftId = pair.id;
                            });
                          },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _WordColumn(
                    title: 'Kazakh',
                    items: _rightOptions,
                    matchedIds: _matchedIds,
                    selectedId: null,
                    wrongId: _wrongRightId,
                    labelBuilder: (pair) => pair.phrase,
                    onTap: _roundOver ? null : _handleRightSelection,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startRound() {
    _timer?.cancel();
    final unlockedLessons = widget.lessons
        .where(
          (lesson) => widget.progressController.isLessonUnlocked(
            widget.lessons,
            lesson,
          ),
        )
        .toList();

    final pool = <_GamePair>[
      for (final lesson in unlockedLessons)
        for (final item in lesson.learningCards)
          _GamePair(
            id: '${lesson.id}-${item.phrase}',
            phrase: item.phrase,
            translation: item.translation,
          ),
    ]..shuffle(_random);

    final pairCount = min(6, max(4, pool.length));
    final selectedPairs = pool.take(pairCount).toList();
    final rightOptions = List<_GamePair>.from(selectedPairs)..shuffle(_random);

    setState(() {
      _pairs = selectedPairs;
      _rightOptions = rightOptions;
      _matchedIds = <String>{};
      _selectedLeftId = null;
      _wrongLeftId = null;
      _wrongRightId = null;
      _timeLeft = 18;
      _score = 0;
      _xpEarned = 0;
      _roundOver = false;
      _rewardClaimed = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timeLeft <= 1) {
        timer.cancel();
        _finishRound();
        return;
      }
      setState(() {
        _timeLeft -= 1;
      });
    });
  }

  void _handleRightSelection(_GamePair pair) {
    if (_selectedLeftId == null || _matchedIds.contains(pair.id)) {
      return;
    }

    if (_selectedLeftId == pair.id) {
      setState(() {
        _matchedIds.add(pair.id);
        _selectedLeftId = null;
        _score += 1;
      });

      if (_matchedIds.length == _pairs.length) {
        _finishRound();
      }
      return;
    }

    setState(() {
      _wrongLeftId = _selectedLeftId;
      _wrongRightId = pair.id;
      _selectedLeftId = null;
      _timeLeft = max(0, _timeLeft - 1);
    });

    Future<void>.delayed(const Duration(milliseconds: 380), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _wrongLeftId = null;
        _wrongRightId = null;
      });
    });

    if (_timeLeft == 0) {
      _finishRound();
    }
  }

  Future<void> _finishRound() async {
    if (_roundOver) {
      return;
    }

    _timer?.cancel();
    final xp = (_score * 4) + (_matchedIds.length == _pairs.length ? 8 : 0);

    setState(() {
      _roundOver = true;
      _xpEarned = xp;
    });

    if (!_rewardClaimed && xp > 0) {
      _rewardClaimed = true;
      await widget.progressController.awardBonusXp(xp);
      if (!mounted) {
        return;
      }
      setState(() {});
    }
  }
}

class _WordColumn extends StatelessWidget {
  const _WordColumn({
    required this.title,
    required this.items,
    required this.matchedIds,
    required this.selectedId,
    required this.wrongId,
    required this.labelBuilder,
    required this.onTap,
  });

  final String title;
  final List<_GamePair> items;
  final Set<String> matchedIds;
  final String? selectedId;
  final String? wrongId;
  final String Function(_GamePair pair) labelBuilder;
  final ValueChanged<_GamePair>? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            for (final pair in items) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MatchTile(
                  label: labelBuilder(pair),
                  isMatched: matchedIds.contains(pair.id),
                  isSelected: selectedId == pair.id,
                  isWrong: wrongId == pair.id,
                  onTap: matchedIds.contains(pair.id)
                      ? null
                      : () => onTap?.call(pair),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.label,
    required this.isMatched,
    required this.isSelected,
    required this.isWrong,
    this.onTap,
  });

  final String label;
  final bool isMatched;
  final bool isSelected;
  final bool isWrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color background = Colors.white;
    Color border = const Color(0xFFD8E9DB);

    if (isMatched) {
      background = const Color(0xFFE6F8EC);
      border = const Color(0xFF1F9D53);
    } else if (isWrong) {
      background = const Color(0xFFFFE8E6);
      border = const Color(0xFFE15D4A);
    } else if (isSelected) {
      background = const Color(0xFFFFF1D9);
      border = const Color(0xFFF59E0B);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF17321E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GamePill extends StatelessWidget {
  const _GamePill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
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

class _GamePair {
  const _GamePair({
    required this.id,
    required this.phrase,
    required this.translation,
  });

  final String id;
  final String phrase;
  final String translation;
}
