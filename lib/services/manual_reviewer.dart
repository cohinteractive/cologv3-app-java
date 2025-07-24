import 'dart:convert';
import 'dart:io';

import '../models/context_parcel.dart';
import '../models/manual_edit.dart';
import '../config/app_config.dart';

/// Provides interactive review of ContextParcel objects before merging.
class ManualReviewer {
  /// Prompts the user to accept, reject, or edit the [parcel]. Optionally
  /// compares the parcel against [baseline] and shows a unified diff.
  /// Returns the parcel to merge or `null` if rejected.
  static Future<ContextParcel?> review(
    ContextParcel parcel,
    int exchangeId, [
    ContextParcel? baseline,
  ]) async {
    if (baseline != null && baseline.summary.isNotEmpty) {
      final oldJson = JsonEncoder.withIndent('  ').convert(baseline.toJson());
      final newJson = JsonEncoder.withIndent('  ').convert(parcel.toJson());
      final diff = _generateUnifiedDiff(oldJson, newJson);
      stdout.writeln('\nProposed ContextParcel diff:');
      stdout.writeln(_truncate(diff));
    } else {
      stdout.writeln('\nProposed ContextParcel:');
      stdout.writeln(JsonEncoder.withIndent('  ').convert(parcel.toJson()));
    }
    stdout.write('[A]ccept / [R]eject / [E]dit: ');
    final choice = stdin.readLineSync()?.trim().toLowerCase();
    switch (choice) {
      case 'r':
        stdout.writeln('Rejected. Skipping this exchange.');
        return null;
      case 'e':
        stdout.write('Edit summary (leave blank to keep): ');
        final newSummary = stdin.readLineSync();
        stdout.write('Edit tags CSV (leave blank to keep): ');
        final tagsInput = stdin.readLineSync();
        stdout.write('Edit assumptions CSV (leave blank to keep): ');
        final assumptionsInput = stdin.readLineSync();
        final edited = ContextParcel(
          summary: newSummary != null && newSummary.trim().isNotEmpty
              ? newSummary.trim()
              : parcel.summary,
          mergeHistory: parcel.mergeHistory,
          tags: tagsInput != null && tagsInput.trim().isNotEmpty
              ? tagsInput
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList()
              : parcel.tags,
          assumptions:
              assumptionsInput != null && assumptionsInput.trim().isNotEmpty
                  ? assumptionsInput
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList()
                  : parcel.assumptions,
          confidence: parcel.confidence,
          manualEdits: parcel.manualEdits,
        );

        final record = ManualEdit(
          exchangeId: exchangeId,
          original: parcel.toJson(),
          edited: edited.toJson(),
          timestamp: DateTime.now(),
        );
        return ContextParcel(
          summary: edited.summary,
          mergeHistory: edited.mergeHistory,
          tags: edited.tags,
          assumptions: edited.assumptions,
          confidence: edited.confidence,
          manualEdits: [...parcel.manualEdits, record],
        );
      default:
        stdout.writeln('Accepted.');
        return parcel;
    }
  }

  /// Creates a naive unified diff between [oldText] and [newText].
  static String _generateUnifiedDiff(String oldText, String newText) {
    final oldLines = oldText.split('\n');
    final newLines = newText.split('\n');
    final buffer = StringBuffer();
    var i = 0;
    var j = 0;
    while (i < oldLines.length || j < newLines.length) {
      final oldLine = i < oldLines.length ? oldLines[i] : null;
      final newLine = j < newLines.length ? newLines[j] : null;
      if (oldLine != null && newLine != null && oldLine == newLine) {
        buffer.writeln('  $oldLine');
        i++;
        j++;
      } else {
        if (oldLine != null) {
          buffer.writeln('- $oldLine');
          i++;
        }
        if (newLine != null) {
          buffer.writeln('+ $newLine');
          j++;
        }
      }
    }
    return buffer.toString();
  }

  /// Truncates [diff] for non-debug mode to avoid flooding the terminal.
  static String _truncate(String diff) {
    final lines = diff.split('\n');
    if (!AppConfig.debugMode && lines.length > 40) {
      final head = lines.take(20).join('\n');
      final tail = lines.skip(lines.length - 20).join('\n');
      return '$head\n... (${lines.length - 40} lines truncated) ...\n$tail';
    }
    return diff;
  }
}
