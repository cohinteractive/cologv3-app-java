import 'dart:io';

import '../config/app_config.dart';
import '../models/context_memory.dart';
import '../export/context_memory_exporter.dart';
import '../export/export_formats.dart';
import '../export/exporter_registry.dart';
import '../config/routing_config.dart';

/// Possible destinations for exported [ContextMemory].
enum OutputDestination {
  /// Save exported data to local files.
  fileSystem,

  /// Placeholder for a log summary viewer.
  logViewer,

  /// Placeholder for documentation generation pipeline.
  docGenerator,

  /// Placeholder for error or fix pattern archive routing.
  fixArchive,
}

/// Routes [ContextMemory] exports to configured destinations.
class ContextMemoryRouter {
  const ContextMemoryRouter();

  /// Exports [memory] using the formats and destinations defined in [config].
  Future<void> route(ContextMemory memory, RoutingConfig config) async {
    final formats = config.formats;
    final destinations = config.destinations;
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
            _logViewerStub();
            break;
          case OutputDestination.docGenerator:
            // TODO: integrate with documentation generator
            break;
          case OutputDestination.fixArchive:
            if (_hasFixTags(memory)) {
              _fixArchiveStub();
            }
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

  void _logViewerStub() {
    print('LogViewer: output routing not yet implemented');
  }

  void _fixArchiveStub() {
    print('FixArchive: output routing not yet implemented');
  }

  bool _hasFixTags(ContextMemory memory) {
    for (final parcel in memory.parcels) {
      for (final tag in parcel.tags) {
        final lower = tag.toLowerCase();
        if (lower.contains('fix') || lower.contains('error') || lower.contains('bug')) {
          return true;
        }
      }
    }
    return false;
  }
}

