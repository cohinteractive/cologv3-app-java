import 'context_parcel.dart';
import 'merge_strategy.dart';

/*
Merge History Policy:

- Each call to `update()` pushes the current context into `history`.
- This preserves all prior full versions of merged context.
- Deltas are not currently stored separately; only full snapshots are tracked.
- Rollback and inspection of older context states is supported via `history`.
*/

class ContextMemory {
  ContextParcel? current;
  // Stores prior full ContextParcel snapshots before each update.
  // Allows rollback or inspection of previous merged states.
  final List<ContextParcel> history;
  // Previous ContextMemory snapshots for versioning support.
  final List<ContextMemory> versions;

  // Default merging strategy when none provided.
  MergeStrategy strategy;

  DateTime? lastMerged;

  ContextMemory({
    this.current,
    List<ContextParcel>? history,
    this.strategy = MergeStrategy.appendWithRefinement,
    List<ContextMemory>? versions,
    this.lastMerged,
  })  : history = history ?? [],
        versions = versions ?? [];

  void update(ContextParcel newParcel) {
    if (current != null) {
      history.add(current!);
    }
    current = newParcel;
  }

  /// Merge [other] into this memory using [strategyOverride] if provided.
  void mergeWith(ContextMemory other, {MergeStrategy? strategyOverride}) {
    final strat = strategyOverride ?? strategy;
    versions.add(clone());
    lastMerged = DateTime.now();

    final newParcels = <ContextParcel>[];
    newParcels.addAll(other.history);
    if (other.current != null) newParcels.add(other.current!);

    for (final parcel in newParcels) {
      switch (strat) {
        case MergeStrategy.appendWithRefinement:
          if (allParcels.any((p) => p.isRedundantWith(parcel))) {
            continue;
          }
          if (current != null) history.add(current!);
          current = parcel;
          break;
        case MergeStrategy.replaceOnConflict:
          bool replaced = false;
          for (var i = 0; i < history.length; i++) {
            if (history[i].isRedundantWith(parcel)) {
              history[i] = parcel;
              replaced = true;
              break;
            }
          }
          if (!replaced && current != null && current!.isRedundantWith(parcel)) {
            current = parcel;
            replaced = true;
          }
          if (!replaced) {
            if (current != null) history.add(current!);
            current = parcel;
          }
          break;
      }
    }
  }

  /// Returns all stored parcels including history and current.
  List<ContextParcel> get allParcels => [
        ...history,
        if (current != null) current!,
      ];

  /// Creates a deep copy of this memory.
  ContextMemory clone() => ContextMemory(
        current: current != null
            ? ContextParcel.fromJson(current!.toJson())
            : null,
        history:
            history.map((e) => ContextParcel.fromJson(e.toJson())).toList(),
        strategy: strategy,
        versions: versions.map((v) => v.clone()).toList(),
        lastMerged: lastMerged,
      );

  void reset() {
    current = null;
    history.clear();
    versions.clear();
    lastMerged = null;
  }

  ContextParcel? getPrevious(int stepsBack) {
    if (stepsBack < 1 || stepsBack > history.length) return null;
    return history[history.length - stepsBack];
  }

  factory ContextMemory.fromJson(Map<String, dynamic> json) => ContextMemory(
        current: json['current'] != null
            ? ContextParcel.fromJson(json['current'])
            : null,
        history: (json['history'] as List<dynamic>?)
                ?.map((e) => ContextParcel.fromJson(e))
                .toList() ??
            [],
        strategy: json['strategy'] != null
            ? MergeStrategy.values.byName(json['strategy'])
            : MergeStrategy.appendWithRefinement,
        versions: (json['versions'] as List<dynamic>?)
                ?.map((e) => ContextMemory.fromJson(e))
                .toList() ??
            [],
        lastMerged: json['lastMerged'] != null
            ? DateTime.parse(json['lastMerged'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'current': current?.toJson(),
        'history': history.map((e) => e.toJson()).toList(),
        'strategy': strategy.name,
        'versions': versions.map((e) => e.toJson()).toList(),
        'lastMerged': lastMerged?.toIso8601String(),
      };
}

/*
Example usage:

final memory = ContextMemory();
memory.update(ContextParcel(...));
print(memory.current?.summary);
*/

/*
\ud83e\uddd0 ContextMemory Example

{
  "current": { ...ContextParcel JSON... },
  "history": [
    { ...previous ContextParcel... },
    { ...older ContextParcel... }
  ],
  "strategy": "appendWithRefinement",
  "versions": [],
  "lastMerged": "2025-07-23T22:13:00Z"
}
*/
