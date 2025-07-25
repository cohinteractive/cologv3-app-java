import 'package:test/test.dart';

import '../../lib/models/context_parcel.dart';
import '../../lib/services/memory_slicer.dart';

void main() {
  group('MemorySlicer', () {
    final parcels = [
      ContextParcel(summary: '[BUG_FIX] fixed router bug', mergeHistory: [0], tags: ['bug']),
      ContextParcel(summary: '[PLAN] improve router', mergeHistory: [1]),
      ContextParcel(summary: 'Discuss search bar', mergeHistory: [2], tags: ['feature']),
    ];

    test('sliceByTag finds matching tags or inline tags', () {
      final slicer = MemorySlicer(parcels);
      final bug = slicer.sliceByTag('BUG_FIX');
      expect(bug.length, 1);
      expect(bug.first.summary, contains('router bug'));
      final plan = slicer.sliceByTag('PLAN');
      expect(plan.length, 1);
      expect(plan.first.summary, contains('improve router'));
    });

    test('sliceByTopic matches keywords', () {
      final slicer = MemorySlicer(parcels);
      final router = slicer.sliceByTopic('router');
      expect(router.length, 2);
      final search = slicer.sliceByTopic('search');
      expect(search.length, 1);
      expect(search.first.summary, contains('search bar'));
    });

    test('sliceRecent returns last N entries', () {
      final slicer = MemorySlicer(parcels);
      final last = slicer.sliceRecent(2);
      expect(last.length, 2);
      expect(last.first.summary, contains('improve router'));
    });

    test('supports chaining filters', () {
      final slicer = MemorySlicer(parcels);
      final result = slicer.byTag('PLAN').byTopic('router').toList();
      expect(result.length, 1);
      expect(result.first.summary, contains('improve router'));
    });

    test('toInjectable converts parcels', () {
      final slicer = MemorySlicer(parcels);
      final list = slicer.byTag('BUG_FIX').toInjectable(role: 'assistant');
      expect(list.length, 1);
      expect(list.first.role, 'assistant');
      expect(list.first.summary, contains('fixed router bug'));
    });

    test('handles no matches gracefully', () {
      final slicer = MemorySlicer(parcels);
      final none = slicer.sliceByTag('MISSING');
      expect(none, isEmpty);
      final noneTopic = slicer.sliceByTopic('foobar');
      expect(noneTopic, isEmpty);
      final zero = slicer.sliceRecent(0);
      expect(zero, isEmpty);
    });
  });
}
