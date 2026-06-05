enum DialogueSpeaker { local, learner }

class DialogueChoice {
  const DialogueChoice({
    required this.id,
    required this.label,
    required this.translation,
    required this.nextNodeId,
    this.isCorrect = false,
    this.feedback,
  });

  final String id;
  final String label;
  final String translation;
  final String nextNodeId;
  final bool isCorrect;
  final String? feedback;
}

class DialogueNode {
  const DialogueNode({
    required this.id,
    required this.speaker,
    required this.text,
    this.translation,
    this.pronunciation,
    this.choices = const [],
    this.nextNodeId,
    this.actionLabel,
  });

  final String id;
  final DialogueSpeaker speaker;
  final String text;
  final String? translation;
  final String? pronunciation;
  final List<DialogueChoice> choices;
  final String? nextNodeId;
  final String? actionLabel;

  bool get hasChoices => choices.isNotEmpty;
}

class DialogueScenario {
  const DialogueScenario({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.nodes,
    this.startNodeId = 'start',
    this.xpReward = 18,
  });

  final String id;
  final String lessonId;
  final String title;
  final String description;
  final List<DialogueNode> nodes;
  final String startNodeId;
  final int xpReward;

  DialogueNode nodeById(String id) {
    return nodes.firstWhere((node) => node.id == id);
  }

  int get interactiveStepCount {
    return nodes.where((node) => node.hasChoices).length;
  }
}
