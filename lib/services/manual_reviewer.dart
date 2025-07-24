import 'dart:convert';
import 'dart:io';

import '../models/context_parcel.dart';

/// Provides interactive review of ContextParcel objects before merging.
class ManualReviewer {
  /// Prompts the user to accept, reject, or edit the [parcel].
  /// Returns the parcel to merge or `null` if rejected.
  static Future<ContextParcel?> review(ContextParcel parcel) async {
    stdout.writeln('\nProposed ContextParcel:');
    stdout.writeln(JsonEncoder.withIndent('  ').convert(parcel.toJson()));
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
        return ContextParcel(
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
        );
      default:
        stdout.writeln('Accepted.');
        return parcel;
    }
  }
}
