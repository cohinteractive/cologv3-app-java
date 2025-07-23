import 'dart:convert';
import 'dart:io';

import '../app_config.dart';
import '../models/context_parcel.dart';
import '../models/exchange.dart';
import '../memory/context_delta.dart';

/// Writes debug logs of [ContextParcel]s during merge operations.
class DebugLogger {
  /// Logs [parcel] to a JSON file named `context_step_{stepIndex}.json`
  /// inside [AppConfig.debugOutputDir]. Includes a timestamp and step index.
  static void logContextParcel(ContextParcel parcel, int stepIndex) {
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
    required ContextParcel context,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final log = '''
    === LLM CALL [$timestamp] ===
    Instructions:
    $instructions

    Exchange:
    PROMPT: ${exchange.prompt}
    RESPONSE: ${exchange.response}

    ContextParcel:
    ${jsonEncode(context.toJson())}
    ''';
    print(log);
    // Optionally write to file: debug/llm_call_$timestamp.txt
  }

  /// Logs the raw LLM [response] for debugging purposes.
  static void logRawResponse(String response) {
    // TODO: Implement logging of raw LLM responses
  }

  /// Logs a warning message when [AppConfig.debugMode] is enabled.
  static void logWarning(String message) {
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

  /// Logs the parsed [parcel] returned from the LLM.
  static void logParsedParcel(ContextParcel parcel) {
    // TODO: Implement logging of parsed ContextParcel objects
  }
}
