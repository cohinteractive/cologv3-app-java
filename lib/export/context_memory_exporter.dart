import '../models/context_memory.dart';
import 'export_formats.dart';

/// Base class for modules that convert a [ContextMemory] into
/// a specific output format.
abstract class ContextMemoryExporter {
  /// The [ExportFormat] supported by this exporter.
  ExportFormat get format;

  /// Returns a string representation of [memory] in the
  /// desired output format.
  String export(ContextMemory memory);
}
