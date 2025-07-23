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
    final responseText = exchange.response?.trim();

    if (promptText.isEmpty && (responseText == null || responseText.isEmpty)) {
      print('SingleExchangeProcessor: Warning - malformed exchange');
      return inputParcel;
    }

    var instructions = InstructionTemplates.merge;
    switch (strategy) {
      case MergeStrategy.conservative:
        instructions += ' Use a conservative merge strategy.';
        break;
      case MergeStrategy.aggressive:
        instructions +=
            ' Use an aggressive merge strategy that overwrites conflicting details.';
        break;
      case MergeStrategy.defaultStrategy:
        break;
    }

    final prompt = jsonEncode({
      'context': inputParcel.toJson(),
      'exchange': {
        'prompt': exchange.prompt,
        'response': exchange.response,
      },
      'instructions': instructions,
    });

    if (AppConfig.debugMode) {
      print('SingleExchangeProcessor prompt: $prompt');
    }

    final raw = await LLMClient.sendPrompt(prompt);
    if (raw.trim().isEmpty) {
      throw MergeException('LLM returned empty response');
    }

    try {
      final parsed = jsonDecode(raw);
      final parcel = ContextParcel.fromJson(parsed);
      if (AppConfig.debugMode) {
        print('SingleExchangeProcessor returned: ${parcel.toJson()}');
      }
      return parcel;
    } catch (e) {
      throw MergeException('Failed to parse LLM response: $e');
    }
  }
}
