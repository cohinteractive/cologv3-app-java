import 'dart:convert';

import '../config/app_config.dart';
import '../models/context_parcel.dart';
import '../models/exchange.dart';
import '../models/merge_strategy.dart';
import '../services/llm_client.dart';
import '../src/instructions/instruction_templates.dart';
import '../debug/debug_logger.dart';

/// Parses an LLM [response] into a [ContextParcel]. Returns null if parsing
/// fails or the response is empty.
ContextParcel? process(Map<String, dynamic> response) {
  final choices = response['choices'];
  if (choices == null || choices.isEmpty) {
    return null;
  }
  final content = choices.first['message']?['content'] as String?;
  if (content == null || content.trim().isEmpty) {
    return null;
  }

  try {
    final Map<String, dynamic> json = jsonDecode(content);
    final parcel = ContextParcel.fromJson(json);
    if (AppConfig.debugMode) {
      DebugLogger.logParsedParcel(parcel);
    }
    return parcel;
  } catch (e) {
    DebugLogger.logError(
      'Failed to parse context extraction',
      error: e,
      raw: content,
    );
    return null;
  }
}

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

    try {
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
        print('[DEBUG] Prompt sent to LLM:\n$prompt');
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
        print('[DEBUG] Full raw LLM response:\n${jsonEncode(response)}');
      }
      final choices = response['choices'];
      if (choices == null || choices.isEmpty) {
        if (AppConfig.debugMode) {
          print('[DEBUG] No choices returned in response');
        }
        throw MergeException('No choices returned from LLM');
      }

      final content = choices.first['message']?['content'] as String?;
      if (AppConfig.debugMode) {
        print('[DEBUG] Raw content string: $content');
      }
      if (content == null || content.trim().isEmpty) {
        print('[DEBUG] content was null or empty');
        throw MergeException('LLM response content is empty');
      }

      Map<String, dynamic> parsed;
      try {
        parsed = jsonDecode(content);
        if (AppConfig.debugMode) {
          print('[DEBUG] Parsed JSON: $parsed');
        }
        if (!parsed.containsKey('summary')) {
          print('[DEBUG] Parsed JSON missing "summary" key');
        }
      } catch (e) {
        if (AppConfig.debugMode) {
          print('[DEBUG] Failed to decode JSON');
        }
        DebugLogger.logError('LLM returned non-JSON content', error: e, stack: StackTrace.current, raw: content);
        throw MergeException('Invalid JSON format in LLM response');
      }

      try {
        final contextParcel = ContextParcel.fromJson(parsed);
        if (AppConfig.debugMode) {
          print('[DEBUG] ContextParcel.summary: ${contextParcel.summary}');
        }
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
    } catch (e, stack) {
      if (AppConfig.debugMode) {
        print('[DEBUG] General failure in process(): $e');
      }
      DebugLogger.logError('LLM merge failed', error: e, stack: stack);
      throw MergeException('Failed to process LLM response: $e');
    }
  }

  /// Processes a single [exchange] and returns a [ContextParcel] generated
  /// by the LLM without merging it into existing context.
  static Future<ContextParcel?> processExchange(Exchange exchange) async {
    final prompt = InstructionTemplates.contextExtractionPrompt(exchange);

    if (AppConfig.debugMode) {
      DebugLogger.logLLMCall(
        context: 'supervised_merge_iteration',
        instructions: prompt,
        exchange: exchange,
      );
    }

    final response = await LLMClient.sendPrompt(prompt);
    return SingleExchangeProcessor.process(response);
  }
}
