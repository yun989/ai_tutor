import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/api_key_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class TutorProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isApiKeySet = false;
  bool get isApiKeySet => _isApiKeySet;

  TutorProvider() {
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    final apiKey = await ApiKeyService.getApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      _geminiService.initialize(apiKey);
      _isApiKeySet = true;
      notifyListeners();
    }
  }

  Future<void> setApiKey(String apiKey) async {
    await ApiKeyService.saveApiKey(apiKey);
    _geminiService.initialize(apiKey);
    _isApiKeySet = true;
    notifyListeners();
  }
  
  Future<void> removeApiKey() async {
      await ApiKeyService.deleteApiKey();
      _isApiKeySet = false;
      _messages.clear();
      notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _geminiService.sendMessage(text);
      if (response != null) {
        _messages.add(ChatMessage(text: response, isUser: false));
      }
    } catch (e) {
      _messages.add(ChatMessage(text: "Error: ${e.toString()}", isUser: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
