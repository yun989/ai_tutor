import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/gemini_live_client.dart';
import '../services/api_key_service.dart';

enum LiveSessionState { disconnected, connecting, listening, aiSpeaking, error }

class LiveTutorProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  GeminiLiveClient? _liveClient;

  LiveSessionState _state = LiveSessionState.disconnected;
  LiveSessionState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _currentAiText = '';
  String get currentAiText => _currentAiText;

  // Provide cleanup when provider is destroyed
  @override
  void dispose() {
    stopSession();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> startSession() async {
    if (_state == LiveSessionState.connecting ||
        _state == LiveSessionState.listening)
      return;

    _setState(LiveSessionState.connecting);
    print("startSession: Connecting...");

    try {
      final apiKey = await ApiKeyService.getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API Key not found. Please log in again.");
      }

      print("startSession: Initializing audio service...");
      await _audioService.init();
      print("startSession: Audio service initialized successfully.");

      _liveClient = GeminiLiveClient(
        onConnected: () {
          print("liveClient: Setup complete! Transitioning to listening state.");
          _setState(LiveSessionState.listening);
          _startRecording();
        },
        onAudioReceived: (audioBytes) {
          if (_state != LiveSessionState.aiSpeaking) {
            _setState(LiveSessionState.aiSpeaking);
          }
          _audioService.playAudioChunk(audioBytes);
        },
        onTextReceived: (text) {
          print("liveClient: Text received: $text");
          _currentAiText += text;
          notifyListeners();
        },
        onError: (err) {
          print("liveClient onError: $err");
          _errorMessage = err;
          _setState(LiveSessionState.error);
          stopSession();
        },
        onDisconnected: () {
          print("liveClient: Connection terminated.");
          stopSession();
        },
      );

      print("startSession: Initiating connection to Gemini Live...");
      _liveClient?.connect(apiKey);
    } catch (e, stacktrace) {
      print("startSession Exception: $e");
      print("startSession Stacktrace: $stacktrace");
      _errorMessage = e.toString();
      _setState(LiveSessionState.error);
    }
  }

  Future<void> _startRecording() async {
    await _audioService.startRecording((pcmData) {
      if (_state == LiveSessionState.listening ||
          _state == LiveSessionState.aiSpeaking) {
        _liveClient?.sendAudio(pcmData);
        // Note: In 2026 Barge-in, sending audio while AI Speaking triggers interruption
      }
    });
  }

  void stopSession() {
    _audioService.stopRecording();
    _liveClient?.disconnect();
    _liveClient = null;
    _currentAiText = '';
    _setState(LiveSessionState.disconnected);
  }

  void _setState(LiveSessionState newState) {
    _state = newState;
    notifyListeners();
  }
}
