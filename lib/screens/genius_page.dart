import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/game_logic.dart';
import '../services/device_bridge.dart';
import '../theme.dart';

const geniusColors = [
  Color(0xFFFFD600),
  Color(0xFF1565C0),
  Color(0xFFC62828),
  Color(0xFFEF6C00),
  Color(0xFF2E7D32),
];
const colorLabels = ['Amarelo', 'Azul', 'Vermelho', 'Laranja', 'Verde'];
const audioNames = {
  'pt': ['amarelo', 'azul', 'vermelho', 'laranja', 'verde'],
  'en': ['yellow', 'blue', 'red', 'orange', 'green'],
  'es': ['amarillo', 'azul', 'rojo', 'naranja', 'verde'],
};

class GeniusPage extends StatefulWidget {
  const GeniusPage({super.key, required this.device});
  final DeviceBridge device;
  @override
  State<GeniusPage> createState() => _GeniusPageState();
}

class _GeniusPageState extends State<GeniusPage> {
  final _game = GeniusGame();
  final _watch = Stopwatch();
  Timer? _timer;
  Timer? _flash;
  String _language = 'pt';
  bool _running = false;
  bool _speaking = false;
  bool _finishing = false;
  int? _lit;
  int _epoch = 0;

  @override
  void initState() {
    super.initState();
    final language =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    _language = audioNames.containsKey(language) ? language : 'pt';
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  Future<void> _start() async {
    if (_running || _finishing) return;
    final token = ++_epoch;
    _game.reset();
    _watch
      ..reset()
      ..start();
    setState(() {
      _running = true;
      _speaking = true;
      _lit = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    await _speakRound(token);
  }

  Future<void> _speakRound(int token) async {
    if (!mounted || token != _epoch) return;
    _game.newRound();
    setState(() => _speaking = true);
    try {
      for (final color in _game.sequence) {
        if (!mounted || token != _epoch) return;
        final played = await widget.device.play(
          'assets/audio/$_language/${audioNames[_language]![color]}.mp3',
        );
        if (!mounted || token != _epoch) return;
        if (!played) {
          throw StateError('Não foi possível reproduzir a fala das cores.');
        }
        await Future<void>.delayed(const Duration(milliseconds: 220));
      }
      if (mounted && token == _epoch) setState(() => _speaking = false);
    } catch (error) {
      if (!mounted || token != _epoch) return;
      await _stop();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Falha de áudio: $error')));
      }
    }
  }

  Future<void> _press(int color) async {
    if (!_running || _speaking || _finishing) return;
    final token = _epoch;
    setState(() => _lit = color);
    _flash?.cancel();
    _flash = Timer(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _lit = null);
    });
    // O clique pode tocar junto com a animacao, sem bloquear o proximo toque.
    unawaited(
      widget.device.play('assets/audio/mouse-click-sound.mp3', effect: true),
    );
    final result = _game.press(color);
    if (result == false) {
      await _stop(showResult: true);
      return;
    }
    if (result == true) {
      setState(() => _speaking = true);
      await Future<void>.delayed(const Duration(milliseconds: 550));
      if (mounted && token == _epoch) await _speakRound(token);
    }
  }

  Future<void> _stop({bool showResult = false}) async {
    if (_finishing) return;
    _finishing = true;
    ++_epoch;
    _watch.stop();
    _timer?.cancel();
    _flash?.cancel();
    final hadGame = _running;
    final score = _game.score;
    final time = formatTime(_watch.elapsed.inSeconds);
    setState(() {
      _running = false;
      _speaking = false;
      _lit = null;
    });
    await widget.device.stopAudio();
    if (hadGame) await widget.device.saveScore('genius', score);
    _game.reset();
    _watch.reset();
    if (!mounted) return;
    setState(() {});
    if (showResult) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fim de jogo!'),
          content: Text('Score final: $score\nTempo: $time'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }
    _finishing = false;
  }

  Future<void> _restart() async {
    await _stop();
    if (mounted) await _start();
  }

  Future<void> _back() async {
    await _stop();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    ++_epoch;
    _timer?.cancel();
    _flash?.cancel();
    _watch.stop();
    unawaited(widget.device.stopAudio());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _back();
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Genius Play'),
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: _back,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _language,
                decoration: const InputDecoration(
                  labelText: 'Linguagem',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pt', child: Text('Português')),
                  DropdownMenuItem(value: 'en', child: Text('Inglês')),
                  DropdownMenuItem(value: 'es', child: Text('Espanhol')),
                ],
                onChanged: _running
                    ? null
                    : (value) {
                        if (value != null) setState(() => _language = value);
                      },
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  StatChip('Nivel', _game.level.toString()),
                  StatChip('Cronômetro', formatTime(_watch.elapsed.inSeconds)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _running
                    ? (_speaking ? 'Ouça a sequência…' : 'Sua vez!')
                    : 'Toque em Start para jogar.',
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = min(
                        360.0,
                        min(constraints.maxWidth, constraints.maxHeight),
                      );
                      return SizedBox(
                        key: const ValueKey('genius-board'),
                        width: size,
                        height: size,
                        child: Stack(
                          children: [
                            for (var i = 0; i < 5; i++)
                              Positioned.fill(
                                child: ClipPath(
                                  clipper: PentagonSegment(i),
                                  child: Semantics(
                                    label: colorLabels[i],
                                    button: true,
                                    enabled: _running && !_speaking,
                                    child: GestureDetector(
                                      onTap: _running && !_speaking
                                          ? () => _press(i)
                                          : null,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 130,
                                        ),
                                        color: _lit == i
                                            ? Colors.white
                                            : geniusColors[i],
                                        child: Align(
                                          alignment: Alignment(
                                            cos(
                                                  -pi / 2 +
                                                      (i + .5) * 2 * pi / 5,
                                                ) *
                                                .68,
                                            sin(
                                                  -pi / 2 +
                                                      (i + .5) * 2 * pi / 5,
                                                ) *
                                                .68,
                                          ),
                                          child: Icon(
                                            Icons.circle,
                                            size: 16,
                                            color: i == 0 ? ink : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Center(
                              child: SizedBox(
                                width: size * .29,
                                height: size * .29,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: const CircleBorder(),
                                  ),
                                  key: const ValueKey('genius-start'),
                                  onPressed: _finishing
                                      ? null
                                      : () => _running ? _stop() : _start(),
                                  child: Text(_running ? 'Stop' : 'Start'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatChip('Score', _game.score.toString()),
                  OutlinedButton(
                    onPressed: _finishing ? null : _restart,
                    child: const Text('Restart'),
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

/// Cinco trapezios formam o anel pentagonal, deixando o botao no centro livre.
class PentagonSegment extends CustomClipper<Path> {
  PentagonSegment(this.index);
  final int index;
  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .48;
    final start = -pi / 2 + index * 2 * pi / 5;
    final end = start + 2 * pi / 5;
    Offset point(double angle, double scale) =>
        center + Offset(cos(angle), sin(angle)) * radius * scale;
    final points = [
      point(start, 1),
      point(end, 1),
      point(end, .36),
      point(start, .36),
    ];
    return Path()..addPolygon(points, true);
  }

  @override
  bool shouldReclip(PentagonSegment oldClipper) => oldClipper.index != index;
}
