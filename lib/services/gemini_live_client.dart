import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class GeminiLiveClient {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  // Callback when audio bytes are received
  final Function(List<int>) onAudioReceived;
  final Function(String) onTextReceived;
  final Function() onConnected;
  final Function(String) onError;
  final Function() onDisconnected;

  GeminiLiveClient({
    required this.onAudioReceived,
    required this.onTextReceived,
    required this.onConnected,
    required this.onError,
    required this.onDisconnected,
  });

  void connect(String apiKey) {
    if (_channel != null) return;

    // Gemini Live Bidi Web Socket Endpoint (Alpha/V2)
    final uri = Uri.parse(
      'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key=$apiKey',
    );

    try {
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel?.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print("liveClient onError: $error");
          onError(error.toString());
          disconnect();
        },
        onDone: () {
          final closeCode = _channel?.closeCode;
          final closeReason = _channel?.closeReason;
          print("liveClient onDone: Server closed connection. Code: $closeCode, Reason: $closeReason");
          onDisconnected();
          disconnect();
        },
      );

      _sendSetupMessage();
    } catch (e) {
      onError(e.toString());
    }
  }

  void _sendSetupMessage() {
    final setupMsg = {
      "setup": {
        "model": "models/gemini-3.1-flash-live-preview",
        "systemInstruction": {
          "parts": [
            {
              "text":
                  "You are a strict but encouraging English tutor. Speak clearly and correct the user's grammar gently.",
            },
          ],
        },
        "generationConfig": {
          "responseModalities": ["AUDIO"],
          "speechConfig": {
            "voiceConfig": {
              "prebuiltVoiceConfig": {
                "voiceName": "Puck" 
              }
            }
          }
        }
      },
    };
    print("liveClient: Sending setup message for gemini-3.1...");
    _channel?.sink.add(jsonEncode(setupMsg));
  }

  void sendAudio(List<int> pcmData) {
    if (_channel == null) return;

    final rawInputMsg = {
      "realtimeInput": {
        "audio": {
          "mimeType": "audio/pcm;rate=16000",
          "data": base64Encode(pcmData)
        },
      },
    };
    _channel?.sink.add(jsonEncode(rawInputMsg));
  }

  void _handleMessage(dynamic message) {
    String? jsonString;
    if (message is String) {
      jsonString = message;
    } else if (message is List<int>) {
      jsonString = utf8.decode(message);
    }

    if (jsonString != null) {
      print("liveClient received: $jsonString");
      final data = jsonDecode(jsonString);

      if (data['setupComplete'] != null) {
        print("liveClient: setupComplete received.");
        onConnected();
        return;
      }

      // Check for server_content or serverContent
      final serverContent = data['serverContent'] ?? data['server_content'];
      if (serverContent != null) {
        final modelTurn = serverContent['modelTurn'] ?? serverContent['model_turn'];
        if (modelTurn != null) {
          final parts = modelTurn['parts'];
          if (parts != null && parts is List) {
            for (var part in parts) {
              if (part['text'] != null) {
                onTextReceived(part['text']);
              }
              final inlineData = part['inlineData'] ?? part['inline_data'];
              if (inlineData != null && inlineData['data'] != null) {
                final audioBytes = base64Decode(inlineData['data']);
                print("liveClient: Received audio chunk of ${audioBytes.length} bytes");
                onAudioReceived(audioBytes);
              }
            }
          }
        }
      }
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }
}
