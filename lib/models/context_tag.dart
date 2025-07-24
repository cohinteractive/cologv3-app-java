/// Defines supported inline tags for ContextParcel summaries.
///
/// Tags label specific parts of the conversation memory so other
/// tools can filter or highlight them.

enum ContextTag {
  /// Captures important project or architectural decisions.
  decision('DECISION', 'Captures important project or architectural decisions'),

  /// Describes the nature of a bug fix or its discussion.
  bugFix('BUG_FIX', 'Describes the nature of a fix or its discussion'),

  /// Denotes architectural commentary or notes.
  archNote('ARCH_NOTE', 'Denotes architectural commentary'),

  /// Marks a question raised in the conversation.
  question('QUESTION', 'Marks a question raised in the conversation'),

  /// Marks an explicit answer or solution provided.
  answer('ANSWER', 'Marks an explicit answer or solution provided'),

  /// Outlines a plan or next steps.
  plan('PLAN', 'Outlines a plan or next steps'),

  /// Indicates something blocking progress.
  blocker('BLOCKER', 'Indicates something blocking progress');

  /// Raw label used inside brackets, e.g. `[DECISION]`.
  final String label;

  /// Human-readable description of the tag purpose.
  final String description;

  const ContextTag(this.label, this.description);

  /// Returns the bracketed representation, e.g. `[DECISION]`.
  String get bracketed => '[$label]';

  static final RegExp _inlinePattern = RegExp(r'^\[([A-Z_]+)\]');

  /// Parses the tag at the beginning of [line]. Returns `null` if not found
  /// or if the tag name is unrecognized.
  static ContextTag? fromLine(String line) {
    final match = _inlinePattern.firstMatch(line.trim());
    if (match == null) return null;
    final name = match.group(1);
    for (final tag in ContextTag.values) {
      if (tag.label == name) return tag;
    }
    return null;
  }

  /// Returns the tag matching [label], or `null` if unrecognized.
  static ContextTag? fromLabel(String label) {
    for (final tag in ContextTag.values) {
      if (tag.label == label) return tag;
    }
    return null;
  }

  /// Returns `true` if [line] begins with a recognized context tag.
  static bool isValidTaggedLine(String line) => fromLine(line) != null;

  /// Returns `true` if [name] matches one of the supported tag labels.
  static bool isValidTagName(String name) {
    for (final tag in ContextTag.values) {
      if (tag.label == name) return true;
    }
    return false;
  }
}
