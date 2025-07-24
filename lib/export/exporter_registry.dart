import 'context_memory_exporter.dart';
import 'export_formats.dart';
import 'markdown_resume_exporter.dart';
import 'feature_summary_exporter.dart';
import 'structured_json_exporter.dart';

/// Provides lookup of [ContextMemoryExporter] implementations by [ExportFormat].
class ExporterRegistry {
  static final Map<ExportFormat, ContextMemoryExporter> _exporters = {
    ExportFormat.markdownResume: MarkdownResumeExporter(),
    ExportFormat.featureSummary: FeatureSummaryExporter(),
    ExportFormat.structuredJson: StructuredJsonExporter(),
  };

  /// Returns the exporter registered for [format], or null if none exists.
  static ContextMemoryExporter? getExporter(ExportFormat format) {
    return _exporters[format];
  }

  /// Registers a custom [exporter], overriding any existing one for its format.
  static void registerExporter(ContextMemoryExporter exporter) {
    _exporters[exporter.format] = exporter;
  }
}
