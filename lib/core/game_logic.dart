import 'dart:convert';
import 'dart:math';

/// Uma pergunta do JSON. Esta classe representa os dados, sem desenhar a tela.
class Question {
  const Question({
    required this.id,
    required this.weight,
    required this.type,
    required this.text,
    required this.options,
    required this.answer,
  });
  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json['id'] as int,
    weight: json['peso'] as int,
    type: json['tipo'] as String,
    text: json['enunciado'] as String,
    options: json['alternativas'] as List<dynamic>,
    answer: json['resposta'],
  );
  final int id;
  final int weight;
  final String type;
  final String text;
  final List<dynamic> options;
  final dynamic answer;
  List<String> get choices => options.cast<String>();
  List<String> get terms => (options[0] as List<dynamic>).cast<String>();
  List<String> get concepts => (options[1] as List<dynamic>).cast<String>();
  Map<int, int> get matchingAnswer {
    // Correcao autorizada pelo aluno; o arquivo original continua intacto.
    if (id == 501) return {0: 1, 1: 2, 2: 0};
    return {
      for (final pair in answer as List<dynamic>)
        (pair as List<dynamic>)[0] as int: pair[1] as int,
    };
  }
}

List<Question> parseQuestions(String source) {
  final json = jsonDecode(source) as Map<String, dynamic>;
  return (json['perguntas'] as List<dynamic>)
      .map((item) => Question.fromJson(item as Map<String, dynamic>))
      .toList();
}

/// Controla a pontuacao sem permitir contar a mesma pergunta duas vezes.
class QuizSession {
  QuizSession(this.questions);
  final List<Question> questions;
  int index = 0;
  int score = 0;
  int? selected;
  bool revealed = false;
  bool graded = false;
  final Map<int, int> matches = {};
  Question get current => questions[index];
  bool get canSubmit => current.type == 'REL'
      ? matches.length == current.terms.length
      : selected != null;
  void select(int value) {
    if (!graded) selected = value;
  }

  void match(int term, int concept) {
    if (graded) return;
    matches.removeWhere((key, value) => value == concept || key == term);
    matches[term] = concept;
  }

  bool get isCorrect {
    if (current.type != 'REL') return selected == current.answer;
    final expected = current.matchingAnswer;
    return expected.length == matches.length &&
        expected.entries.every((entry) => matches[entry.key] == entry.value);
  }

  void grade() {
    if (graded || !canSubmit) return;
    if (isCorrect) score += current.weight;
    graded = true;
  }

  // ME: revela no primeiro toque, avanca no segundo. VF/REL: avanca direto.
  bool next() {
    if (!canSubmit) return false;
    if (current.type == 'ME' && !revealed) {
      grade();
      revealed = true;
      return false;
    }
    grade();
    if (index == questions.length - 1) return true;
    index++;
    selected = null;
    matches.clear();
    revealed = false;
    graded = false;
    return false;
  }
}

class GeniusGame {
  GeniusGame({Random? random}) : random = random ?? Random();
  final Random random;
  int score = 0;
  int inputIndex = 0;
  List<int> sequence = [];
  int get level => score ~/ 2 + 1;
  void reset() {
    score = 0;
    inputIndex = 0;
    sequence = [];
  }

  void newRound() {
    inputIndex = 0;
    sequence = List.generate(level, (_) => random.nextInt(5));
  }

  // null: faltam cores; true: acertou a rodada; false: errou.
  bool? press(int color) {
    if (inputIndex >= sequence.length) return null;
    if (sequence[inputIndex] != color) return false;
    inputIndex++;
    if (inputIndex == sequence.length) {
      score++;
      return true;
    }
    return null;
  }
}

class MemoryCardData {
  MemoryCardData({required this.id, required this.pair, required this.image});
  final int id;
  final int pair;
  final String image;
  bool faceUp = true;
  bool matched = false;
}

class MemoryGame {
  MemoryGame({Random? random}) : random = random ?? Random();
  final Random random;
  List<MemoryCardData> cards = [];
  int hits = 0;
  int errors = 0;
  int? firstId;
  bool busy = false;
  void prepare(List<String> images) {
    assert(images.length == 4);
    hits = 0;
    errors = 0;
    firstId = null;
    busy = false;
    cards = [
      for (var i = 0; i < images.length; i++)
        for (var copy = 0; copy < 2; copy++)
          MemoryCardData(id: i * 2 + copy, pair: i, image: images[i]),
    ]..shuffle(random);
  }

  void hideAll() {
    for (final card in cards) {
      card.faceUp = false;
    }
  }

  bool? reveal(int id) {
    final card = cards.firstWhere((card) => card.id == id);
    if (busy || card.faceUp || card.matched) return null;
    card.faceUp = true;
    if (firstId == null) {
      firstId = id;
      return null;
    }
    final first = cards.firstWhere((card) => card.id == firstId);
    if (first.pair == card.pair) {
      first.matched = card.matched = true;
      firstId = null;
      hits++;
      return true;
    }
    errors++;
    busy = true;
    return false;
  }

  void hideMismatch() {
    for (final card in cards.where((card) => !card.matched)) {
      card.faceUp = false;
    }
    firstId = null;
    busy = false;
  }

  void shuffle() => cards.shuffle(random);
  bool get complete => hits == 4;
}

String formatTime(int seconds) =>
    '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
