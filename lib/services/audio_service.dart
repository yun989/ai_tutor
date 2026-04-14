import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isInit = false;
  StreamSubscription<Uint8List>? _audioSubscription;

  Future<void> init() async {
    if (_isInit) return;

    // Request microphone permission natively using the record package
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
    await _player.stop();
  }

  Future<void> playAudioChunk(List<int> chunk) async {
    if (!_isInit) await init();
    
    // Wrap raw 24kHz 16-bit Mono PCM in a WAV header
    final wavData = _createWavHeader(chunk, 24000);
    
    // Play the wrapped bytes as a source
    await _player.play(BytesSource(wavData));
  }

  Uint8List _createWavHeader(List<int> pcmData, int sampleRate) {
    final int dataSize = pcmData.length;
    final int fileSize = dataSize + 36;
    final int byteRate = sampleRate * 1 * 16 ~/ 8;
    
    final ByteData header = ByteData(44);
    
    // RIFF header
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileSize, Endian.little);
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E
    
    // fmt chunk
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6d); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, 1, Endian.little); // Channels
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, 2, Endian.little); // Block align
    header.setUint16(34, 16, Endian.little); // Bits per sample
    
    // data chunk
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataSize, Endian.little);
    
    final Uint8List result = Uint8List(44 + dataSize);
    result.setRange(0, 44, header.buffer.asUint8List());
    result.setRange(44, 44 + dataSize, pcmData);
    
    return result;
  }

  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }
}
