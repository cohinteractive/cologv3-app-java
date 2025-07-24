import 'exchange.dart';

class Conversation {
  final String title;
  final DateTime timestamp;
  final List<Exchange> exchanges;
  final List<String> tags;

  Conversation({
    required this.title,
    required this.timestamp,
    required this.exchanges,
    this.tags = const [],
  });
}
