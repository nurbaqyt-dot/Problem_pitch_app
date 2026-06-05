enum QuestionType { multipleChoice, translate, match, listening }

class MatchPair {
  const MatchPair({required this.left, required this.right});

  final String left;
  final String right;
}

class Question {
  const Question({
    required this.id,
    required this.type,
    required this.prompt,
    this.context,
    this.options = const [],
    this.correctAnswer = '',
    this.acceptedAnswers = const [],
    this.pairs = const [],
    this.audioText,
    this.explanation,
  });

  final String id;
  final QuestionType type;
  final String prompt;
  final String? context;
  final List<String> options;
  final String correctAnswer;
  final List<String> acceptedAnswers;
  final List<MatchPair> pairs;
  final String? audioText;
  final String? explanation;

  bool matchesTypedAnswer(String value) {
    final normalizedValue = _normalize(value);
    final accepted = <String>{
      correctAnswer,
      ...acceptedAnswers,
    }.map(_normalize);
    return accepted.contains(normalizedValue);
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
