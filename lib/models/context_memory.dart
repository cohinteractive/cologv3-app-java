/// Defines the final merged memory after processing a conversation.
///
/// `ContextMemory` stores the list of consolidated [ContextParcel] objects
/// produced by the merge pipeline. Optional metadata describes when and how
/// the memory was generated so it can be routed or audited by other tools.

import 'context_parcel.dart';

class ContextMemory {
  /// Ordered list of merged context parcels representing the conversation.
  final List<ContextParcel> parcels;

  /// Time the memory was generated, if known.
  final DateTime? generatedAt;

  /// Identifier for the source conversation.
  final String? conversationId;

  /// Total number of Exchanges that were processed.
  final int? exchangeCount;

  /// Merge strategy or version string used during generation.
  final String? strategy;

  /// Optional notes such as LLM confidence or limitations.
  final String? notes;

  ContextMemory({
    List<ContextParcel>? parcels,
    this.generatedAt,
    this.conversationId,
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
        conversationId: json['conversationId'] as String?,
        exchangeCount: json['exchangeCount'] as int?,
        strategy: json['strategy'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'parcels': parcels.map((e) => e.toJson()).toList(),
        'generatedAt': generatedAt?.toIso8601String(),
        'conversationId': conversationId,
        'exchangeCount': exchangeCount,
        'strategy': strategy,
        'notes': notes,
      };
}
