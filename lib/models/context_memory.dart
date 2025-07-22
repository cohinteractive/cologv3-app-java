import 'context_parcel.dart';

class ContextMemory {
  ContextParcel? current;
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
