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
      return false;
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
          "你是一位專業的英文教學助理。請分析以下這段AI英文家教的對話紀錄片段。\n"
          "請幫我萃取出這次對話的教學重點，並以繁體中文與 Markdown 格式輸出。\n"
          "必須包含以下結構：\n"
          "1. 📝 **重點回顧**：這段對話中教了哪些英文概念。\n"
          "2. 📚 **單字與片語**：對話中出現的實用詞彙與用法。\n"
          "3. 💡 **綜合建議**：給予學生的後續學習建議。"
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
