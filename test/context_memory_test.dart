import 'package:test/test.dart';
import '../lib/models/context_memory.dart';
import '../lib/models/context_parcel.dart';
import '../lib/models/manual_edit.dart';

void main() {
  group('ContextMemory serialization', () {
    test('toJson and fromJson preserve data', () {
      final edit = ManualEdit(
        exchangeId: 0,
        original: {'summary': 'b'},
        edited: {'summary': 'b edited'},
        timestamp: DateTime.parse('2025-07-23T01:00:00Z'),
      );
      final memory = ContextMemory(
        parcels: [
          ContextParcel(summary: 'a', mergeHistory: [1]),
          ContextParcel(summary: 'b edited', mergeHistory: [2], manualEdits: [edit]),
        ],
        generatedAt: DateTime.parse('2025-07-23T00:00:00Z'),
        sourceConversationId: 'conv1',
        exchangeCount: 2,
        strategy: 'test',
        notes: 'n',
        confidence: '0.8',
        completeness: 'partial',
        limitations: 'some missing data',
      );
      final json = memory.toJson();
      final roundTrip = ContextMemory.fromJson(json);
      expect(roundTrip.parcels.length, 2);
      expect(roundTrip.sourceConversationId, 'conv1');
      expect(roundTrip.exchangeCount, 2);
      expect(roundTrip.strategy, 'test');
      expect(roundTrip.notes, 'n');
      expect(roundTrip.confidence, '0.8');
      expect(roundTrip.completeness, 'partial');
      expect(roundTrip.limitations, 'some missing data');
      expect(roundTrip.generatedAt, DateTime.parse('2025-07-23T00:00:00Z'));
    });
  });
}
