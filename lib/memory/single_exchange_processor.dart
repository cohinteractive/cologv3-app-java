import 'dart:convert';

import '../config/app_config.dart';
import '../models/context_parcel.dart';
import '../models/exchange.dart';
import '../models/llm_merge_strategy.dart';
import '../services/llm_client.dart';
import '../llm/instruction_templates.dart';
import '../debug/debug_logger.dart';

class MergeException implements Exception {
  final String message;
  MergeException(this.message);
  @override
  String toString() => 'MergeException: $message';
}

/// Processes a single Exchange using an LLM to merge it with an existing
/// ContextParcel.
class SingleExchangeProcessor {
  /// Sends [exchange] and [inputParcel] to the LLM and returns the merged parcel.
  static Future<ContextParcel> process(
      ContextParcel inputParcel, Exchange exchange, MergeStrategy strategy) async {
    if (!exchange.isValid()) {
      if (AppConfig.debugMode) {
        DebugLogger.logWarning(
            'Skipping malformed Exchange: prompt or response is empty');
      }
      return inputParcel;
    }

    final promptText = exchange.prompt.trim();
    final responseText = exchange.response!.trim();

    final mergeInstructions = InstructionTemplates.forStrategy(strategy);
    final prompt = '''=== MERGE INSTRUCTIONS ===
$mergeInstructions

=== EXISTING CONTEXT ===
${jsonEncode(inputParcel.toJson())}

=== NEW EXCHANGE ===
PROMPT:
$promptText
RESPONSE:
$responseText''';

    if (AppConfig.debugMode) {
      print('SingleExchangeProcessor prompt:\n$prompt');
      DebugLogger.logLLMCall(
        instructions: mergeInstructions,
        exchange: exchange,
        context: inputParcel,
      );
    }

    final Map<String, dynamic> response = await LLMClient.sendPrompt(prompt);
    if (AppConfig.debugMode) {
      DebugLogger.logLLMCallRaw(
          prompt: prompt, rawResponse: jsonEncode(response));
      print('[DEBUG] Full OpenAI JSON response:\n$response');
    }
    final choices = response['choices'];
    if (choices == null || choices.isEmpty) {
      throw MergeException('No choices returned from LLM');
    }

    final content = choices.first['message']?['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw MergeException('LLM response content is empty');
    }

    print('[DEBUG] Raw LLM response content:\n$content');

    Map<String, dynamic> parsed;
    try {
      parsed = jsonDecode(content);
    } catch (e) {
      DebugLogger.logError('LLM returned non-JSON content', error: e, stack: StackTrace.current, raw: content);
      throw MergeException('Invalid JSON format in LLM response');
    }

    try {
      final contextParcel = ContextParcel.fromJson(parsed);
      DebugLogger.log('LLM Summary Returned: ${contextParcel.summary}');

      if (contextParcel.summary.isEmpty && contextParcel.mergeHistory.isEmpty) {
        throw const FormatException();
      }

      if (AppConfig.debugMode) {
        DebugLogger.logRawResponse(jsonEncode(response));
        DebugLogger.logParsedParcel(contextParcel);
      }

      return contextParcel;
    } catch (e, stack) {
      DebugLogger.logError('LLM merge failed', error: e, stack: stack, raw: content);
      throw MergeException('LLM returned invalid ContextParcel format');
    }
  }
}
