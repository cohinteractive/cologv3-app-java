import 'package:flutter/material.dart';

import '../models/conversation.dart';

class ConversationPanel extends StatelessWidget {
  final Conversation? conversation;
  const ConversationPanel({super.key, this.conversation});

  @override
  Widget build(BuildContext context) {
    if (conversation == null) {
      return const Center(child: Text('No conversation selected'));
    }

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          'ConversationPanel Loaded: ${conversation!.exchanges.length} exchanges',
        ),
      ),
    );
  }
}
