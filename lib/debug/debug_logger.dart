import 'dart:convert';
import 'dart:io';

import '../config/app_config.dart';
import '../models/context_parcel.dart';
import '../models/exchange.dart';
import '../memory/context_delta.dart';

/// Writes debug logs of [ContextParcel]s during merge operations.
class DebugLogger {
  /// Logs an arbitrary [message] when [AppConfig.debugMode] is enabled.
  static void log(String message) {
    if (!AppConfig.debugMode) return;
    print('[DEBUG] $message');
  }

  /// Logs [parcel] to a JSON file named `context_step_{stepIndex}.json`
  /// inside [AppConfig.debugOutputDir]. Includes a timestamp and step index.
  static void logContextParcel(ContextParcel parcel, int stepIndex) {
    if (!AppConfig.debugMode) return;
    final ts = DateTime.now().toIso8601String();
    final outputDir = Directory(AppConfig.debugOutputDir);
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }
    final path = '${outputDir.path}/context_step_$stepIndex.json';
    final data = {
      'timestamp': ts,
      'step': stepIndex,
      'parcel': parcel.toJson(),
    };
    File(path).writeAsStringSync(jsonEncode(data));
    stdout.writeln('DebugLogger: wrote $path at $ts');
  }

  /// Writes a timestamped snapshot of [parcel] after each merge step.
  /// The file is named `context_step_<stepIndex>_<timestamp>.json` inside
  /// the `debug/` directory. Any errors are caught to avoid disrupting
  /// the merge process.
  static void logContextCheckpoint(ContextParcel parcel, int stepIndex) {
    if (!AppConfig.debugMode) return;
    try {
      Directory('debug').createSync(recursive: true);
      final timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-');
      final filename = 'debug/context_step_${stepIndex}_$timestamp.json';
      final file = File(filename);
      file.createSync(recursive: true);
      file.writeAsStringSync(jsonEncode(parcel.toJson()));
    } catch (_) {
      // Swallow any exceptions to avoid interfering with merge flow
    }
  }

  /// Logs the [delta] between ContextParcel states to a timestamped JSON file.
  static void logContextDelta(ContextDelta delta, int stepIndex) {
    if (!AppConfig.debugMode) return;
    try {
      Directory('debug').createSync(recursive: true);
      final timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-');
      final filename = 'debug/context_delta_${stepIndex}_$timestamp.json';
      final file = File(filename);
      file.createSync(recursive: true);
      file.writeAsStringSync(jsonEncode(delta.toJson()));
    } catch (_) {
      // Swallow any exceptions to avoid interfering with merge flow
    }
  }

  /// Logs each LLM call with instructions, exchange, and context state.
  static void logLLMCall({
    required String instructions,
    required Exchange exchange,
    Object? context,
  }) {
    if (!AppConfig.debugMode) return;
    final timestamp = DateTime.now().toIso8601String();
    final contextString = context is ContextParcel
        ? jsonEncode(context.toJson())
        : context?.toString() ?? 'null';
    final log = '''
    === LLM CALL [$timestamp] ===
    Instructions:
    $instructions

    Exchange:
    PROMPT: ${exchange.prompt}
    RESPONSE: ${exchange.response}

    Context:
    $contextString
    ''';
    print(log);
    // Optionally write to file: debug/llm_call_$timestamp.txt
  }

  /// Logs the raw LLM [response] for debugging purposes.
  static void logRawResponse(String response) {
    if (!AppConfig.debugMode) return;
    // TODO: Implement logging of raw LLM responses
  }

  /// Logs the full [prompt] sent to the LLM and the [rawResponse] string.
  static void logLLMCallRaw({required String prompt, required String rawResponse}) {
    if (!AppConfig.debugMode) return;
    final timestamp = DateTime.now().toIso8601String();
    final entry = '''
=== LLM CALL [$timestamp] ===
PROMPT:
$prompt

RAW RESPONSE:
$rawResponse
''';
    print(entry);
  }

  /// Logs a warning message when [AppConfig.debugMode] is enabled.
  static void logWarning(String message) {
    if (!AppConfig.debugMode) return;
    print('[DEBUG WARNING] $message');
  }

  /// Logs an anomaly when [AppConfig.debugMode] is enabled.
  /// Anomalies represent unexpected states like unchanged context or
  /// merge failures. Entries are appended to `debug/anomalies.log` with
  /// an ISO timestamp.
  static void logAnomaly(String message) {
    if (!AppConfig.debugMode) return;
    final timestamp = DateTime.now().toIso8601String();
    final entry = '[$timestamp] ANOMALY: $message';
    print(entry);
    final file = File('debug/anomalies.log');
    file.writeAsStringSync('$entry\n', mode: FileMode.append);
  }

  /// Logs an error message with optional [error] and [stack] details.
  static void logError(String message,
      {Object? error, StackTrace? stack, String? raw}) {
    if (!AppConfig.debugMode) return;
    final timestamp = DateTime.now().toIso8601String();
    final entry = '[$timestamp] ERROR: $message';
    print(entry);
    if (error != null) print(error);
    if (raw != null) print('RAW CONTENT: $raw');
    if (stack != null) print(stack);
    final file = File('debug/errors.log');
    final buffer = StringBuffer(entry);
    if (error != null) buffer.write(' | $error');
    if (raw != null) buffer.write(' | RAW: $raw');
    file.writeAsStringSync('${buffer.toString()}\n', mode: FileMode.append);
  }

  /// Logs the parsed [parcel] returned from the LLM.
  static void logParsedParcel(ContextParcel parcel) {
    if (!AppConfig.debugMode) return;
    print('[DEBUG] Parsed ContextParcel: ${jsonEncode(parcel.toJson())}');
  }
}
