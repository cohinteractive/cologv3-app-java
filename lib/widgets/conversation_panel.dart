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

    final exchanges = conversation!.exchanges;
    if (exchanges.isEmpty) {
      return const Center(child: Text('No exchanges found.'));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.background,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exchanges.length,
        itemBuilder: (context, index) {
          final ex = exchanges[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ex.prompt,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (ex.response != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ex.response!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
