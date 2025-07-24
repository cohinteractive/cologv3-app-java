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
    final info = exportFormatInfo[format];
    final data = Map<String, dynamic>.from(memory.toJson());
    data['_meta'] = {
      'format': 'structuredJson',
      'generatedAt': (memory.generatedAt ?? DateTime.now()).toIso8601String(),
      'sourceConversationId': memory.sourceConversationId,
      'description': info?.description,
    };
    return jsonEncode(data);
  }
}
