import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:record/record.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();

  bool _isInit = false;
  StreamSubscription<Uint8List>? _audioSubscription;

  Future<void> init() async {
    if (_isInit) return;

    // Request microphone permission natively using the record package (works on Web too)
    if (await _recorder.hasPermission()) {
      _isInit = true;
    } else {
      throw Exception('Microphone permission not granted');
    }
  }

  Future<void> startRecording(Function(List<int>) onData) async {
    if (!_isInit) await init();

    final config = const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    );

    final stream = await _recorder.startStream(config);

    _audioSubscription = stream.listen((buffer) {
      onData(buffer);
    });
  }

  Future<void> stopRecording() async {
    await _audioSubscription?.cancel();
    await _recorder.stop();
  }

  Future<void> playAudioChunk(List<int> chunk) async {
    // In a real live streaming scenario, we might need a dedicated audio buffer/queue mechanism
    // This is a simplified placeholder.
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}

