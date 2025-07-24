import '../models/context_memory.dart';
import '../models/context_parcel.dart';
import 'context_memory_exporter.dart';
import 'export_formats.dart';

/// Exports [ContextMemory] as a Markdown conversation resume block.
class MarkdownResumeExporter implements ContextMemoryExporter {
  @override
  ExportFormat get format => ExportFormat.markdownResume;

  @override
  String export(ContextMemory memory) {
    final buffer = StringBuffer();
    final info = exportFormatInfo[format];

    buffer.writeln('#### Export Metadata');
    buffer.writeln('- Format: Markdown Resume');
    final ts = (memory.generatedAt ?? DateTime.now()).toIso8601String();
    buffer.writeln('- Generated: $ts');
    if (memory.sourceConversationId != null) {
      buffer.writeln('- Source Conversation: ${memory.sourceConversationId}');
    }
    buffer.writeln('- Purpose: ${info?.description}');
    buffer.writeln();
    for (int i = 0; i < memory.parcels.length; i++) {
      final ContextParcel parcel = memory.parcels[i];
      buffer.writeln('### Step ${i + 1}');
      buffer.writeln(parcel.summary);
      if (parcel.tags.isNotEmpty) {
        buffer.writeln('_Tags:_ ${parcel.tags.join(', ')}');
      }
      buffer.writeln();
    }
    return buffer.toString().trim();
  }
}
