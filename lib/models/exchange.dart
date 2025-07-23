class Exchange {
  final String prompt;
  final String? response;
  final DateTime? promptTimestamp;
  final DateTime? responseTimestamp;

  Exchange({
    required this.prompt,
    required this.promptTimestamp,
    this.response,
    this.responseTimestamp,
  });

  /// Returns true if both [prompt] and [response] contain non-empty text.
  bool isValid() {
    return prompt.trim().isNotEmpty && (response?.trim().isNotEmpty ?? false);
  }
}
