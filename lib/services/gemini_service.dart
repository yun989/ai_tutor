import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GenerativeModel? _model;
  ChatSession? _chatSession;

  static Future<bool> validateApiKey(String apiKey) async {
    try {
      final tempModel = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: apiKey,
      );
      // countTokens is a cheap operation used to verify if the API key works
      await tempModel.countTokens([Content.text("test")]);
      return true;
    } catch (e) {
      // Only invalidate the key if it's explicitly an invalid key error.
      // If it's a network error (e.g. SocketException), we should not force the user to re-enter their key.
      if (e.runtimeType.toString() == 'InvalidApiKey' || 
          e.toString().contains('API key not valid') ||
          e.toString().contains('API_KEY_INVALID')) {
        return false;
      }
      return true; // Assume true on network errors to preserve the saved key
    }
  }

  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
      systemInstruction: Content.system(
        "You are a strict but encouraging English tutor. "
        "Your goal is to help the user improve their English. "
        "If the user makes grammar or vocabulary mistakes, correct them gently and explain why. "
        "Keep your responses engaging and ask follow-up questions to keep the conversation going.",
      ),
    );
    _chatSession = _model?.startChat();
  }

  Future<String?> sendMessage(String message) async {
    if (_chatSession == null) {
      throw Exception(
        "GeminiService not initialized. Please set API key first.",
      );
    }
    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text;
    } catch (e) {
      throw Exception("Failed to send message: $e");
    }
  }

  static Future<String?> generateSummary(String apiKey, String transcript) async {
    try {
      final summaryModel = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: apiKey,
        systemInstruction: Content.system(
          "You are a professional English teaching assistant. Please analyze the following transcript of an AI English tutor session.\n"
          "Extract the key teaching points from this conversation and output them entirely in English using Markdown format.\n"
          "The output must include the following structure:\n"
          "1. 📝 **Key Takeaways**: What English concepts were taught in this conversation.\n"
          "2. 📚 **Vocabulary & Phrases**: Useful words and phrases that appeared in the conversation.\n"
          "3. 💡 **Overall Suggestions**: Follow-up learning advice for the student."
        ),
      );
      final response = await summaryModel.generateContent([
        Content.text("對話紀錄如下：\n$transcript")
      ]);
      return response.text;
    } catch (e) {
      throw Exception("Failed to generate summary: $e");
    }
  }
}
