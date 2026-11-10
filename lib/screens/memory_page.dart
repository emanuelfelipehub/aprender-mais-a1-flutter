import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/game_logic.dart';
import '../services/device_bridge.dart';
import '../theme.dart';

const animalImages = [
  'arara.jpg',
  'macacoprego.jpg',
  'onca.jpg',
  'tamandua.jpg',
];
const carImages = ['car1.jpg', 'car2.jpg', 'car3.jpg', 'car4.jpg'];

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key, required this.device});
  final DeviceBridge device;
  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  final _game = MemoryGame();
  final _watch = Stopwatch();
  StreamSubscription<Map<String, dynamic>>? _subscription;
  Timer? _timer;
  Timer? _mismatch;
  String _theme = 'Animais da Amazonia';
  List<String> _customImages = [];
  bool _running = false;
  bool _finishing = false;
  int _countdown = 0;
  int _epoch = 0;

  List<String> get _images => _theme == 'Personalizado'
      ? _customImages
      : (_theme == 'Carros'
                ? carImages.map((image) => 'assets/images/cars/$image')
                : animalImages.map((image) => 'assets/images/animals/$image'))
            .toList();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _game.prepare(_images);
    _subscription = widget.device.events.listen((event) {
      if (event['type'] == 'shake' && mounted && !_finishing) {
        setState(_game.shuffle);
      }
    });
  }

  Future<void> _start() async {
    if (_running || _countdown > 0 || _finishing) return;
    final token = ++_epoch;
    _game.prepare(_images);
    for (var seconds = 3; seconds > 0; seconds--) {
      if (!mounted || token != _epoch) return;
      setState(() => _countdown = seconds);
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    if (!mounted || token != _epoch) return;
    setState(() {
      _countdown = 0;
      _running = true;
      _game.hideAll();
    });
    _watch
      ..reset()
      ..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _reveal(int id) {
    if (!_running || _game.busy || _finishing) return;
    final result = _game.reveal(id);
    setState(() {});
    if (result == false) {
      unawaited(widget.device.vibrate());
      final token = _epoch;
      _mismatch?.cancel();
      _mismatch = Timer(const Duration(seconds: 1), () {
        if (mounted && token == _epoch) setState(_game.hideMismatch);
      });
    } else if (result == true && _game.complete) {
      // Deixa o ultimo flip terminar antes de mostrar o resultado.
      final token = _epoch;
      Future<void>.delayed(const Duration(milliseconds: 430), () {
        if (mounted && token == _epoch) _end();
      });
    }
  }

  Future<void> _end({bool showResult = true}) async {
    if (_finishing) return;
    _finishing = true;
    ++_epoch;
    _timer?.cancel();
    _mismatch?.cancel();
    _watch.stop();
    final hits = _game.hits;
    final errors = _game.errors;
    final time = formatTime(_watch.elapsed.inSeconds);
    setState(() {
      _running = false;
      _countdown = 0;
    });
    await widget.device.saveScore('memo', hits);
    if (!mounted) return;
    if (showResult) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Partida encerrada!'),
          content: Text(
            'Score final: $hits\nAcertos: $hits\nErros: $errors\nTempo: $time',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }
    if (!mounted) return;
    _watch.reset();
    setState(() {
      _game.prepare(_images);
      _finishing = false;
    });
  }

  Future<void> _pickPhotos() async {
    try {
      final photos = await widget.device.pickPhotos();
      if (!mounted || photos.isEmpty) return;
      if (photos.length != 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione exatamente quatro fotos.')),
        );
        return;
      }
      setState(() {
        _customImages = photos;
        _theme = 'Personalizado';
        _game.prepare(_images);
      });
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir a galeria: ${error.message}'),
          ),
        );
      }
    }
  }

  Future<void> _back() async {
    if (_running || _countdown > 0) await _end(showResult: false);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    ++_epoch;
    _subscription?.cancel();
    _timer?.cancel();
    _mismatch?.cancel();
    _watch.stop();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = _running || _countdown > 0 || _finishing;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MemoCheck'),
          leading: IconButton(
            tooltip: 'Voltar',
            onPressed: _back,
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              tooltip: 'Configurações: escolher quatro fotos',
              onPressed: locked ? null : _pickPhotos,
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    StatChip('Tempo', formatTime(_watch.elapsed.inSeconds)),
                    StatChip('Acertos', _game.hits.toString().padLeft(2, '0')),
                    StatChip('Erros', _game.errors.toString().padLeft(2, '0')),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > constraints.maxHeight;
                      final columns = wide ? 4 : 2;
                      final rows = 8 ~/ columns;
                      return GridView.count(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: columns,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio:
                            ((constraints.maxWidth - (columns - 1) * 8) /
                                columns) /
                            ((constraints.maxHeight - (rows - 1) * 8) / rows),
                        children: [
                          for (final card in _game.cards)
                            FlipCard(
                              key: ValueKey('memory-card-${card.id}'),
                              card: card,
                              onTap: () => _reveal(card.id),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('Tema'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _theme,
                        items: [
                          const DropdownMenuItem(
                            value: 'Animais da Amazonia',
                            child: Text('Animais da Amazonia'),
                          ),
                          const DropdownMenuItem(
                            value: 'Carros',
                            child: Text('Carros'),
                          ),
                          if (_customImages.length == 4)
                            const DropdownMenuItem(
                              value: 'Personalizado',
                              child: Text('Personalizado'),
                            ),
                        ],
                        onChanged: locked
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    _theme = value;
                                    _game.prepare(_images);
                                  });
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      key: const ValueKey('memory-start'),
                      onPressed: _countdown > 0 || _finishing
                          ? null
                          : () => _running ? _end() : _start(),
                      child: Text(
                        _countdown > 0
                            ? '$_countdown'
                            : _running
                            ? 'STOP'
                            : 'START',
                      ),
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
}

class FlipCard extends StatelessWidget {
  const FlipCard({super.key, required this.card, required this.onTap});
  final MemoryCardData card;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    label: card.faceUp ? 'Carta ${card.pair + 1}, visível' : 'Carta oculta',
    button: true,
    child: GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: card.faceUp ? 0 : pi),
        duration: const Duration(milliseconds: 400),
        builder: (context, angle, child) {
          final front = angle < pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, .0015)
              ..rotateY(angle),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: front
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: card.matched
                              ? purple
                              : const Color(0xFFE0D6F2),
                          width: card.matched ? 4 : 1,
                        ),
                      ),
                      child: card.image.startsWith('assets/')
                          ? Image.asset(
                              card.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              cacheWidth: 600,
                              excludeFromSemantics: true,
                            )
                          : Image.file(
                              File(card.image),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              cacheWidth: 600,
                              excludeFromSemantics: true,
                            ),
                    )
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(pi),
                      child: Container(
                        color: violet,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.psychology_outlined,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    ),
  );
}
