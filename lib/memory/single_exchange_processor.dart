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

    final response = await LLMClient.sendPrompt(prompt);
    if (response.trim().isEmpty) {
      throw MergeException('LLM returned invalid ContextParcel format');
    }

    try {
      final Map<String, dynamic> json = jsonDecode(response);
      final newParcel = ContextParcel.fromJson(json);

      if (newParcel.summary.isEmpty && newParcel.mergeHistory.isEmpty) {
        throw const FormatException();
      }

      if (AppConfig.debugMode) {
        DebugLogger.logRawResponse(response);
        DebugLogger.logParsedParcel(newParcel);
      }

      return newParcel;
    } catch (_) {
      throw MergeException('LLM returned invalid ContextParcel format');
    }
  }
}
