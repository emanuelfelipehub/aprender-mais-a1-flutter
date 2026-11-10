import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aprender_a1/main.dart';
import 'package:aprender_a1/services/device_bridge.dart';

class FakeDevice implements DeviceBridge {
  final controller = StreamController<Map<String, dynamic>>.broadcast();
  final values = <String, int>{'quiz': 0, 'genius': 0, 'memo': 0};
  Map<String, dynamic> status = {
    'battery': 100,
    'connected': true,
    'powerSave': false,
  };
  @override
  Stream<Map<String, dynamic>> get events => controller.stream;
  @override
  Future<Map<String, dynamic>> snapshot() async => status;
  @override
  Future<bool> play(String asset, {bool effect = false}) async => true;
  @override
  Future<void> stopAudio() async {}
  @override
  Future<void> vibrate() async {}
  @override
  Future<List<String>> pickPhotos() async => [];
  @override
  Future<void> saveScore(String game, int score) async {
    values[game] = score;
  }

  @override
  Future<Map<String, int>> scores() async => Map.of(values);
}

void main() {
  testWidgets('Home abre menu, inicia quiz, revela ME e salva ao encerrar', (
    tester,
  ) async {
    final device = FakeDevice();
    await tester.pumpWidget(AprenderApp(device: device, systemAlerts: false));
    await tester.pumpAndSettle();
    expect(find.text('Bem-vindo ao Aprender+'), findsOneWidget);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Sair'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-quiz')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('answer-3')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('quiz-next')));
    await tester.pumpAndSettle();
    expect(find.text('Resposta correta!'), findsOneWidget);
    expect(find.text('Qual comando insere dados?'), findsOneWidget);
    await tester.tap(find.text('Encerrar'));
    await tester.pumpAndSettle();
    expect(find.text('Pontuação total: 5'), findsOneWidget);
    await tester.tap(find.text('Voltar para Home'));
    await tester.pumpAndSettle();
    expect(device.values['quiz'], 5);
    expect(find.text('Bem-vindo ao Aprender+'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await device.controller.close();
  });

  testWidgets('bateria baixa aparece apenas uma vez e os alertas sao enfileirados', (
    tester,
  ) async {
    final device = FakeDevice()
      ..status = {'battery': 20, 'connected': false, 'powerSave': true};
    await tester.pumpWidget(AprenderApp(device: device));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Sem conexão com internet, seus dados podem não estar completamente salvos.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Seu dispositivo está no modo economia de energia, alguns recursos podem ser limitados.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Atenção. Bateria Baixa.'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    device.controller.add({'type': 'battery', 'level': 19});
    await tester.pumpAndSettle();
    expect(find.text('Atenção. Bateria Baixa.'), findsNothing);
    device.controller.add({'type': 'headset'});
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Fone de ouvido conectado, o volume do dispositivo foi definido como 50%',
      ),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
    await device.controller.close();
  });

  testWidgets('Genius Restart reinicia automaticamente e Stop interrompe', (
    tester,
  ) async {
    final device = FakeDevice();
    await tester.pumpWidget(AprenderApp(device: device, systemAlerts: false));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('open-genius')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-genius')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('genius-start')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Stop'), findsOneWidget);
    await tester.tap(find.text('Restart'));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Stop'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('genius-start')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Score: 0'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await device.controller.close();
  });

  testWidgets('MemoCheck conta tres segundos e Stop mostra resultado e zera', (
    tester,
  ) async {
    final device = FakeDevice();
    await tester.pumpWidget(AprenderApp(device: device, systemAlerts: false));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('open-memo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-memo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('memory-start')));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('STOP'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('memory-start')));
    await tester.pumpAndSettle();
    expect(find.text('Partida encerrada!'), findsOneWidget);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('START'), findsOneWidget);
    expect(find.text('Tempo: 00:00'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await device.controller.close();
  });
}
