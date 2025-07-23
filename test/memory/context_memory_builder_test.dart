import 'package:test/test.dart';

import '../../lib/models/context_parcel.dart';
import '../../lib/services/context_memory_builder.dart';

void main() {
  group('ContextMemoryBuilder', () {
    test('builds memory with history and metadata', () {
      final latest = ContextParcel(summary: 'final', mergeHistory: [0, 1]);
      final prev = ContextParcel(summary: 'prev', mergeHistory: [0]);
      final ts = DateTime.parse('2025-07-24T00:00:00Z');
      final memory = ContextMemoryBuilder.buildFinalMemory(
        latest: latest,
        history: [prev],
        sourceConversationId: 'c1',
        generatedAt: ts,
        totalExchangeCount: 2,
        mergeStrategy: 'default',
        notes: 'n',
      );
      expect(memory.parcels.length, 2);
      expect(memory.parcels.first.summary, 'prev');
      expect(memory.parcels.last.summary, 'final');
      expect(memory.sourceConversationId, 'c1');
      expect(memory.exchangeCount, 2);
      expect(memory.strategy, 'default');
      expect(memory.notes, 'n');
      expect(memory.generatedAt, ts);
    });

    test('infers generatedAt and exchangeCount', () {
      final latest = ContextParcel(summary: 'end', mergeHistory: [0, 1, 2]);
      final memory = ContextMemoryBuilder.buildFinalMemory(latest: latest);
      expect(memory.parcels.length, 1);
      expect(memory.generatedAt, isNotNull);
      expect(memory.exchangeCount, 3);
    });
  });
}
