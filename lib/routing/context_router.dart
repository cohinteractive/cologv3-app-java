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
  final List<ContextParcel> ambiguous;

  RoutingResult({
    required this.byFeature,
    required this.bySystem,
    required this.byModule,
    required this.byPriority,
    required this.unassigned,
    required this.ambiguous,
  });
}

/// Groups ContextParcels or ContextMemory objects by metadata fields.
class ContextRouter {
  final List<RoutingKey> priority;
  List<ContextParcel> _lastParcels = [];
  RoutingResult? _lastResult;

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
    final ambiguous = <ContextParcel>[];

    _lastParcels = List<ContextParcel>.from(parcels);
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

      final hasFeature = parcel.feature != null && parcel.feature!.trim().isNotEmpty;
      final hasSystem = parcel.system != null && parcel.system!.trim().isNotEmpty;
      final hasModule = parcel.module != null && parcel.module!.trim().isNotEmpty;
      final fieldCount = [hasFeature, hasSystem, hasModule].where((e) => e).length;
      if (fieldCount == 0) {
        unassigned.add(parcel);
      } else if (fieldCount > 1) {
        ambiguous.add(parcel);
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
        if (!unassigned.contains(parcel)) {
          unassigned.add(parcel);
        }
      } else {
        byPriority.putIfAbsent(key, () => []).add(parcel);
      }
    }

    _lastResult = RoutingResult(
      byFeature: byFeature,
      bySystem: bySystem,
      byModule: byModule,
      byPriority: byPriority,
      unassigned: unassigned,
      ambiguous: ambiguous,
    );
    return _lastResult!;
  }

  /// Routes all parcels contained in [memories].
  RoutingResult routeMemories(List<ContextMemory> memories) {
    final parcels = memories.expand((m) => m.parcels).toList();
    return routeParcels(parcels);
  }

  List<ContextParcel> getUnroutedParcels() =>
      List.unmodifiable(_lastResult?.unassigned ?? []);

  List<ContextParcel> getAmbiguousParcels() =>
      List.unmodifiable(_lastResult?.ambiguous ?? []);

  RoutingResult overrideRouting(
    ContextParcel parcel, {
    String? feature,
    String? system,
    String? module,
  }) {
    final updated = ContextParcel(
      summary: parcel.summary,
      mergeHistory: parcel.mergeHistory,
      tags: parcel.tags,
      assumptions: parcel.assumptions,
      confidence: parcel.confidence,
      manualEdits: parcel.manualEdits,
      feature: feature ?? parcel.feature,
      system: system ?? parcel.system,
      module: module ?? parcel.module,
    );
    for (var i = 0; i < _lastParcels.length; i++) {
      if (identical(_lastParcels[i], parcel)) {
        _lastParcels[i] = updated;
        break;
      }
    }
    _lastResult = routeParcels(_lastParcels);
    return _lastResult!;
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

