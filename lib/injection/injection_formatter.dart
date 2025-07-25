import 'dart:convert';

import 'injectable_context.dart';

/// Utility to convert [InjectableContext] entries into various
/// injection-ready text formats.
class InjectionFormatter {
  /// Context entries to format.
  final List<InjectableContext> entries;

  /// Creates a formatter for [entries].
  InjectionFormatter(this.entries);

  /// Renders context using the ChatGPT-friendly format.
  ///
  /// Each entry becomes a line like:
  /// `[TAG] Summary text`
  String toChatFormat() =>
      entries.map((e) => _chatLine(e)).join('\n');

  String _chatLine(InjectableContext e) {
    final tags = e.tags.map((t) => '[${t.trim()}]').join(' ');
    final prefix = tags.isNotEmpty ? '$tags ' : '';
    return '$prefix${e.summary.trim()}';
  }

  /// Renders context in a compact comment style for Codex planning.
  ///
  /// Example: `// PLAN: Do the thing`
  String toCodexFormat() =>
      entries.map((e) => _codexLine(e)).join('\n');

  String _codexLine(InjectableContext e) {
    final tag = e.tags.isNotEmpty ? e.tags.first : 'NOTE';
    return '// $tag: ${e.summary.trim()}';
  }

  /// Renders context as JSON for external analyzers.
  ///
  /// Returns a JSON object if a single entry is provided or
  /// a JSON array for multiple entries.
  String toJsonSummary() {
    if (entries.length == 1) {
      return jsonEncode(_toMap(entries.first));
    }
    return jsonEncode(entries.map(_toMap).toList());
  }

  Map<String, dynamic> _toMap(InjectableContext e) {
    return {
      'tag': e.tags.isNotEmpty ? e.tags.first : null,
      'summary': e.summary.trim(),
      if (e.timestamp != null) 'timestamp': e.timestamp!.toIso8601String(),
      if (e.role != null) 'role': e.role,
      if (e.feature != null) 'feature': e.feature,
      if (e.system != null) 'system': e.system,
      if (e.module != null) 'module': e.module,
    }..removeWhere((key, value) => value == null);
  }
}
