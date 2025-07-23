import 'package:test/test.dart';
import '../lib/models/context_memory.dart';
import '../lib/models/context_parcel.dart';
import '../lib/models/merge_strategy.dart';

void main() {
  group('ContextMemory merge', () {
    test('appendWithRefinement adds non redundant parcels', () {
      final a = ContextParcel(summary: 'Init', mergeHistory: [1]);
      final b = ContextParcel(summary: 'Init', mergeHistory: [2]);
      final mem1 = ContextMemory(current: a);
      final mem2 = ContextMemory(current: b);
      mem1.mergeWith(mem2);
      expect(mem1.history.isNotEmpty, true);
    });

    test('replaceOnConflict overwrites matching parcel', () {
      final a = ContextParcel(summary: 'Init', mergeHistory: [1]);
      final b = ContextParcel(summary: 'Init refined', mergeHistory: [2]);
      final mem1 = ContextMemory(current: a);
      final mem2 = ContextMemory(current: b);
      mem1.mergeWith(mem2, strategyOverride: MergeStrategy.replaceOnConflict);
      expect(mem1.current?.summary, 'Init refined');
    });
  });
}
