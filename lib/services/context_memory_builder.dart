import '../models/context_memory.dart';
import '../models/context_parcel.dart';

/// Utility for constructing a finalized [ContextMemory] from the
/// latest [ContextParcel] produced by the merge pipeline.
class ContextMemoryBuilder {
  /// Combines [latest] with optional [history] into a new [ContextMemory].
  /// If [generatedAt] is not provided, the current time is used.
  /// If [totalExchangeCount] is null, it is inferred from the highest
  /// exchange index present in the parcel merge histories.
  static ContextMemory buildFinalMemory({
    required ContextParcel latest,
    List<ContextParcel> history = const [],
    String? sourceConversationId,
    DateTime? generatedAt,
    int? totalExchangeCount,
    String? mergeStrategy,
    String? notes,
    /// Overall confidence annotation from the LLM, if provided.
    String? confidence,
    /// How complete the LLM believes this memory is.
    String? completeness,
    /// Any limitations or caveats noted when generating the memory.
    String? limitations,
  }) {
    final parcels = <ContextParcel>[...history, latest];

    final genAt = generatedAt ?? DateTime.now();
    int? exchangeCount = totalExchangeCount;
    if (exchangeCount == null) {
      final ids = parcels.expand((p) => p.mergeHistory).toList();
      if (ids.isNotEmpty) {
        final maxId = ids.reduce((a, b) => a > b ? a : b);
        exchangeCount = maxId + 1;
      }
    }

    return ContextMemory(
      parcels: parcels,
      generatedAt: genAt,
      sourceConversationId: sourceConversationId,
      exchangeCount: exchangeCount,
      strategy: mergeStrategy,
      notes: notes,
      confidence: confidence,
      completeness: completeness,
      limitations: limitations,
    );
  }
}
