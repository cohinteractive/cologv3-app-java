import 'package:test/test.dart';

import '../../lib/models/context_parcel.dart';
import '../../lib/models/manual_edit.dart';
import '../../lib/services/context_memory_builder.dart';

void main() {
  group('ContextMemoryBuilder', () {
    test('builds memory with history and metadata', () {
      final latest = ContextParcel(
        summary: 'final',
        mergeHistory: [0, 1],
        feature: 'search',
        system: 'parser',
        module: 'ContextRouter',
      );
      final prev = ContextParcel(
        summary: 'prev',
        mergeHistory: [0],
        feature: 'search',
        system: 'parser',
        module: 'ContextRouter',
      );
      final ts = DateTime.parse('2025-07-24T00:00:00Z');
      final memory = ContextMemoryBuilder.buildFinalMemory(
        latest: latest,
        history: [prev],
        sourceConversationId: 'c1',
        generatedAt: ts,
        totalExchangeCount: 2,
        mergeStrategy: 'default',
        notes: 'n',
        confidence: '0.9',
        completeness: 'complete',
        limitations: 'none',
      );
      expect(memory.parcels.length, 2);
      expect(memory.parcels.first.summary, 'prev');
      expect(memory.parcels.last.summary, 'final');
      expect(memory.parcels.first.feature, 'search');
      expect(memory.parcels.first.system, 'parser');
      expect(memory.parcels.first.module, 'ContextRouter');
      expect(memory.sourceConversationId, 'c1');
      expect(memory.exchangeCount, 2);
      expect(memory.strategy, 'default');
      expect(memory.notes, 'n');
      expect(memory.confidence, '0.9');
      expect(memory.completeness, 'complete');
      expect(memory.limitations, 'none');
      expect(memory.generatedAt, ts);
      expect(memory.tagIndex.isEmpty, isTrue);
    });

    test('preserves manual edits in final memory', () {
      final edit = ManualEdit(
        exchangeId: 1,
        original: {'summary': 'initial'},
        edited: {'summary': 'edited'},
        timestamp: DateTime.parse('2025-07-24T01:00:00Z'),
      );
      final latest = ContextParcel(
        summary: 'edited',
        mergeHistory: [1],
        manualEdits: [edit],
      );
      final memory = ContextMemoryBuilder.buildFinalMemory(latest: latest);
      expect(memory.parcels.first.manualEdits.length, 1);
      expect(memory.parcels.first.manualEdits.first.exchangeId, 1);
      expect(memory.tagIndex.isEmpty, isTrue);
    });

    test('infers generatedAt and exchangeCount', () {
      final latest = ContextParcel(summary: 'end', mergeHistory: [0, 1, 2]);
      final memory = ContextMemoryBuilder.buildFinalMemory(latest: latest);
      expect(memory.parcels.length, 1);
      expect(memory.generatedAt, isNotNull);
      expect(memory.exchangeCount, 3);
      expect(memory.tagIndex.isEmpty, isTrue);
    });
  });
}
