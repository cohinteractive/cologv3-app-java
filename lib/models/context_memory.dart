/// Defines the final merged memory after processing a conversation.
///
/// `ContextMemory` stores the list of consolidated [ContextParcel] objects
/// produced by the merge pipeline. Optional metadata describes when and how
/// the memory was generated so it can be routed or audited by other tools.

import 'context_parcel.dart';

class ContextMemory {
  /// Ordered list of merged context parcels representing the conversation.
  final List<ContextParcel> parcels;

  /// Timestamp when this memory snapshot was generated.
  final DateTime? generatedAt;

  /// Identifier for the original conversation this memory summarizes.
  final String? sourceConversationId;

  /// Total number of exchanges that contributed to this memory.
  final int? exchangeCount;

  /// Merge strategy or version string used during generation.
  final String? strategy;

  /// Optional notes such as LLM confidence or limitations.
  final String? notes;

  ContextMemory({
    List<ContextParcel>? parcels,
    this.generatedAt,
    this.sourceConversationId,
    this.exchangeCount,
    this.strategy,
    this.notes,
  }) : parcels = parcels ?? [];

  factory ContextMemory.fromJson(Map<String, dynamic> json) => ContextMemory(
        parcels: (json['parcels'] as List<dynamic>?)
                ?.map((e) => ContextParcel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        generatedAt: json['generatedAt'] != null
            ? DateTime.parse(json['generatedAt'])
            : null,
        sourceConversationId: json['sourceConversationId'] as String?,
        exchangeCount: json['exchangeCount'] as int?,
        strategy: json['strategy'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'parcels': parcels.map((e) => e.toJson()).toList(),
        'generatedAt': generatedAt?.toIso8601String(),
        'sourceConversationId': sourceConversationId,
        'exchangeCount': exchangeCount,
        'strategy': strategy,
        'notes': notes,
      };
}
