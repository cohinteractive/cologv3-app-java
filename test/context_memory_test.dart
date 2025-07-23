import 'package:test/test.dart';
import '../lib/models/context_memory.dart';
import '../lib/models/context_parcel.dart';

void main() {
  group('ContextMemory serialization', () {
    test('toJson and fromJson preserve data', () {
      final memory = ContextMemory(
        parcels: [
          ContextParcel(summary: 'a', mergeHistory: [1]),
          ContextParcel(summary: 'b', mergeHistory: [2]),
        ],
        generatedAt: DateTime.parse('2025-07-23T00:00:00Z'),
        sourceConversationId: 'conv1',
        exchangeCount: 2,
        strategy: 'test',
        notes: 'n',
      );
      final json = memory.toJson();
      final roundTrip = ContextMemory.fromJson(json);
      expect(roundTrip.parcels.length, 2);
      expect(roundTrip.sourceConversationId, 'conv1');
      expect(roundTrip.exchangeCount, 2);
      expect(roundTrip.strategy, 'test');
      expect(roundTrip.notes, 'n');
      expect(roundTrip.generatedAt, DateTime.parse('2025-07-23T00:00:00Z'));
    });
  });
}
