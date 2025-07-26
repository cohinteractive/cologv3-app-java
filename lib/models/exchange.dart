class Exchange {
  final String prompt;
  final String? response;
  final DateTime? promptTimestamp;
  final DateTime? responseTimestamp;
  String? llmSummary;

  Exchange({
    required this.prompt,
    required this.promptTimestamp,
    this.response,
    this.responseTimestamp,
    this.llmSummary,
  });

  /// Returns true if both [prompt] and [response] contain non-empty text.
  bool isValid() {
    return prompt.trim().isNotEmpty && (response?.trim().isNotEmpty ?? false);
  }
}
