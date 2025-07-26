import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/context_memory.dart';

class ContextMergeCompleteDialog extends StatelessWidget {
  final ContextMemory memory;

  const ContextMergeCompleteDialog({required this.memory, super.key});

  @override
  Widget build(BuildContext context) {
    final summaryText =
        memory.parcels.map((p) => p.summary).whereType<String>().join('\n\n');

    return AlertDialog(
      title: const Text('Merge Completed'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Merged Context Summary:'),
            const SizedBox(height: 8),
            Text(
              summaryText.isEmpty ? '(no content)' : summaryText,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: summaryText));
            Navigator.of(context).pop();
          },
          child: const Text('Copy Summary'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
