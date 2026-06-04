// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

class PlatformRecorder {
  html.MediaRecorder? _mr;
  html.MediaStream? _stream;
  final List<html.Blob> _chunks = [];

  Future<bool> requestPermission() async {
    try {
      _stream = await html.window.navigator.getUserMedia(audio: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> start() async {
    _chunks.clear();
    _stream ??= await html.window.navigator.getUserMedia(audio: true);
    _mr = html.MediaRecorder(_stream!);
    _mr!.addEventListener('dataavailable', (e) {
      final blob = (e as html.BlobEvent).data;
      if (blob != null && blob.size > 0) _chunks.add(blob);
    });
    _mr!.start();
  }

  Future<Uint8List?> stop() async {
    if (_mr == null) return null;
    _mr!.requestData();
    await Future.delayed(const Duration(milliseconds: 150));
    _mr!.stop();
    await Future.delayed(const Duration(milliseconds: 300));
    if (_chunks.isEmpty) return null;
    final blob = html.Blob(_chunks, 'audio/webm');
    final reader = html.FileReader();
    reader.readAsArrayBuffer(blob);
    await reader.onLoadEnd.first;
    return reader.result as Uint8List?;
  }

  void dispose() {
    try {
      _mr?.stop();
      _stream?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
  }
}