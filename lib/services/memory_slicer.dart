import '../models/context_memory.dart';
import '../models/context_parcel.dart';
import '../injection/injectable_context.dart';

/// Utility for extracting subsets of context memory.
class MemorySlicer {
  /// List of parcels being operated on.
  final List<ContextParcel> _parcels;

  /// Creates a slicer for [parcels].
  MemorySlicer(List<ContextParcel> parcels)
      : _parcels = List<ContextParcel>.from(parcels);

  /// Creates a slicer from [memory].
  factory MemorySlicer.fromMemory(ContextMemory memory) =>
      MemorySlicer(memory.parcels);

  MemorySlicer._internal(this._parcels);

  /// Returns parcels containing [tag] either in the `tags` list or as an inline tag.
  List<ContextParcel> sliceByTag(String tag) {
    final lower = tag.toLowerCase();
    return _parcels.where((p) {
      final tagMatch = p.tags.any((t) => t.toLowerCase() == lower);
      final inlineMatch =
          p.inlineTags.any((t) => t.label.toLowerCase() == lower);
      return tagMatch || inlineMatch;
    }).toList();
  }

  /// Returns parcels whose summary contains [keyword] (case-insensitive).
  List<ContextParcel> sliceByTopic(String keyword) {
    final lower = keyword.toLowerCase();
    return _parcels
        .where((p) => p.summary.toLowerCase().contains(lower))
        .toList();
  }

  /// Returns the last [count] parcels.
  List<ContextParcel> sliceRecent(int count) {
    if (count <= 0) return [];
    return _parcels.sublist(_parcels.length - count.clamp(0, _parcels.length));
  }

  /// Filters by [tag] and returns a new slicer for chaining.
  MemorySlicer byTag(String tag) => MemorySlicer._internal(sliceByTag(tag));

  /// Filters by [keyword] and returns a new slicer for chaining.
  MemorySlicer byTopic(String keyword) =>
      MemorySlicer._internal(sliceByTopic(keyword));

  /// Returns a new slicer containing only the last [count] parcels.
  MemorySlicer recent(int count) => MemorySlicer._internal(sliceRecent(count));

  /// Returns the current parcel list.
  List<ContextParcel> toList() => List.unmodifiable(_parcels);

  /// Returns the parcels as [InjectableContext] entries.
  List<InjectableContext> toInjectable({String? role}) => _parcels
      .map((p) => InjectableContext.fromParcel(p, role: role))
      .toList();
}

