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
        return _ConversationRow(
          conversation: conv,
          index: index,
          selected: conv == selected,
          onSelected: () => onSelected(conv),
        );
      },
    );
  }
}

class _ConversationRow extends StatefulWidget {
  final Conversation conversation;
  final int index;
  final bool selected;
  final VoidCallback onSelected;

  const _ConversationRow({
    required this.conversation,
    required this.index,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_ConversationRow> createState() => _ConversationRowState();
}

class _ConversationRowState extends State<_ConversationRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final metaStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Colors.grey.shade400);

    final lastUpdated = _lastUpdate(widget.conversation);
    final metaText =
        '${widget.conversation.exchanges.length} exchanges • Last updated $lastUpdated';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: widget.selected
            ? colorScheme.primary.withOpacity(0.2)
            : Colors.transparent,
        child: InkWell(
          onTap: widget.onSelected,
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
                  child: Text('${widget.index + 1}',
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
                        widget.conversation.title,
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
                AnimatedOpacity(
                  opacity: _hover ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    color: Theme.of(context).colorScheme.surface,
                    onSelected: (value) {
                      if (value == 'about') {
                        _showAboutDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'about',
                        child: Text('About'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showAboutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('About'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Name: Colog V3'),
            Text('Version: 0.1.0'),
            Text('Author: Charles Clark'),
            Text('© 2025'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

String _lastUpdate(Conversation c) {
  DateTime? ts;
  for (final ex in c.exchanges) {
    ts = ex.responseTimestamp ?? ex.promptTimestamp ?? ts;
  }
  ts ??= c.timestamp;
  return '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')}';
}
