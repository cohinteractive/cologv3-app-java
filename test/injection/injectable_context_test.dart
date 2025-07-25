import 'package:test/test.dart';

import '../../lib/injection/injectable_context.dart';
import '../../lib/models/context_parcel.dart';

void main() {
  group('InjectableContext', () {
    test('fromParcel copies basic fields', () {
      final parcel = ContextParcel(
        summary: 'Fixed bug',
        mergeHistory: [0],
        tags: ['bug'],
        feature: 'search',
        system: 'parser',
        module: 'context',
      );
      final ctx = InjectableContext.fromParcel(
        parcel,
        role: 'assistant',
        timestamp: DateTime.parse('2025-07-24T00:00:00Z'),
      );
      expect(ctx.summary, 'Fixed bug');
      expect(ctx.tags, ['bug']);
      expect(ctx.feature, 'search');
      expect(ctx.system, 'parser');
      expect(ctx.module, 'context');
      expect(ctx.role, 'assistant');
      expect(ctx.timestamp, DateTime.parse('2025-07-24T00:00:00Z'));
    });

    test('toInjectionString renders compact output', () {
      final ctx = InjectableContext(
        summary: 'Add search bar',
        tags: ['ui', 'feature'],
        role: 'user',
        timestamp: DateTime.parse('2025-07-24T01:00:00Z'),
      );
      final str = ctx.toInjectionString();
      expect(str, '2025-07-24T01:00:00Z [user] Add search bar {ui, feature}');
    });

    test('concatenate joins multiple entries', () {
      final a = InjectableContext(summary: 'A');
      final b = InjectableContext(summary: 'B');
      final joined = InjectableContext.concatenate([a, b]);
      expect(joined, 'A\nB');
    });
  });
}
