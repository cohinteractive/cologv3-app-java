import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/conversation.dart';
import '../models/exchange.dart';

class ConversationView extends StatelessWidget {
  final List<Conversation> conversations;
  const ConversationView({super.key, required this.conversations});

  @override
  Widget build(BuildContext context) {
    final items = <_ListItem>[];
    for (final c in conversations) {
      items.add(_ListItem.conversation(c));
      for (final ex in c.exchanges) {
        items.add(_ListItem.exchange(ex));
      }
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return item.when(
          conversation: (c) => _buildConversationHeader(context, c),
          exchange: (e) => _buildExchange(context, e),
        );
      },
    );
  }

  Widget _buildConversationHeader(BuildContext context, Conversation conv) {
    final ts = DateFormat('yy/MM/dd HH:mm:ss').format(conv.timestamp);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '${conv.title} ($ts)',
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExchange(BuildContext context, Exchange ex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
          child: Text('User : ${ex.user.replaceAll("\r", "")}') ,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24.0, bottom: 4.0),
          child: Text('Agent : ${ex.agent.replaceAll("\r", "")}'),
        ),
        const Divider(height: 16),
      ],
    );
  }
}

class _ListItem {
  final Conversation? conversation;
  final Exchange? exchange;

  _ListItem.conversation(this.conversation) : exchange = null;
  _ListItem.exchange(this.exchange) : conversation = null;

  T when<T>({
    required T Function(Conversation) conversation,
    required T Function(Exchange) exchange,
  }) {
    if (this.conversation != null) return conversation(this.conversation!);
    return exchange(this.exchange!);
  }
}
