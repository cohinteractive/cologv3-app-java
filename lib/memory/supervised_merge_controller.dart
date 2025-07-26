import 'dart:convert';

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/context_memory.dart';
import '../models/context_parcel.dart';
import '../models/exchange.dart';
import '../models/llm_merge_strategy.dart';
import '../services/context_memory_builder.dart';
import 'single_exchange_processor.dart';
import '../widgets/context_merge_review_dialog.dart';

/// Controls a step-by-step supervised merge process.
class SupervisedMergeController {
  /// Starts merging [exchanges] beginning at [startIndex].
  /// Shows a confirmation dialog after each step.
  static Future<void> start({
    required BuildContext context,
    required List<Exchange> exchanges,
    required int startIndex,
  }) async {
    // Initialize empty context memory and parcel.
    var parcel = ContextParcel(summary: '', mergeHistory: []);
    var memory = ContextMemory(parcels: [parcel]);
    final strategy =
        MergeStrategyParser.fromString(AppConfig.mergeStrategy);

    for (var i = startIndex; i < exchanges.length; i++) {
      final ex = exchanges[i];
      try {
        parcel = await SingleExchangeProcessor.process(parcel, ex, strategy);
        // Append new parcel to memory and rebuild to keep metadata updated.
        memory = ContextMemoryBuilder.buildFinalMemory(
          latest: parcel,
          history: memory.parcels,
          totalExchangeCount: exchanges.length,
          mergeStrategy: AppConfig.mergeStrategy,
        );
        _logStep(i, parcel, memory);
      } catch (e) {
        // Show basic error dialog and abort.
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Merge Error'),
            content: Text('Failed to merge exchange $i: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      final charCount = jsonEncode(memory.toJson()).length;
      const promptTokens = 0;
      const completionTokens = 0;
      const model = 'mock-model';

      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ContextMergeReviewDialog(
          iteration: i - startIndex + 1,
          memory: memory,
          memoryCharCount: charCount,
          promptTokens: promptTokens,
          completionTokens: completionTokens,
          model: model,
          onContinue: () => Navigator.of(context).pop('continue'),
          onCancel: () => Navigator.of(context).pop('cancel'),
        ),
      );

      if (result != 'continue') break;
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Merge Complete'),
        content: Text(
          'Merged ${memory.parcels.length - 1} exchanges.\nFinal summary:\n${parcel.summary}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Logs merge step information to stdout.
  static void _logStep(int index, ContextParcel parcel, ContextMemory memory) {
    print('[MERGE] Step $index completed');
    print('[MERGE] Parcel summary: ${parcel.summary}');
    print('[MERGE] Memory size: ${jsonEncode(memory.toJson()).length} chars');
  }

}

