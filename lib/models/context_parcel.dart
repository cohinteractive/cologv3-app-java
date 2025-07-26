import 'manual_edit.dart';
import 'context_tag.dart';

class ContextParcel {
  /// Human-readable context summary for quick reference
  final String summary;

  /// Indices of exchanges that contributed to this summary
  final List<int> mergeHistory;

  /// Optional manual or inferred tags (e.g. "bug", "feature")
  final List<String> tags;

  /// Optional assumptions inferred or explicitly stated
  final List<String> assumptions;

  /// Optional confidence values for parts of the summary or tags
  final Map<String, double> confidence;

  /// Records any manual edits applied during merge review.
  final List<ManualEdit> manualEdits;

  /// Inline tags detected within the summary content.
  final Set<ContextTag> inlineTags;

  /// Short feature identifier this parcel relates to (e.g. "search").
  final String? feature;

  /// Optional high-level system or component name.
  final String? system;

  /// Optional file or logical module identifier.
  final String? module;

  ContextParcel({
    required this.summary,
    required this.mergeHistory,
    this.tags = const [],
    this.assumptions = const [],
    this.confidence = const {},
    this.manualEdits = const [],
    this.feature,
    this.system,
    this.module,
    Set<ContextTag>? inlineTags,
  }) : inlineTags = inlineTags ?? _extractInlineTags(summary);

  factory ContextParcel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as String? ?? '';
    print('[DEBUG] ContextParcel.fromJson: summary = "$summary"');
    Set<ContextTag>? inline;
    if (json['inlineTags'] is List) {
      inline = <ContextTag>{};
      for (final e in json['inlineTags']) {
        if (e is String) {
          final tag = ContextTag.fromLabel(e);
          if (tag != null) inline.add(tag);
        }
      }
    }
    return ContextParcel(
      summary: summary,
      mergeHistory: List<int>.from(
        json['mergeHistory'] ?? json['contributingExchangeIds'] ?? [],
      ),
      tags: List<String>.from(json['tags'] ?? []),
      assumptions: List<String>.from(json['assumptions'] ?? []),
      confidence: Map<String, double>.from(json['confidence'] ?? {}),
      manualEdits: (json['manualEdits'] as List<dynamic>? ?? [])
          .map((e) => ManualEdit.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      feature: json['feature'] as String?,
      system: json['system'] as String?,
      module: json['module'] as String?,
      inlineTags: inline ?? _extractInlineTags(summary),
    );
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'mergeHistory': mergeHistory,
        'tags': tags,
        'assumptions': assumptions,
        'confidence': confidence,
        'manualEdits': manualEdits.map((e) => e.toJson()).toList(),
        if (inlineTags.isNotEmpty)
          'inlineTags': inlineTags.map((e) => e.label).toList(),
        if (feature != null) 'feature': feature,
        if (system != null) 'system': system,
        if (module != null) 'module': module,
      };

  /// Returns true if this parcel conveys essentially the same
  /// information as [other] using simple text and tag comparisons.
  bool isRedundantWith(ContextParcel other) {
    final a = _normalize(summary);
    final b = _normalize(other.summary);
    if (a == b || a.contains(b) || b.contains(a)) return true;
    if (_levenshtein(a, b) < 10) return true;

    final tagsA = tags.map((e) => e.toLowerCase()).toSet();
    final tagsB = other.tags.map((e) => e.toLowerCase()).toSet();
    if (tagsA.isNotEmpty &&
        tagsA.length == tagsB.length &&
        tagsA.containsAll(tagsB)) {
      return true;
    }
    return false;
  }

  String _normalize(String input) =>
      input.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    final v0 = List<int>.generate(t.length + 1, (i) => i);
    final v1 = List<int>.filled(t.length + 1, 0);

    for (var i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (var j = 0; j < t.length; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      for (var j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }

  /// Scans [content] for inline tags at the start of lines.
  static Set<ContextTag> _extractInlineTags(String content) {
    final tags = <ContextTag>{};
    for (final line in content.split('\n')) {
      final tag = ContextTag.fromLine(line);
      if (tag != null) tags.add(tag);
    }
    return tags;
  }
}

/*
Example:

ContextParcel(
  summary: "Discussed bug in message loader and implemented JSON streaming fix.",
  mergeHistory: [101, 102, 105],
  tags: ["bug", "loader", "streaming"],
  assumptions: ["File was too large for previous parser"],
  confidence: {"summary": 0.95}
);
*/

/*
\ud83d\udce6 ContextParcel Example

{
  "summary": "Fixed null pointer in message loader",
  "mergeHistory": [12, 15, 16],
  "tags": ["bug", "loader", "json"],
  "assumptions": ["Data exceeds buffer size"],
  "confidence": {
    "summary": 0.93,
    "tags": 0.8
  }
}
*/
