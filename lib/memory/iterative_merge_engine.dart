import '../app_config.dart';
import '../models/context_parcel.dart';
import '../models/exchange.dart';
import '../debug/debug_logger.dart';
import '../models/llm_merge_strategy.dart';
import 'single_exchange_processor.dart';

/// Engine that incrementally merges a list of Exchanges into a ContextParcel
/// using an LLM-backed processor.
class IterativeMergeEngine {
  final MergeStrategy strategy;

  IterativeMergeEngine({this.strategy = MergeStrategy.defaultStrategy});

  factory IterativeMergeEngine.fromConfig() => IterativeMergeEngine(
      strategy: MergeStrategyParser.fromString(AppConfig.mergeStrategy));

  /// Merges [exchanges] sequentially using [SingleExchangeProcessor].
  /// Returns the final merged [ContextParcel].
  Future<ContextParcel> mergeAll(List<Exchange> exchanges) async {
    var context = ContextParcel(summary: '', mergeHistory: []);
    final mergeHistory = <int>[];
    var index = 0;

    if (AppConfig.debugMode) {
      print('IterativeMergeEngine: Using strategy $strategy');
    }
    for (final exchange in exchanges) {
      if (exchange.prompt.trim().isEmpty &&
          (exchange.response == null || exchange.response!.trim().isEmpty)) {
        if (AppConfig.debugMode) {
          print('IterativeMergeEngine: Skipping malformed exchange at index $index');
        }
        index++;
        continue;
      }

      try {
        final result = await SingleExchangeProcessor.process(context, exchange, strategy);
        if (result == null) {
          if (AppConfig.debugMode) {
            print('IterativeMergeEngine: Warning - null merge result at index $index');
          }
          index++;
          continue;
        }
        context = result;
        mergeHistory.add(index);
        if (AppConfig.debugMode) {
          print('IterativeMergeEngine: merged exchange $index');
          print('Current merge history: $mergeHistory');
          DebugLogger.logContextParcel(context, index);
        }
      } on MergeException catch (e) {
        if (AppConfig.debugMode) {
          print('IterativeMergeEngine: MergeException at index $index: $e');
        }
        index++;
        continue;
      }

      // ContextParcel state logged via DebugLogger above when debugMode is true.
      index++;
    }

    return ContextParcel(
      summary: context.summary,
      mergeHistory: mergeHistory,
      tags: context.tags,
      assumptions: context.assumptions,
      confidence: context.confidence,
    );
  }
}
