import 'dart:typed_data';

class PlatformRecorder {
  Future<bool> requestPermission() async => true;
  Future<void> start() async {}
  Future<Uint8List?> stop() async => null;
  void dispose() {}
}