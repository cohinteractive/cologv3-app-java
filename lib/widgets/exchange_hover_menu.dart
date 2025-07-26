import 'package:flutter/material.dart';

import '../models/exchange.dart';

class ExchangeHoverMenu extends StatelessWidget {
  final Exchange exchange;
  final void Function(Exchange) onSummarizeRequested;
  const ExchangeHoverMenu({
    super.key,
    required this.exchange,
    required this.onSummarizeRequested,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      color: Theme.of(context).colorScheme.surface,
      onSelected: (value) {
        if (value == 'summarize') {
          onSummarizeRequested(exchange);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'summarize',
          child: Text('Summarize with LLM'),
        ),
      ],
    );
  }
}
