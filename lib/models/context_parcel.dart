class ContextParcel {
  /// Human-readable context summary for quick reference
  final String summary;

  /// IDs of exchanges that contributed to this summary
  final List<int> contributingExchangeIds;

  /// Optional manual or inferred tags (e.g. "bug", "feature")
  final List<String> tags;

  /// Optional assumptions inferred or explicitly stated
  final List<String> assumptions;

  /// Optional confidence values for parts of the summary or tags
  final Map<String, double> confidence;

  ContextParcel({
    required this.summary,
    required this.contributingExchangeIds,
    this.tags = const [],
    this.assumptions = const [],
    this.confidence = const {},
  });

  factory ContextParcel.fromJson(Map<String, dynamic> json) => ContextParcel(
        summary: json['summary'],
        contributingExchangeIds: List<int>.from(json['contributingExchangeIds']),
        tags: List<String>.from(json['tags'] ?? []),
        assumptions: List<String>.from(json['assumptions'] ?? []),
        confidence: Map<String, double>.from(json['confidence'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'contributingExchangeIds': contributingExchangeIds,
        'tags': tags,
        'assumptions': assumptions,
        'confidence': confidence,
      };
}

/*
Example:

ContextParcel(
  summary: "Discussed bug in message loader and implemented JSON streaming fix.",
  contributingExchangeIds: [101, 102, 105],
  tags: ["bug", "loader", "streaming"],
  assumptions: ["File was too large for previous parser"],
  confidence: {"summary": 0.95}
);
*/

/*
\ud83d\udce6 ContextParcel Example

{
  "summary": "Fixed null pointer in message loader",
  "contributingExchangeIds": [12, 15, 16],
  "tags": ["bug", "loader", "json"],
  "assumptions": ["Data exceeds buffer size"],
  "confidence": {
    "summary": 0.93,
    "tags": 0.8
  }
}
*/
