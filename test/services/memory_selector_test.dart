import 'package:test/test.dart';

import '../../lib/models/context_parcel.dart';
import '../../lib/models/context_memory.dart';
import '../../lib/services/memory_selector.dart';

void main() {
  group('MemorySelector', () {
    final parcels = [
      ContextParcel(summary: '[PLAN] add ui', mergeHistory: [0]),
      ContextParcel(summary: '[BUG_FIX] fix crash', mergeHistory: [1], tags: ['bug']),
      ContextParcel(summary: 'Discuss search bar', mergeHistory: [2], tags: ['feature']),
    ];
    final memory = ContextMemory(parcels: parcels);

    test('selectByTag finds tags or inline tags', () {
      final selector = MemorySelector.fromMemory(memory);
      final plan = selector.selectByTag('PLAN');
      expect(plan.length, 1);
      expect(plan.first.summary, contains('add ui'));
    });

    test('selectByKeyword matches topic', () {
      final selector = MemorySelector.fromMemory(memory);
      final search = selector.selectByKeyword('search');
      expect(search.length, 1);
      expect(search.first.summary, contains('search bar'));
    });

    test('selectRecent returns last N', () {
      final selector = MemorySelector.fromMemory(memory);
      final last = selector.selectRecent(2);
      expect(last.length, 2);
      expect(last.first.summary, contains('fix crash'));
    });

    test('selectCustom echoes provided list', () {
      final selector = MemorySelector.fromMemory(memory);
      final custom = selector.selectCustom([parcels[0], parcels[2]]);
      expect(custom.length, 2);
      expect(custom.first.summary, contains('add ui'));
    });

    test('preview handles empty lists', () {
      final selector = MemorySelector.fromMemory(memory);
      final buffer = StringBuffer();
      selector.preview([], out: buffer);
      expect(buffer.toString().trim(), '(no entries)');
    });

    test('interactiveSelect parses indices', () async {
      final selector = MemorySelector.fromMemory(memory);
      final buffer = StringBuffer();
      final result = await selector.interactiveSelect(parcels,
          readInput: () => '1,3', out: buffer);
      expect(result.length, 2);
      expect(result.first.summary, contains('add ui'));
    });
  });
}
