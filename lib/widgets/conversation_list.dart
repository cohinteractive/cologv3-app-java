import 'package:flutter/material.dart';

import '../models/conversation.dart';

class ConversationList extends StatelessWidget {
  final List<Conversation> conversations;
  final Conversation? selected;
  final ValueChanged<Conversation> onSelected;

  const ConversationList({
    super.key,
    required this.conversations,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conv = conversations[index];
        final selectedConv = conv == selected;
        return Material(
          color: selectedConv
              ? colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
          child: InkWell(
            onTap: () => onSelected(conv),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text(
                conv.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }
}
