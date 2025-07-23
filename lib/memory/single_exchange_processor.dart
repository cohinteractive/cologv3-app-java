import 'dart:convert';

import '../app_config.dart';
import '../models/context_parcel.dart';
import '../models/exchange.dart';
import '../models/llm_merge_strategy.dart';
import '../services/llm_client.dart';
import '../src/instructions/instruction_templates.dart';

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
    final promptText = exchange.prompt.trim();
    final responseText = exchange.response?.trim() ?? '';

    if (promptText.isEmpty && responseText.isEmpty) {
      if (AppConfig.debugMode) {
        print('SingleExchangeProcessor: Warning - malformed exchange');
      }
      return inputParcel;
    }

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
    }

    final raw = await LLMClient.sendPrompt(prompt);
    if (raw.trim().isEmpty) {
      throw MergeException('Invalid LLM response');
    }

    try {
      final newParcel =
          ContextParcel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (AppConfig.debugMode) {
        print('SingleExchangeProcessor returned: ${jsonEncode(newParcel.toJson())}');
      }
      return newParcel;
    } catch (_) {
      throw MergeException('Invalid LLM response');
    }
  }
}
