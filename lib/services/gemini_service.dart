import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GenerativeModel? _model;
  ChatSession? _chatSession;

  static Future<bool> validateApiKey(String apiKey) async {
    try {
      final tempModel = GenerativeModel(
        model: 'gemini-3.1-flash-lite-preview',
        apiKey: apiKey,
      );
      // countTokens is a cheap operation used to verify if the API key works
      await tempModel.countTokens([Content.text("test")]);
      return true;
    } catch (e) {
      return false;
    }
  }

  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-3.1-flash-lite-preview', // 快速而低成本的版本，且免費用戶可使用
      apiKey: apiKey,
      systemInstruction: Content.system(
        "You are a strict but encouraging English tutor. "
        "Your goal is to help the user improve their English. "
        "If the user makes grammar or vocabulary mistakes, correct them gently and explain why. "
        "Keep your responses engaging and ask follow-up questions to keep the conversation going."
      ),
    );
    _chatSession = _model?.startChat();
  }

  Future<String?> sendMessage(String message) async {
    if (_chatSession == null) {
      throw Exception("GeminiService not initialized. Please set API key first.");
    }
    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text;
    } catch (e) {
      throw Exception("Failed to send message: $e");
    }
  }
}
