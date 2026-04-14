import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  final apiKeyFile = File('scripts/api_key.txt');
  if (!apiKeyFile.existsSync()) {
    print('API key file not found at scripts/api_key.txt');
    return;
  }
  final apiKey = apiKeyFile.readAsStringSync().trim();

  final variations = [
    {
      'name': '3.1 Live (AUDIO ONLY)',
      'url': 'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key=$apiKey',
      'setup': {
        'setup': {
          'model': 'models/gemini-3.1-flash-live-preview',
          'generationConfig': {
             'responseModalities': ['AUDIO'],
          }
        }
      }
    },
  ];

  for (final variation in variations) {
    print('\n--- Testing Variation: ${variation['name']} ---');
    await testVariation(apiKey, variation);
    await Future.delayed(Duration(seconds: 2));
  }
}

Future<bool> testVariation(String apiKey, Map<String, dynamic> config) async {
  final uri = Uri.parse(config['url'] as String);
  final setupJson = config['setup'];

  final completer = Completer<void>();
  WebSocketChannel? channel;
  bool overallSuccess = false;

  try {
    channel = WebSocketChannel.connect(uri);
    print('Connecting to $uri...');

    final subscription = channel.stream.listen(
      (message) {
        final stringMsg = (message is List<int>) ? utf8.decode(message) : message.toString();
        print('Received: $stringMsg');
        
        if (stringMsg.contains('setupComplete')) {
          print('✅ Setup successful!');
          overallSuccess = true;
          
          // Test sending initial content - using camelCase
          final audioContent = {
            "realtimeInput": {
              "audio": {
                "mimeType": "audio/pcm;rate=16000",
                "data": base64Encode(List.filled(100, 0)) // dummy null audio
              }
            }
          };
          print('Sending Audio Content (camelCase)...');
          channel?.sink.add(jsonEncode(audioContent));
        } else if (stringMsg.contains('serverContent')) {
          print('🤖 Server Content Received!');
          completer.complete();
        }
      },
      onError: (error) {
        print('❌ Error: $error');
        completer.complete();
      },
      onDone: () {
        print('🔌 Connection closed. Code: ${channel?.closeCode}, Reason: ${channel?.closeReason}');
        completer.complete();
      },
    );

    print('Sending Setup...');
    // Ensure setup is also camelCase if needed, but we saw setupComplete coming back.
    channel.sink.add(jsonEncode(setupJson));

    await completer.future.timeout(Duration(seconds: 15), onTimeout: () {
      print('Timeout waiting for server content.');
    });
    
    await subscription.cancel();
  } catch (e) {
    print('💥 Exception: $e');
  } finally {
    await channel?.sink.close();
  }
  return overallSuccess;
}
