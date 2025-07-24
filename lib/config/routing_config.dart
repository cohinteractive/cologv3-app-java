import "../export/export_formats.dart";
import "../routing/context_memory_router.dart";

class RoutingConfig {
  final List<ExportFormat> formats;
  final Set<OutputDestination> destinations;

  RoutingConfig({
    required this.formats,
    required this.destinations,
  });

  factory RoutingConfig.fromJson(Map<String, dynamic> json) {
    final formats = (json['formats'] as List<dynamic>? ?? [])
        .map((e) => ExportFormat.values
            .firstWhere((f) => f.name == e, orElse: () => ExportFormat.values.first))
        .toList();
    final destinations = (json['destinations'] as List<dynamic>? ?? [])
        .map((e) => OutputDestination.values
            .firstWhere((d) => d.name == e, orElse: () => OutputDestination.fileSystem))
        .toSet();
    return RoutingConfig(formats: formats, destinations: destinations);
  }

  Map<String, dynamic> toJson() => {
        'formats': formats.map((e) => e.name).toList(),
        'destinations': destinations.map((e) => e.name).toList(),
      };
}
