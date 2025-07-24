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
