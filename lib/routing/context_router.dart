import '../models/context_memory.dart';
import '../models/context_parcel.dart';

/// Keys used to determine routing priority.
enum RoutingKey { feature, system, module }

/// Holds the results of routing operations.
class RoutingResult {
  final Map<String, List<ContextParcel>> byFeature;
  final Map<String, List<ContextParcel>> bySystem;
  final Map<String, List<ContextParcel>> byModule;
  final Map<String, List<ContextParcel>> byPriority;
  final List<ContextParcel> unassigned;

  RoutingResult({
    required this.byFeature,
    required this.bySystem,
    required this.byModule,
    required this.byPriority,
    required this.unassigned,
  });
}

/// Groups ContextParcels or ContextMemory objects by metadata fields.
class ContextRouter {
  final List<RoutingKey> priority;

  ContextRouter({List<RoutingKey>? priority})
      : priority = priority ??
            const [RoutingKey.module, RoutingKey.feature, RoutingKey.system];

  /// Routes [parcels] according to the configured [priority]. Returns maps of
  /// parcels grouped by feature, system, module, and the chosen priority order.
  RoutingResult routeParcels(List<ContextParcel> parcels) {
    final byFeature = <String, List<ContextParcel>>{};
    final bySystem = <String, List<ContextParcel>>{};
    final byModule = <String, List<ContextParcel>>{};
    final byPriority = <String, List<ContextParcel>>{};
    final unassigned = <ContextParcel>[];

    for (final parcel in parcels) {
      // Record all groupings regardless of priority
      if (parcel.feature != null && parcel.feature!.trim().isNotEmpty) {
        byFeature.putIfAbsent(parcel.feature!, () => []).add(parcel);
      }
      if (parcel.system != null && parcel.system!.trim().isNotEmpty) {
        bySystem.putIfAbsent(parcel.system!, () => []).add(parcel);
      }
      if (parcel.module != null && parcel.module!.trim().isNotEmpty) {
        byModule.putIfAbsent(parcel.module!, () => []).add(parcel);
      }

      // Route to a single priority bucket
      String? key;
      for (final field in priority) {
        key = _valueFor(field, parcel);
        if (key != null && key.trim().isNotEmpty) {
          break;
        }
      }
      if (key == null || key.trim().isEmpty) {
        unassigned.add(parcel);
      } else {
        byPriority.putIfAbsent(key, () => []).add(parcel);
      }
    }

    return RoutingResult(
      byFeature: byFeature,
      bySystem: bySystem,
      byModule: byModule,
      byPriority: byPriority,
      unassigned: unassigned,
    );
  }

  /// Routes all parcels contained in [memories].
  RoutingResult routeMemories(List<ContextMemory> memories) {
    final parcels = memories.expand((m) => m.parcels).toList();
    return routeParcels(parcels);
  }

  String? _valueFor(RoutingKey key, ContextParcel parcel) {
    switch (key) {
      case RoutingKey.feature:
        return parcel.feature;
      case RoutingKey.system:
        return parcel.system;
      case RoutingKey.module:
        return parcel.module;
    }
  }
}

