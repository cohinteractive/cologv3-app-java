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
        final metaStyle = Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.grey.shade400);

        final lastUpdated = _lastUpdate(conv);
        final metaText =
            '${conv.exchanges.length} exchanges • Last updated $lastUpdated';

        return Material(
          color: selectedConv
              ? colorScheme.primary.withOpacity(0.2)
              : Colors.transparent,
          child: InkWell(
            onTap: () => onSelected(conv),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: 24,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2), // medium-bright blue
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('${index + 1}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conv.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          metaText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: metaStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String _lastUpdate(Conversation c) {
  DateTime? ts;
  for (final ex in c.exchanges) {
    ts = ex.responseTimestamp ?? ex.promptTimestamp ?? ts;
  }
  ts ??= c.timestamp;
  return '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')}';
}
