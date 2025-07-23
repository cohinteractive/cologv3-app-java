typedef PromptSender = Future<String> Function(String);

class LLMClient {
  /// Function used to send prompts. Can be overridden in tests.
  static PromptSender sendPrompt = _defaultSendPrompt;

  static Future<String> _defaultSendPrompt(String prompt) async {
    // TODO: Connect to real LLM
    return '';
  }
}
