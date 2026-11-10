import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/device_bridge.dart';
import '../theme.dart';
import 'quiz_page.dart';
import 'genius_page.dart';
import 'memory_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.device});
  final DeviceBridge device;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, int> _scores = {};
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final scores = await widget.device.scores();
      if (mounted) setState(() => _scores = scores);
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível ler as pontuações: ${error.message}',
            ),
          ),
        );
      }
    }
  }

  Future<void> _open(String game) async {
    final page = switch (game) {
      'quiz' => QuizPage(device: widget.device),
      'genius' => GeniusPage(device: widget.device),
      _ => MemoryPage(device: widget.device),
    };
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => page),
    );
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Aprender+')),
    drawer: Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Voltar',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const CircleAvatar(
              radius: 42,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
            const SizedBox(height: 20),
            _menu('Home', Icons.home_outlined, () => Navigator.pop(context)),
            _menu('QuizMyBrain', Icons.quiz_outlined, () {
              Navigator.pop(context);
              _open('quiz');
            }),
            _menu('GeniusPLay', Icons.music_note_outlined, () {
              Navigator.pop(context);
              _open('genius');
            }),
            _menu('MemoCheck', Icons.grid_view_rounded, () {
              Navigator.pop(context);
              _open('memo');
            }),
            const Spacer(),
            _menu('Sair', Icons.logout, () => SystemNavigator.pop()),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 150,
            semanticLabel: 'Logotipo Aprender+',
          ),
          const SizedBox(height: 28),
          Text(
            'Bem-vindo ao Aprender+',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          const Text(
            'Escolha um jogo e aprenda brincando.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _card(
            'QuizMyBrain',
            'Desafie seus conhecimentos',
            Icons.quiz_outlined,
            'quiz',
          ),
          _card(
            'GeniusPlay',
            'Ouça, memorize e repita as cores',
            Icons.music_note_outlined,
            'genius',
          ),
          _card(
            'MemoCheck',
            'Encontre os quatro pares',
            Icons.grid_view_rounded,
            'memo',
          ),
        ],
      ),
    ),
  );
  Widget _menu(String title, IconData icon, VoidCallback onTap) =>
      ListTile(title: Text(title), leading: Icon(icon), onTap: onTap);
  Widget _card(String title, String subtitle, IconData icon, String game) =>
      Card(
        elevation: 0,
        color: const Color(0xFFF0E9FF),
        margin: const EdgeInsets.only(bottom: 14),
        child: ListTile(
          key: ValueKey('open-$game'),
          minVerticalPadding: 18,
          leading: Icon(icon, color: purple, size: 30),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text('$subtitle\nÚltima pontuação: ${_scores[game] ?? 0}'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () => _open(game),
        ),
      );
}
