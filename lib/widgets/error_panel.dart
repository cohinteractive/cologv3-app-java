import 'package:flutter/material.dart';

class ErrorPanel extends StatelessWidget {
  final String message;
  const ErrorPanel({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Failed to load file',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: colorScheme.error),
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 8),
            const Text('Check the file formatting or try another file.'),
          ],
        ),
      ),
    );
  }
}
