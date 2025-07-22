import 'context_parcel.dart';

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

  ContextMemory({this.current, List<ContextParcel>? history})
      : history = history ?? [];

  void update(ContextParcel newParcel) {
    if (current != null) {
      history.add(current!);
    }
    current = newParcel;
  }

  void reset() {
    current = null;
    history.clear();
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
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'current': current?.toJson(),
        'history': history.map((e) => e.toJson()).toList(),
      };
}

/*
Example usage:

final memory = ContextMemory();
memory.update(ContextParcel(...));
print(memory.current?.summary);
*/
