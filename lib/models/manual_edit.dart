class ManualEdit {
  final int exchangeId;
  final Map<String, dynamic> original;
  final Map<String, dynamic> edited;
  final DateTime timestamp;

  ManualEdit({
    required this.exchangeId,
    required this.original,
    required this.edited,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ManualEdit.fromJson(Map<String, dynamic> json) => ManualEdit(
        exchangeId: json['exchangeId'] as int,
        original: Map<String, dynamic>.from(json['original'] as Map),
        edited: Map<String, dynamic>.from(json['edited'] as Map),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  Map<String, dynamic> toJson() => {
        'exchangeId': exchangeId,
        'original': original,
        'edited': edited,
        'timestamp': timestamp.toIso8601String(),
      };
}
