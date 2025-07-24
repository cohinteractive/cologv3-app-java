import '../models/context_memory.dart';
import 'context_memory_exporter.dart';
import 'export_formats.dart';

/// Exports a concise feature summary of [ContextMemory].
class FeatureSummaryExporter implements ContextMemoryExporter {
  @override
  ExportFormat get format => ExportFormat.featureSummary;

  @override
  String export(ContextMemory memory) {
    final info = exportFormatInfo[format];
    final buffer = StringBuffer();

    buffer.writeln('Export Metadata:');
    buffer.writeln('- Format: Feature Summary');
    final ts = (memory.generatedAt ?? DateTime.now()).toIso8601String();
    buffer.writeln('- Generated: $ts');
    if (memory.sourceConversationId != null) {
      buffer.writeln('- Source Conversation: ${memory.sourceConversationId}');
    }
    buffer.writeln('- Purpose: ${info?.description}');
    buffer.writeln();

    buffer.writeAll(memory.parcels.map((p) => p.summary), '\n');
    return buffer.toString().trim();
  }
}
