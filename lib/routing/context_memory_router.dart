import 'dart:io';

import '../config/app_config.dart';
import '../models/context_memory.dart';
import '../export/context_memory_exporter.dart';
import '../export/export_formats.dart';
import '../export/exporter_registry.dart';

/// Possible destinations for exported [ContextMemory].
enum OutputDestination {
  /// Save exported data to local files.
  fileSystem,

  /// Placeholder for a log summary viewer.
  logViewer,

  /// Placeholder for documentation generation pipeline.
  documentationGenerator,

  /// Placeholder for error or fix pattern archive routing.
  errorArchive,
}

/// Routes [ContextMemory] exports to configured destinations.
class ContextMemoryRouter {
  final List<OutputDestination> destinations;

  /// Creates a router that writes to [destinations]. If none are provided,
  /// [OutputDestination.fileSystem] is used by default.
  ContextMemoryRouter({List<OutputDestination>? destinations})
      : destinations = destinations ?? [OutputDestination.fileSystem];

  /// Exports [memory] using each of the requested [formats] and dispatches the
  /// results to all configured destinations.
  Future<void> route(ContextMemory memory, List<ExportFormat> formats) async {
    for (final format in formats) {
      final ContextMemoryExporter? exporter =
          ExporterRegistry.getExporter(format);
      if (exporter == null) continue;
      final output = exporter.export(memory);
      for (final dest in destinations) {
        switch (dest) {
          case OutputDestination.fileSystem:
            await _writeToFileSystem(output, memory, format);
            break;
          case OutputDestination.logViewer:
            // TODO: integrate with log summary viewer
            break;
          case OutputDestination.documentationGenerator:
            // TODO: integrate with documentation generator
            break;
          case OutputDestination.errorArchive:
            // TODO: integrate with error/fix archive
            break;
        }
      }
    }
  }

  Future<void> _writeToFileSystem(
      String content, ContextMemory memory, ExportFormat format) async {
    final info = exportFormatInfo[format];
    final dir = Directory(AppConfig.memoryOutputDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final ts = (memory.generatedAt ?? DateTime.now())
        .toIso8601String()
        .replaceAll(':', '-');
    final base = (memory.sourceConversationId ?? 'memory')
        .replaceAll(RegExp(r'[\\/\:]'), '_');
    final filename =
        '${base}_${info?.suffix ?? format.name}_${ts}.${info?.extension ?? 'txt'}';
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content);
  }
}

