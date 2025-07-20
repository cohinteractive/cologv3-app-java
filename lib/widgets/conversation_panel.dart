import 'package:flutter/material.dart';

import '../models/conversation.dart';

class ConversationPanel extends StatefulWidget {
  final Conversation? conversation;
  const ConversationPanel({super.key, this.conversation});

  @override
  State<ConversationPanel> createState() => _ConversationPanelState();
}

class _ConversationPanelState extends State<ConversationPanel>
    with TickerProviderStateMixin {
  final Set<int> _expanded = <int>{};

  @override
  void didUpdateWidget(covariant ConversationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversation != widget.conversation) {
      _expanded.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversation = widget.conversation;
    if (conversation == null) {
      return const Center(child: Text('No conversation selected'));
    }

    final exchanges = conversation.exchanges;
    if (exchanges.isEmpty) {
      return const Center(child: Text('No exchanges found.'));
    }

    final colorScheme = Theme.of(context).colorScheme;
    // Colors used for prompt and response containers
    const promptBg = Color(0xFF0D47A1); // dark blue
    const responseBg = Color(0xFF424242); // dark grey

    return Container(
      color: colorScheme.background,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exchanges.length,
        itemBuilder: (context, index) {
          final ex = exchanges[index];
          final expanded = _expanded.contains(index);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                setState(() {
                  if (expanded) {
                    _expanded.remove(index);
                  } else {
                    _expanded.add(index);
                  }
                });
              },
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: promptBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ex.prompt,
                        maxLines: expanded ? null : 1,
                        overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade300,
                            ),
                      ),
                    ),
                    if (ex.response != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.only(left: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: responseBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ex.response!,
                          maxLines: expanded ? null : 1,
                          overflow:
                              expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade200,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
