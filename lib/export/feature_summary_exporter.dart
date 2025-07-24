import '../models/context_memory.dart';
import 'context_memory_exporter.dart';
import 'export_formats.dart';

/// Exports a concise feature summary of [ContextMemory].
class FeatureSummaryExporter implements ContextMemoryExporter {
  @override
  ExportFormat get format => ExportFormat.featureSummary;

  @override
  String export(ContextMemory memory) {
    return memory.parcels.map((p) => p.summary).join('\n');
  }
}
