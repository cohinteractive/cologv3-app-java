class ContextDelta {
  final String changeType; // e.g., "addition", "removal", "modification"
  final String field; // e.g., "summary", "tags", "assumptions"
  final dynamic previousValue;
  final dynamic newValue;
  final DateTime timestamp;

  ContextDelta({
    required this.changeType,
    required this.field,
    this.previousValue,
    this.newValue,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ContextDelta.fromJson(Map<String, dynamic> json) => ContextDelta(
        changeType: json['changeType'],
        field: json['field'],
        previousValue: json['previousValue'],
        newValue: json['newValue'],
        timestamp: DateTime.parse(json['timestamp']),
      );

  Map<String, dynamic> toJson() => {
        'changeType': changeType,
        'field': field,
        'previousValue': previousValue,
        'newValue': newValue,
        'timestamp': timestamp.toIso8601String(),
      };
}

/*
Example:

ContextDelta(
  changeType: "modification",
  field: "summary",
  previousValue: "Initial bug summary",
  newValue: "Expanded bug summary with fix details",
);
*/

