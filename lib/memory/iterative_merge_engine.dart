import '../app_config.dart';
import '../models/context_parcel.dart';
import '../models/exchange.dart';

/// Engine that incrementally merges a list of Exchanges into a ContextParcel
/// using an LLM-backed processor.
class IterativeMergeEngine {
  /// Merges [exchanges] sequentially using [SingleExchangeProcessor].
  /// Returns the final merged [ContextParcel].
  Future<ContextParcel> mergeAll(List<Exchange> exchanges) async {
    var context = ContextParcel(summary: '', contributingExchangeIds: []);
    final mergeHistory = <int>[];

    for (var i = 0; i < exchanges.length; i++) {
      final ex = exchanges[i];
      if (ex.prompt.trim().isEmpty &&
          (ex.response == null || ex.response!.trim().isEmpty)) {
        print('IterativeMergeEngine: Skipping malformed exchange at index $i');
        continue;
      }

      try {
        context = await SingleExchangeProcessor.process(context, ex);
        mergeHistory.add(i);
      } catch (e) {
        print('IterativeMergeEngine: Warning - failed to merge exchange index $i: $e');
        continue;
      }

      if (AppConfig.debugMode) {
        print('IterativeMergeEngine debug after $i: ${context.toJson()}');
      }
    }

    return ContextParcel(
      summary: context.summary,
      contributingExchangeIds: mergeHistory,
      tags: context.tags,
      assumptions: context.assumptions,
      confidence: context.confidence,
    );
  }
}

/// Placeholder processor for a single Exchange. In the future this will
/// interact with an LLM via [LLMClient].
class SingleExchangeProcessor {
  static Future<ContextParcel> process(
      ContextParcel context, Exchange exchange) async {
    return LLMClient.mergeContext(context, exchange);
  }
}

/// Placeholder LLM client.
class LLMClient {
  static Future<ContextParcel> mergeContext(
      ContextParcel context, Exchange exchange) async {
    // TODO: Replace with real LLM call
    return context;
  }
}
