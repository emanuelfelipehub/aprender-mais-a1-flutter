import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/game_logic.dart';
import '../services/device_bridge.dart';
import '../theme.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.device});
  final DeviceBridge device;
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  QuizSession? _quiz;
  String? _error;
  bool _finishing = false;
  DateTime _lastTilt = DateTime.fromMillisecondsSinceEpoch(0);
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  void initState() {
    super.initState();
    _load();
    _subscription = widget.device.events.listen((event) {
      final quiz = _quiz;
      if (event['type'] != 'motion' ||
          quiz == null ||
          quiz.current.type != 'VF' ||
          quiz.graded ||
          _finishing) {
        return;
      }
      final x = (event['x'] as num).toDouble();
      if (x.abs() < 4 ||
          DateTime.now().difference(_lastTilt).inMilliseconds < 400) {
        return;
      }
      _lastTilt = DateTime.now();
      setState(() => quiz.select(x < 0 ? 1 : 0));
    });
  }

  Future<void> _load() async {
    try {
      final text = await rootBundle.loadString(
        'assets/data/bancoQuestoes.json',
      );
      if (mounted) {
        setState(() {
          _quiz = QuizSession(parseQuestions(text));
          _error = null;
        });
      }
      await _orient();
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Não foi possível ler as questões: $error');
      }
    }
  }

  Future<void> _orient() => SystemChrome.setPreferredOrientations(
    _quiz?.current.type == 'REL'
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : [DeviceOrientation.portraitUp],
  );

  Future<void> _finish() async {
    if (_finishing) return;
    if (_quiz == null) {
      Navigator.pop(context);
      return;
    }
    _finishing = true;
    _quiz!.grade();
    try {
      await widget.device.saveScore('quiz', _quiz!.score);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Quiz encerrado!'),
          content: Text('Pontuação total: ${_quiz!.score}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar para Home'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } on PlatformException catch (error) {
      _finishing = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar pontuação: ${error.message}')),
        );
      }
    }
  }

  Future<void> _next() async {
    if (_finishing || _quiz == null) return;
    final previous = _quiz!.index;
    final done = _quiz!.next();
    setState(() {});
    if (done) {
      await _finish();
      return;
    }
    if (previous != _quiz!.index) await _orient();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = _quiz;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _finish();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz My Brain'),
          leading: IconButton(
            tooltip: 'Voltar',
            onPressed: _finish,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      TextButton(
                        onPressed: _load,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              )
            : quiz == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Questão ${quiz.index + 1}/${quiz.questions.length} • ${quiz.current.weight} pontos',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        quiz.current.text,
                        key: const ValueKey('question-text'),
                        style: TextStyle(
                          fontSize: quiz.current.type == 'REL' ? 14 : 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: quiz.current.type == 'REL'
                            ? _matching(quiz)
                            : _choices(quiz),
                      ),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: quiz == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _finish,
                          child: const Text('Encerrar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          key: const ValueKey('quiz-next'),
                          onPressed: quiz.canSubmit ? _next : null,
                          child: Text(
                            quiz.current.type == 'REL' ? 'Avançar' : 'Próximo',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _choices(QuizSession quiz) => SingleChildScrollView(
    child: Column(
      children: [
        if (quiz.current.type == 'VF') ...[
          const TiltTutorial(),
          Row(
            children: [
              for (var i = 0; i < quiz.current.choices.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _choice(quiz, i)),
              ],
            ],
          ),
        ] else ...[
          for (var i = 0; i < quiz.current.choices.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _choice(quiz, i),
            ),
        ],
        if (quiz.revealed)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              quiz.isCorrect
                  ? 'Resposta correta!'
                  : 'Confira a alternativa correta destacada.',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
      ],
    ),
  );

  Widget _choice(QuizSession quiz, int index) {
    final correct = quiz.revealed && index == quiz.current.answer;
    final selected = quiz.selected == index;
    final active = correct || selected;
    final label = quiz.current.type == 'ME'
        ? '${String.fromCharCode(65 + index)}. ${quiz.current.choices[index]}'
        : quiz.current.choices[index];
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: correct
            ? ink
            : selected
            ? violet
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: ValueKey('answer-$index'),
          borderRadius: BorderRadius.circular(16),
          onTap: quiz.graded ? null : () => setState(() => quiz.select(index)),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: purple),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: active ? Colors.white : ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (correct)
                  const Icon(Icons.check_circle, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _matching(QuizSession quiz) => Column(
    children: [
      Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var term = 0; term < quiz.current.terms.length; term++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Draggable<int>(
                    data: term,
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: 210,
                        child: _matchBox(
                          quiz.current.terms[term],
                          selected: true,
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: .3,
                      child: _matchBox(quiz.current.terms[term]),
                    ),
                    child: Semantics(
                      label:
                          'Arraste ${quiz.current.terms[term]} para um conceito',
                      child: _matchBox(
                        quiz.current.terms[term],
                        selected: quiz.matches.containsKey(term),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (
              var concept = 0;
              concept < quiz.current.concepts.length;
              concept++
            )
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: DragTarget<int>(
                    onAcceptWithDetails: (details) =>
                        setState(() => quiz.match(details.data, concept)),
                    builder: (context, candidates, rejected) {
                      final term = quiz.matches.entries
                          .where((entry) => entry.value == concept)
                          .firstOrNull
                          ?.key;
                      final text =
                          quiz.current.concepts[concept] +
                          (term == null ? '' : ': ${quiz.current.terms[term]}');
                      return GestureDetector(
                        onTap: term == null
                            ? null
                            : () => setState(() => quiz.matches.remove(term)),
                        child: _matchBox(
                          text,
                          selected: term != null,
                          hovering: candidates.isNotEmpty,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );

  Widget _matchBox(
    String text, {
    bool selected = false,
    bool hovering = false,
  }) => Container(
    padding: const EdgeInsets.all(10),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: hovering
          ? const Color(0xFFE1D1FF)
          : selected
          ? const Color(0xFFF0E9FF)
          : Colors.white,
      border: Border.all(color: purple, width: hovering ? 3 : 1.5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: SingleChildScrollView(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class TiltTutorial extends StatefulWidget {
  const TiltTutorial({super.key});
  @override
  State<TiltTutorial> createState() => _TiltTutorialState();
}

class _TiltTutorialState extends State<TiltTutorial>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);
  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Column(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (_, child) => Transform.rotate(
            angle: (_animation.value - .5) * math.pi / 2,
            child: child,
          ),
          child: const Icon(Icons.screen_rotation, size: 52, color: purple),
        ),
        const SizedBox(height: 12),
        const Text(
          'Gire o celular ou toque na resposta.',
          textAlign: TextAlign.center,
        ),
        const Text(
          'Esquerda: Falso • Direita: Verdadeiro',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}
