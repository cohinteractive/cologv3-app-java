import 'dart:convert';

import '../models/context_parcel.dart';

/// Represents the difference between two [ContextParcel] states.
class ContextDelta {
  final Map<String, dynamic> added;
  final Map<String, dynamic> removed;
  final Map<String, dynamic> changed;

  ContextDelta({required this.added, required this.removed, required this.changed});

  /// Computes the diff from [oldParcel] to [newParcel].
  static ContextDelta compute(ContextParcel oldParcel, ContextParcel newParcel) {
    final oldMap = oldParcel.toJson();
    final newMap = newParcel.toJson();
    final added = <String, dynamic>{};
    final removed = <String, dynamic>{};
    final changed = <String, dynamic>{};

    for (final key in oldMap.keys) {
      if (!newMap.containsKey(key)) {
        removed[key] = oldMap[key];
      } else if (!_deepEqual(oldMap[key], newMap[key])) {
        changed[key] = {'from': oldMap[key], 'to': newMap[key]};
      }
    }
    for (final key in newMap.keys) {
      if (!oldMap.containsKey(key)) {
        added[key] = newMap[key];
      }
    }

    return ContextDelta(added: added, removed: removed, changed: changed);
  }

  Map<String, dynamic> toJson() => {
        'added': added,
        'removed': removed,
        'changed': changed,
      };

  static bool _deepEqual(dynamic a, dynamic b) {
    return jsonEncode(a) == jsonEncode(b);
  }
}
