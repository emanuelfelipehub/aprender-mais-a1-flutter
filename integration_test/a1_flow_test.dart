import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:aprender_a1/main.dart';
import 'package:aprender_a1/core/game_logic.dart';
import 'package:aprender_a1/screens/memory_page.dart';
import 'package:aprender_a1/screens/genius_page.dart';
import 'package:aprender_a1/services/device_bridge.dart';

class RecordingDevice implements DeviceBridge {
  final native = AndroidDeviceBridge();
  final voices = <String>[];
  @override
  Stream<Map<String, dynamic>> get events => native.events;
  @override
  Future<Map<String, dynamic>> snapshot() => native.snapshot();
  @override
  Future<bool> play(String asset, {bool effect = false}) {
    if (!effect) voices.add(asset);
    return native.play(asset, effect: effect);
  }

  @override
  Future<void> stopAudio() => native.stopAudio();
  @override
  Future<void> vibrate() => native.vibrate();
  @override
  Future<List<String>> pickPhotos() => native.pickPhotos();
  @override
  Future<void> saveScore(String game, int score) =>
      native.saveScore(game, score);
  @override
  Future<Map<String, int>> scores() => native.scores();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'A1: canais reais, quiz completo, Genius e MemoCheck no Android',
    (tester) async {
      final device = RecordingDevice();
      final status = await device.snapshot();
      expect(status['battery'], inInclusiveRange(0, 100));
      expect(status['connected'], isA<bool>());
      expect(status['accelerometer'], true);
      for (final game in ['quiz', 'genius', 'memo']) {
        await device.saveScore(game, 0);
      }
      await tester.pumpWidget(AprenderApp(device: device, systemAlerts: false));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('open-quiz')));
      await tester.pumpAndSettle();
      final questions = parseQuestions(
        await rootBundle.loadString('assets/data/bancoQuestoes.json'),
      );
      for (final question in questions) {
        if (question.type == 'REL') {
          await tester.pump(const Duration(seconds: 1));

          for (final entry in question.matchingAnswer.entries) {
            final source = find.text(question.terms[entry.key]);
            final target = find.text(question.concepts[entry.value]);
            final gesture = await tester.startGesture(tester.getCenter(source));
            await gesture.moveTo(
              tester.getCenter(target),
              timeStamp: const Duration(milliseconds: 500),
            );
            await tester.pump(const Duration(milliseconds: 300));
            await gesture.up();
            await tester.pump(const Duration(milliseconds: 150));
          }
        } else {
          await tester.tap(find.byKey(ValueKey('answer-${question.answer}')));
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.tap(find.byKey(const ValueKey('quiz-next')));
        await tester.pump(const Duration(milliseconds: 400));
        if (question.type == 'ME') {
          expect(find.text('Resposta correta!'), findsOneWidget);
          await tester.tap(find.byKey(const ValueKey('quiz-next')));
          await tester.pump(const Duration(milliseconds: 400));
        }
      }
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Pontuação total: 39'), findsOneWidget);
      await tester.tap(find.text('Voltar para Home'));
      await tester.pumpAndSettle();
      expect((await device.scores())['quiz'], 39);

      await tester.ensureVisible(find.byKey(const ValueKey('open-genius')));
      await tester.tap(find.byKey(const ValueKey('open-genius')));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Português').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('genius-start')));
      for (var round = 0; round < 2; round++) {
        for (
          var i = 0;
          i < 100 && find.text('Sua vez!').evaluate().isEmpty;
          i++
        ) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(find.text('Sua vez!'), findsOneWidget);
        final path = device.voices.last;
        final index = audioNames['pt']!.indexWhere(
          (name) => path.endsWith('/$name.mp3'),
        );
        expect(index, greaterThanOrEqualTo(0));
        final board = tester.getRect(
          find.byKey(const ValueKey('genius-board')),
        );
        final theta = -pi / 2 + (index + .5) * 2 * pi / 5;
        await tester.tapAt(
          board.center + Offset(cos(theta), sin(theta)) * board.width * .32,
        );
        await tester.pump(const Duration(milliseconds: 150));
      }
      await tester.tap(find.byKey(const ValueKey('genius-start')));
      await tester.pumpAndSettle();
      expect((await device.scores())['genius'], 2);
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect((await device.scores())['genius'], 2);

      await tester.ensureVisible(find.byKey(const ValueKey('open-memo')));
      await tester.tap(find.byKey(const ValueKey('open-memo')));
      await tester.pumpAndSettle();
      expect(find.byType(FlipCard), findsNWidgets(8));
      await tester.tap(find.byKey(const ValueKey('memory-start')));
      await tester.pump(const Duration(milliseconds: 3200));
      await tester.pump(const Duration(milliseconds: 500));
      // Os IDs pertencem aos pares e continuam estaveis depois de embaralhar.
      await tester.tap(find.byKey(const ValueKey('memory-card-0')));
      await tester.pump(const Duration(milliseconds: 420));
      await tester.tap(find.byKey(const ValueKey('memory-card-2')));
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pump(const Duration(milliseconds: 420));
      expect(find.text('Erros: 01'), findsOneWidget);
      for (var i = 0; i < 8; i += 2) {
        await tester.tap(find.byKey(ValueKey('memory-card-$i')));
        await tester.pump(const Duration(milliseconds: 420));
        await tester.tap(find.byKey(ValueKey('memory-card-${i + 1}')));
        await tester.pump(const Duration(milliseconds: 520));
      }
      await tester.pumpAndSettle();
      expect(find.text('Partida encerrada!'), findsOneWidget);
      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();
      expect(find.text('Acertos: 00'), findsOneWidget);
      expect(find.text('Erros: 00'), findsOneWidget);
      expect((await device.scores())['memo'], 4);
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(find.text('Bem-vindo ao Aprender+'), findsOneWidget);
    },
  );
  testWidgets(
    'Android reproduz as 15 falas em tres idiomas e o efeito de clique',
    (tester) async {
      final device = AndroidDeviceBridge();
      await tester.pumpWidget(AprenderApp(device: device, systemAlerts: false));
      await tester.pumpAndSettle();
      for (final language in audioNames.keys) {
        for (final name in audioNames[language]!) {
          expect(await device.play('assets/audio/$language/$name.mp3'), true);
        }
      }
      expect(
        await device.play('assets/audio/mouse-click-sound.mp3', effect: true),
        true,
      );
      await device.stopAudio();
    },
  );
}
