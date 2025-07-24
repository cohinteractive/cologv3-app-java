import 'dart:io';

import '../models/context_parcel.dart';
import '../routing/context_router.dart';

/// Utility that writes routed [ContextParcel]s to a structured folder layout.
///
/// Output structure:
/// ```
/// <base>/by_feature/<feature_name>/context.md
/// <base>/by_module/<module_name>/context.md
/// ```
class RoutedContextExporter {
  final String basePath;

  RoutedContextExporter({this.basePath = 'export/context'});

  /// Writes [result] groups to the filesystem.
  Future<void> export(RoutingResult result, {bool includeUnassigned = false}) async {
    await _writeGroups(result.byFeature, 'by_feature');
    await _writeGroups(result.byModule, 'by_module');
    if (includeUnassigned) {
      await _writeGroups({'unassigned': result.unassigned}, 'misc');
    }
  }

  Future<void> _writeGroups(Map<String, List<ContextParcel>> groups, String subdir) async {
    for (final entry in groups.entries) {
      if (entry.value.isEmpty) continue;
      final dirName = _sanitizeName(entry.key);
      final dir = Directory('$basePath/$subdir/$dirName');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final file = File('${dir.path}/context.md');
      final buffer = StringBuffer()
        ..writeln('# ${entry.key}')
        ..writeln();
      for (var i = 0; i < entry.value.length; i++) {
        buffer.writeln('## Entry ${i + 1}');
        buffer.writeln(_formatParcel(entry.value[i]));
        buffer.writeln();
      }
      await file.writeAsString(buffer.toString().trim());
    }
  }

  String _sanitizeName(String name) =>
      name.replaceAll(RegExp(r'[\\/\:\*\?"<>\|]'), '').replaceAll(' ', '_');

  String _formatParcel(ContextParcel parcel) {
    final buffer = StringBuffer(parcel.summary.trim());
    if (parcel.tags.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('_Tags:_ ${parcel.tags.join(', ')}');
    }
    return buffer.toString().trim();
  }
}
