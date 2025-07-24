import 'dart:convert';

import '../models/context_memory.dart';
import 'context_memory_exporter.dart';
import 'export_formats.dart';

/// Exports [ContextMemory] as structured JSON.
class StructuredJsonExporter implements ContextMemoryExporter {
  @override
  ExportFormat get format => ExportFormat.structuredJson;

  @override
  String export(ContextMemory memory) {
    return jsonEncode(memory.toJson());
  }
}
