import 'dart:convert';

import '../config/app_config.dart';
import '../models/context_parcel.dart';
import '../models/exchange.dart';
import '../debug/debug_logger.dart';
import '../models/merge_strategy.dart';
import 'single_exchange_processor.dart';
import 'context_delta.dart';
import '../services/manual_reviewer.dart';

/// Engine that incrementally merges a list of Exchanges into a ContextParcel
/// using an LLM-backed processor.
class IterativeMergeEngine {
  final MergeStrategy strategy;

  IterativeMergeEngine({this.strategy = MergeStrategy.smart});

  factory IterativeMergeEngine.fromConfig() => IterativeMergeEngine(
        strategy: MergeStrategyParser.fromString(AppConfig.mergeStrategy),
      );

  /// Merges [exchanges] sequentially using [SingleExchangeProcessor].
  /// Returns the final merged [ContextParcel].
  Future<ContextParcel> mergeAll(
    List<Exchange> exchanges, {
    void Function(int index, int total, Exchange exchange)? onProgress,
  }) async {
    var context = ContextParcel(summary: '', mergeHistory: []);
    final mergeHistory = <int>[];
    var index = 0;

    if (AppConfig.debugMode) {
      print('IterativeMergeEngine: Using strategy $strategy');
      print(
        'IterativeMergeEngine: manual review mode is '
        '${AppConfig.manualReview ? 'enabled' : 'disabled'}',
      );
    }
    final total = exchanges.length;
    for (final exchange in exchanges) {
      onProgress?.call(index, total, exchange);
      if (exchange.prompt.trim().isEmpty &&
          (exchange.response == null || exchange.response!.trim().isEmpty)) {
        if (AppConfig.debugMode) {
          print(
            'IterativeMergeEngine: Skipping malformed exchange at index $index',
          );
          DebugLogger.logAnomaly(
            'Skipped merge for malformed exchange at index $index',
          );
        }
        index++;
        continue;
      }

      try {
        final previousContext = context;
        final prevJson = jsonEncode(previousContext.toJson());
        final result = await SingleExchangeProcessor.process(
          context,
          exchange,
          strategy,
        );
        ContextParcel? reviewed = result;
        if (result == null) {
          if (AppConfig.debugMode) {
            print(
              'IterativeMergeEngine: Warning - null merge result at index $index',
            );
          }
          if (AppConfig.debugMode) {
            DebugLogger.logAnomaly(
              'LLM merge failure at exchange index $index: null result',
            );
          }
          index++;
          continue;
        }
        if (AppConfig.manualReview) {
          if (AppConfig.debugMode) {
            print('IterativeMergeEngine: launching manual review for exchange $index');
          }
          reviewed = await ManualReviewer.review(
            result,
            index,
            previousContext,
          );
          if (reviewed == null) {
            index++;
            continue;
          }
        }
        if (prevJson == jsonEncode(reviewed.toJson()) && AppConfig.debugMode) {
          DebugLogger.logAnomaly(
            'ContextParcel unchanged after merging exchange at index $index',
          );
        }
        if (AppConfig.debugMode) {
          final delta = ContextDelta.compute(previousContext, reviewed);
          DebugLogger.logContextDelta(delta, index);
        }
        context = reviewed;
        mergeHistory.add(index);
        if (AppConfig.debugMode) {
          print('IterativeMergeEngine: merged exchange $index');
          print('Current merge history: $mergeHistory');
          DebugLogger.logContextParcel(context, index);
          DebugLogger.logContextCheckpoint(context, index);
        }
      } on MergeException catch (e) {
        if (AppConfig.debugMode) {
          print('IterativeMergeEngine: MergeException at index $index: $e');
          DebugLogger.logAnomaly(
            'LLM merge failure at exchange index $index: ${e.message}',
          );
        }
        index++;
        continue;
      }

      // ContextParcel state logged via DebugLogger above when debugMode is true.
      index++;
    }

    return ContextParcel(
      summary: context.summary,
      mergeHistory: mergeHistory,
      tags: context.tags,
      assumptions: context.assumptions,
      notes: context.notes,
      confidence: context.confidence,
      manualEdits: context.manualEdits,
    );
  }
}
