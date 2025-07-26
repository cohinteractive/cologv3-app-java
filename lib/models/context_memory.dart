/// Defines the final merged memory after processing a conversation.
///
/// `ContextMemory` stores the list of consolidated [ContextParcel] objects
/// produced by the merge pipeline. Optional metadata describes when and how
/// the memory was generated so it can be routed or audited by other tools.

import 'context_parcel.dart';
import '../injection/injectable_context.dart';

class ContextMemory {
  /// Ordered list of merged context parcels representing the conversation.
  final List<ContextParcel> parcels;

  /// Map of inline tag labels to parcel indices.
  final Map<String, List<int>> tagIndex;

  /// Timestamp when this memory snapshot was generated.
  final DateTime? generatedAt;

  /// Identifier for the original conversation this memory summarizes.
  final String? sourceConversationId;

  /// Total number of exchanges that contributed to this memory.
  final int? exchangeCount;

  /// Merge strategy or version string used during generation.
  final String? strategy;

  /// Optional free-form notes about this memory snapshot.
  ///
  /// This may include explanations from the LLM, caveats, or other
  /// context that doesn't fit in the dedicated fields below.
  final String? notes;

  /// Overall confidence score or description provided by the LLM.
  ///
  /// Use this to gauge how reliable the summarized context may be.
  final String? confidence;

  /// Indicates how complete the LLM believes this memory to be.
  ///
  /// Useful when only a partial conversation was available during
  /// summarization.
  final String? completeness;

  /// Any known limitations or blind spots noted by the LLM when
  /// generating this memory.
  final String? limitations;

  ContextMemory({
    List<ContextParcel>? parcels,
    Map<String, List<int>>? tagIndex,
    this.generatedAt,
    this.sourceConversationId,
    this.exchangeCount,
    this.strategy,
    this.notes,
    this.confidence,
    this.completeness,
    this.limitations,
  })  : parcels = parcels ?? [],
        tagIndex = tagIndex ?? {};

  factory ContextMemory.fromJson(Map<String, dynamic> json) => ContextMemory(
        parcels: (json['parcels'] as List<dynamic>?)
                ?.map((e) => ContextParcel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        tagIndex: (json['tagIndex'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, List<int>.from(v as List<dynamic>)),
            ) ??
            {},
        generatedAt: json['generatedAt'] != null
            ? DateTime.parse(json['generatedAt'])
            : null,
        sourceConversationId: json['sourceConversationId'] as String?,
        exchangeCount: json['exchangeCount'] as int?,
        strategy: json['strategy'] as String?,
        notes: json['notes'] as String?,
        confidence: json['confidence'] as String?,
        completeness: json['completeness'] as String?,
        limitations: json['limitations'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'parcels': parcels.map((e) => e.toJson()).toList(),
        if (tagIndex.isNotEmpty) 'tagIndex': tagIndex,
        'generatedAt': generatedAt?.toIso8601String(),
        'sourceConversationId': sourceConversationId,
        'exchangeCount': exchangeCount,
        'strategy': strategy,
        'notes': notes,
        'confidence': confidence,
        'completeness': completeness,
        'limitations': limitations,
      };

  /// Adds [parcel] to the in-memory list while preserving existing entries.
  void mergeWith(ContextParcel parcel) {
    parcels.add(parcel);
  }

  /// Converts all parcels into a single concatenated [InjectableContext].
  InjectableContext toInjectable({String? role}) {
    final summaries = parcels.map((p) => p.summary).join('\n\n');
    return InjectableContext(summary: summaries, role: role);
  }
}
