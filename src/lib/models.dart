class Choice {
  final String id;
  final String text;
  final bool isCorrect;
  const Choice({required this.id, required this.text, required this.isCorrect});
  factory Choice.fromJson(Map<String, dynamic> j) => Choice(
    id: j['id'], text: j['text'], isCorrect: (j['isCorrect'] ?? false) as bool
  );
  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'isCorrect': isCorrect};
}

class Question {
  final String id;
  final String text;
  final List<Choice> choices;
  final String topic;
  final String ref;
  final String? explanation;
  const Question({
    required this.id,
    required this.text,
    required this.choices,
    required this.topic,
    required this.ref,
    this.explanation
  });
  factory Question.fromJson(Map<String, dynamic> j) => Question(
    id: j['id'],
    text: j['text'],
    choices: (j['choices'] as List).map((e) => Choice.fromJson(e)).toList(),
    topic: j['topic'] ?? '',
    ref: j['ref'] ?? '',
    explanation: j['explanation']
  );
}
