import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:aprender_a1/core/game_logic.dart';

void main() {
  final questions = parseQuestions(
    File('assets/data/bancoQuestoes.json').readAsStringSync(),
  );
  group('Quiz com JSON original', () {
    test('carrega sete perguntas e os tres tipos', () {
      expect(questions.length, 7);
      expect(questions.map((q) => q.type).toSet(), {'ME', 'VF', 'REL'});
    });
    test('ME revela antes de avancar e nao duplica pontos', () {
      final session = QuizSession(questions)..select(3);
      expect(session.next(), false);
      expect(session.index, 0);
      expect(session.revealed, true);
      expect(session.score, 5);
      session.select(0);
      expect(session.selected, 3);
      expect(session.next(), false);
      expect(session.index, 1);
      expect(session.score, 5);
    });
    test('alternativa nova substitui a anterior', () {
      final session = QuizSession(questions)
        ..select(0)
        ..select(3);
      expect(session.selected, 3);
    });
    test('nao avanca sem responder e nao pontua erro', () {
      final session = QuizSession(questions);
      expect(session.next(), false);
      expect(session.index, 0);
      session.select(0);
      session.next();
      expect(session.score, 0);
    });
    test('501 tem correcao explicita e todos os indices sao validos', () {
      final q = questions.firstWhere((q) => q.id == 501);
      expect(q.matchingAnswer, {0: 1, 1: 2, 2: 0});
      expect(
        q.matchingAnswer.values.every((index) => index < q.concepts.length),
        true,
      );
    });
    test('conceito nao aceita dois termos simultaneamente', () {
      final s = QuizSession([questions.last])
        ..match(0, 0)
        ..match(1, 0);
      expect(s.matches, {1: 0});
      expect(s.canSubmit, false);
    });
    test('todos os acertos somam exatamente os pesos: 39', () {
      final s = QuizSession(questions);
      var done = false;
      while (!done) {
        if (s.current.type == 'REL') {
          s.current.matchingAnswer.forEach(s.match);
        } else {
          s.select(s.current.answer as int);
        }
        done = s.next();
      }
      expect(s.score, 39);
      s.grade();
      expect(s.score, 39);
    });
    test('VF avanca no primeiro toque e conta uma vez', () {
      final s = QuizSession(questions.where((q) => q.type == 'VF').toList())
        ..select(0);
      s.next();
      expect(s.index, 1);
      expect(s.score, 2);
    });
  });
  group('Genius', () {
    test('nivel sobe a cada duas rodadas corretas', () {
      final game = GeniusGame(random: Random(4));
      for (var round = 0; round < 6; round++) {
        game.newRound();
        expect(game.sequence.length, round ~/ 2 + 1);
        for (final color in List<int>.of(game.sequence)) {
          game.press(color);
        }
        expect(game.score, round + 1);
      }
      expect(game.level, 4);
    });
    test('erro nao acrescenta score', () {
      final game = GeniusGame(random: Random(7))..newRound();
      expect(game.press((game.sequence.first + 1) % 5), false);
      expect(game.score, 0);
    });
    test('geracao usa as cinco cores e reset limpa a partida', () {
      final game = GeniusGame(random: Random(9));
      final seen = <int>{};
      for (var i = 0; i < 60; i++) {
        game.newRound();
        seen.addAll(game.sequence);
      }
      expect(seen, {0, 1, 2, 3, 4});
      game.reset();
      expect(game.sequence, isEmpty);
      expect(game.level, 1);
      expect(game.score, 0);
    });
  });
  group('MemoCheck', () {
    MemoryGame setup() =>
        MemoryGame(random: Random(3))..prepare(['a', 'b', 'c', 'd']);
    test('oito cartas representam quatro pares, inicialmente visiveis', () {
      final game = setup();
      expect(game.cards.length, 8);
      expect(game.cards.every((c) => c.faceUp), true);
      for (var i = 0; i < 4; i++) {
        expect(game.cards.where((c) => c.pair == i).length, 2);
      }
    });
    test('mesma carta nao pode ser usada duas vezes', () {
      final game = setup()..hideAll();
      game.reveal(0);
      game.reveal(0);
      expect(game.hits, 0);
      expect(game.errors, 0);
      expect(game.firstId, 0);
    });
    test('par correto permanece aberto e so aumenta acertos', () {
      final game = setup()..hideAll();
      game.reveal(0);
      expect(game.reveal(1), true);
      expect(game.hits, 1);
      expect(game.errors, 0);
      expect(game.cards.where((c) => c.matched).length, 2);
    });
    test('erro bloqueia outros cliques ate esconder novamente', () {
      final game = setup()..hideAll();
      game.reveal(0);
      expect(game.reveal(2), false);
      expect(game.reveal(4), null);
      expect(game.busy, true);
      expect(game.errors, 1);
      expect(game.hits, 0);
      game.hideMismatch();
      expect(game.cards.every((c) => !c.faceUp), true);
      expect(game.busy, false);
    });
    test('embaralhar conserva pares, acertos e selecao', () {
      final game = setup()..hideAll();
      game.reveal(0);
      game.shuffle();
      expect(game.firstId, 0);
      expect(game.reveal(1), true);
      expect(game.hits, 1);
    });
    test('termina ao acertar quatro pares e prepara nova partida limpa', () {
      final game = setup()..hideAll();
      for (var i = 0; i < 8; i += 2) {
        game.reveal(i);
        game.reveal(i + 1);
      }
      expect(game.complete, true);
      game.prepare(['a', 'b', 'c', 'd']);
      expect(game.hits, 0);
      expect(game.errors, 0);
      expect(game.complete, false);
    });
  });
  test('cronometro usa minutos e segundos com dois digitos', () {
    expect(formatTime(0), '00:00');
    expect(formatTime(65), '01:05');
    expect(formatTime(3600), '60:00');
  });
}
