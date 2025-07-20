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
}
