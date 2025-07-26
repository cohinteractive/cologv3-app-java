import 'package:flutter/material.dart';

import '../models/context_memory.dart';

class ContextMergeReviewDialog extends StatelessWidget {
  final int iteration;
  final ContextMemory memory;
  final int memoryCharCount;
  final int promptTokens;
  final int completionTokens;
  final String model;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  const ContextMergeReviewDialog({
    required this.iteration,
    required this.memory,
    required this.memoryCharCount,
    required this.promptTokens,
    required this.completionTokens,
    required this.model,
    required this.onContinue,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Iteration $iteration – Context Merge Review'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Model: $model'),
            Text('Prompt tokens: $promptTokens'),
            Text('Completion tokens: $completionTokens'),
            Text('Context memory length: $memoryCharCount chars'),
            const SizedBox(height: 12),
            Text('Merged Context Summary:'),
            const SizedBox(height: 8),
            Text(
              memory.parcels
                  .map((p) => p.summary)
                  .whereType<String>()
                  .join('\n\n'),
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
        ElevatedButton(onPressed: onContinue, child: const Text('Continue')),
      ],
    );
  }
}
