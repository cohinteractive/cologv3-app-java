import 'dart:convert';
import 'dart:io';

import '../app_config.dart';
import '../models/context_parcel.dart';

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

  /// Logs the raw LLM [response] for debugging purposes.
  static void logRawResponse(String response) {
    // TODO: Implement logging of raw LLM responses
  }

  /// Logs the parsed [parcel] returned from the LLM.
  static void logParsedParcel(ContextParcel parcel) {
    // TODO: Implement logging of parsed ContextParcel objects
  }
}
