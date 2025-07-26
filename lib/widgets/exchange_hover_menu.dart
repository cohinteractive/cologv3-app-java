import 'package:flutter/material.dart';

import '../models/exchange.dart';

class ExchangeHoverMenu extends StatelessWidget {
  final Exchange exchange;
  final void Function(Exchange) onSummarizeRequested;
  final void Function(Exchange)? onSummarizeFromHereRequested;
  const ExchangeHoverMenu({
    super.key,
    required this.exchange,
    required this.onSummarizeRequested,
    this.onSummarizeFromHereRequested,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      color: Theme.of(context).colorScheme.surface,
      onSelected: (value) {
        switch (value) {
          case 'summarize':
            onSummarizeRequested(exchange);
            break;
          case 'summarize_from_here':
            if (onSummarizeFromHereRequested != null) {
              onSummarizeFromHereRequested!(exchange);
            }
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'summarize',
          child: Text('Summarize with LLM'),
        ),
        PopupMenuItem(
          value: 'summarize_from_here',
          child: Text('Summarize From This Point Forward'),
        ),
      ],
    );
  }
}
