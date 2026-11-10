import 'package:flutter/services.dart';

/// A interface permite trocar o Android real por um dispositivo falso nos testes.
abstract class DeviceBridge {
  Stream<Map<String, dynamic>> get events;
  Future<Map<String, dynamic>> snapshot();
  Future<bool> play(String asset, {bool effect = false});
  Future<void> stopAudio();
  Future<void> vibrate();
  Future<List<String>> pickPhotos();
  Future<void> saveScore(String game, int score);
  Future<Map<String, int>> scores();
}

class AndroidDeviceBridge implements DeviceBridge {
  static const _methods = MethodChannel('aprender_a1/device');
  static const _events = EventChannel('aprender_a1/events');
  late final Stream<Map<String, dynamic>> _stream = _events
      .receiveBroadcastStream()
      .map((event) => Map<String, dynamic>.from(event as Map))
      .asBroadcastStream();
  @override
  Stream<Map<String, dynamic>> get events => _stream;
  @override
  Future<Map<String, dynamic>> snapshot() async => Map<String, dynamic>.from(
    await _methods.invokeMethod<Map<dynamic, dynamic>>('snapshot') ?? {},
  );
  @override
  Future<bool> play(String asset, {bool effect = false}) async =>
      await _methods.invokeMethod<bool>('playSound', {
        'asset': asset,
        'effect': effect,
      }) ??
      false;
  @override
  Future<void> stopAudio() => _methods.invokeMethod<void>('stopAudio');
  @override
  Future<void> vibrate() => _methods.invokeMethod<void>('vibrate');
  @override
  Future<List<String>> pickPhotos() async =>
      await _methods.invokeListMethod<String>('pickPhotos') ?? [];
  @override
  Future<void> saveScore(String game, int score) =>
      _methods.invokeMethod<void>('saveScore', {'game': game, 'score': score});
  @override
  Future<Map<String, int>> scores() async => Map<String, int>.from(
    await _methods.invokeMethod<Map<dynamic, dynamic>>('scores') ?? {},
  );
}
