import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_page.dart';
import 'services/device_bridge.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(AprenderApp(device: AndroidDeviceBridge()));
}

class AprenderApp extends StatefulWidget {
  const AprenderApp({
    super.key,
    required this.device,
    this.systemAlerts = true,
  });
  final DeviceBridge device;
  final bool systemAlerts;
  @override
  State<AprenderApp> createState() => _AprenderAppState();
}

class _AprenderAppState extends State<AprenderApp> {
  final _navigator = GlobalKey<NavigatorState>();
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<Map<String, dynamic>>? _subscription;
  Future<void> _alerts = Future.value();
  bool _batteryWarned = false;

  @override
  void initState() {
    super.initState();
    if (!widget.systemAlerts) return;
    _subscription = widget.device.events.listen(
      _event,
      onError: (Object error) {
        _messenger.currentState?.showSnackBar(
          SnackBar(content: Text('Falha no monitor do dispositivo: $error')),
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _inspectDevice());
  }

  Future<void> _inspectDevice() async {
    try {
      final status = await widget.device.snapshot();
      if (!mounted) return;
      if (status['connected'] == false) {
        _enqueue(
          'Sem conexão com internet, seus dados podem não estar completamente salvos.',
        );
      }
      if (status['powerSave'] == true) {
        _enqueue(
          'Seu dispositivo está no modo economia de energia, alguns recursos podem ser limitados.',
        );
      }
      _checkBattery(status['battery'] as int?);
    } on PlatformException catch (error) {
      _enqueue('Não foi possível consultar o dispositivo: ${error.message}');
    }
  }

  void _event(Map<String, dynamic> event) {
    if (event['type'] == 'battery') _checkBattery(event['level'] as int?);
    if (event['type'] == 'headset') {
      _messenger.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            'Fone de ouvido conectado, o volume do dispositivo foi definido como 50%',
          ),
        ),
      );
    }
  }

  void _checkBattery(int? level) {
    if (level != null && level >= 0 && level <= 20 && !_batteryWarned) {
      _batteryWarned = true;
      _enqueue('Atenção. Bateria Baixa.', battery: true);
    }
  }

  // Uma fila impede que tres alertas de inicio aparecam sobrepostos.
  void _enqueue(String message, {bool battery = false}) {
    _alerts = _alerts.then((_) async {
      if (!mounted || _navigator.currentContext == null) return;
      await showDialog<void>(
        context: _navigator.currentContext!,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (battery) ...[
                Image.asset('assets/images/bateria.png', height: 92),
                const SizedBox(height: 20),
              ],
              Text(message, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Aprender+',
    debugShowCheckedModeBanner: false,
    navigatorKey: _navigator,
    scaffoldMessengerKey: _messenger,
    theme: appTheme(),
    home: HomePage(device: widget.device),
  );
}
