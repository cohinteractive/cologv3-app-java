import 'package:flutter/material.dart';

import '../models/context_memory.dart';
import '../models/context_parcel.dart';
import '../models/exchange.dart';
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
    final memory = ContextMemory(parcels: []);
    final processor = SingleExchangeProcessor();

    for (int i = startIndex; i < exchanges.length; i++) {
      final exchange = exchanges[i];
      ContextParcel? parcel;

      try {
        parcel = await processor.process(exchange);
      } catch (e) {
        debugPrint('[SupervisedMerge] Error processing exchange $i: $e');
        continue;
      }

      if (parcel == null) {
        debugPrint('[SupervisedMerge] Skipping null parcel at index $i');
        continue;
      }

      memory.mergeWith(parcel);

      const int promptTokens = 0;
      const int completionTokens = 0;
      const String model = 'unknown';

      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ContextMergeReviewDialog(
          iteration: i - startIndex + 1,
          memory: memory,
          memoryCharCount: memory.toInjectable().summary.length,
          promptTokens: promptTokens,
          completionTokens: completionTokens,
          model: model,
          onContinue: () => Navigator.of(context).pop('continue'),
          onCancel: () => Navigator.of(context).pop('cancel'),
        ),
      );

      if (result != 'continue') {
        debugPrint('[SupervisedMerge] Aborted by user at index $i');
        break;
      }
    }

    debugPrint('[SupervisedMerge] Completed merge process.');
  }

}

