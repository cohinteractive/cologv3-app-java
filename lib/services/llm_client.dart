import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

typedef PromptSender = Future<String> Function(String);

class LLMClient {
  /// Function used to send prompts. Can be overridden in tests.
  static PromptSender sendPrompt = _defaultSendPrompt;

  static Future<String> _defaultSendPrompt(String prompt) async {
    final apiKey = Platform.environment['OPENAI_API_KEY_COLOG'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY_COLOG not found in environment.');
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.2,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'OpenAI request failed: ${response.statusCode} ${response.body}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    final choices = json['choices'];
    if (choices is List && choices.isNotEmpty) {
      final message = choices[0]['message'];
      if (message is Map<String, dynamic> && message['content'] != null) {
        return message['content'] as String;
      }
    }

    throw Exception('OpenAI response missing message content');
  }
}
