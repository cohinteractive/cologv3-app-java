import 'package:test/test.dart';

import '../../lib/models/context_parcel.dart';
import '../../lib/models/context_memory.dart';
import '../../lib/routing/context_router.dart';

void main() {
  group('ContextRouter', () {
    test('routes parcels by priority and groups metadata', () {
      final parcels = [
        ContextParcel(
          summary: 'a',
          mergeHistory: [0],
          feature: 'f1',
          module: 'm1',
        ),
        ContextParcel(
          summary: 'b',
          mergeHistory: [1],
          feature: 'f1',
        ),
        ContextParcel(
          summary: 'c',
          mergeHistory: [2],
          system: 's1',
        ),
        ContextParcel(
          summary: 'd',
          mergeHistory: [3],
        ),
      ];
      final router = ContextRouter(priority: [RoutingKey.module, RoutingKey.feature]);
      final result = router.routeParcels(parcels);

      expect(result.byModule['m1']!.length, 1);
      expect(result.byFeature['f1']!.length, 2);
      expect(result.bySystem['s1']!.length, 1);
      expect(result.byPriority['m1']!.first.summary, 'a');
      expect(result.byPriority['f1']!.length, 1);
      expect(result.unassigned.length, 2);
      expect(result.ambiguous.length, 1);
    });

    test('routes memories by flattening parcels', () {
      final mem1 = ContextMemory(parcels: [
        ContextParcel(summary: 'x', mergeHistory: [0], feature: 'fx'),
      ]);
      final mem2 = ContextMemory(parcels: [
        ContextParcel(summary: 'y', mergeHistory: [1]),
      ]);
      final router = ContextRouter();
      final result = router.routeMemories([mem1, mem2]);
      expect(result.byFeature['fx']!.length, 1);
      expect(result.unassigned.length, 1);
    });

    test('manual override updates routing', () {
      final parcel = ContextParcel(summary: 'x', mergeHistory: [0]);
      final router = ContextRouter();
      router.routeParcels([parcel]);
      expect(router.getUnroutedParcels().length, 1);
      router.overrideRouting(parcel, feature: 'feat');
      expect(router.getUnroutedParcels().isEmpty, isTrue);
      expect(router.getAmbiguousParcels().isEmpty, isTrue);
    });

    test('detects ambiguous parcels', () {
      final parcel = ContextParcel(
        summary: 'a',
        mergeHistory: [0],
        feature: 'f',
        module: 'm',
      );
      final router = ContextRouter();
      router.routeParcels([parcel]);
      expect(router.getAmbiguousParcels(), contains(parcel));
    });
  });
}

