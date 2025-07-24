/// Supported export output formats for ContextMemory views.
///
/// These formats allow the conversation context to be re-used
/// in documentation, summaries, or downstream tooling.
/// Each enum value includes documentation on its intended use,
/// target audience, and output characteristics.

enum ExportFormat {
  /// High-fidelity conversation resume in Markdown.
  ///
  /// * **Intended use:** recreate the original conversation
  ///   with minimal loss of detail when resuming work.
  /// * **Target audience:** developers and reviewers who
  ///   need the full dialogue for reference.
  /// * **Output characteristics:** formatted Markdown with
  ///   headings, timestamps, and verbatim prompts/responses.
  markdownResume,

  /// Concise design or feature summary in plain text.
  ///
  /// * **Intended use:** capture key decisions or features
  ///   discussed during the conversation.
  /// * **Target audience:** project managers or team members
  ///   seeking a quick overview without full transcripts.
  /// * **Output characteristics:** paragraph style text
  ///   summarizing main ideas and follow-up actions.
  featureSummary,

  /// Machine-readable JSON representation.
  ///
  /// * **Intended use:** feed context into automated tools
  ///   or later processing stages.
  /// * **Target audience:** scripts and services that parse
  ///   structured conversation memory.
  /// * **Output characteristics:** well-formed JSON matching
  ///   the `ContextMemory` schema.
  structuredJson,
}

/// Metadata describing additional details for each [ExportFormat].
class ExportFormatInfo {
  /// Default file extension, without leading dot.
  final String extension;

  /// Suggested filename suffix appended to a base name.
  final String suffix;

  /// One-line description of the format purpose.
  final String description;

  const ExportFormatInfo(this.extension, this.suffix, this.description);
}

/// Lookup table of export format metadata.
const Map<ExportFormat, ExportFormatInfo> exportFormatInfo = {
  ExportFormat.markdownResume:
      ExportFormatInfo('md', 'resume', 'Markdown conversation resume block'),
  ExportFormat.featureSummary:
      ExportFormatInfo('txt', 'summary', 'Human-readable feature summary'),
  ExportFormat.structuredJson:
      ExportFormatInfo('json', 'memory', 'Structured JSON memory output'),
};
