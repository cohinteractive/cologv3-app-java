import 'dart:io';

import '../models/context_memory.dart';
import '../models/context_parcel.dart';
import '../injection/injectable_context.dart';
import 'memory_slicer.dart';

/// Provides selection and preview of ContextParcels for export or injection.
class MemorySelector {
  final List<ContextParcel> _parcels;

  MemorySelector(List<ContextParcel> parcels)
      : _parcels = List<ContextParcel>.from(parcels);

  /// Creates a selector from a [ContextMemory].
  factory MemorySelector.fromMemory(ContextMemory memory) =>
      MemorySelector(memory.parcels);

  /// Returns parcels containing [tag].
  List<ContextParcel> selectByTag(String tag) =>
      MemorySlicer(_parcels).sliceByTag(tag);

  /// Returns parcels whose summary contains [keyword].
  List<ContextParcel> selectByKeyword(String keyword) =>
      MemorySlicer(_parcels).sliceByTopic(keyword);

  /// Returns the most recent [count] parcels.
  List<ContextParcel> selectRecent(int count) =>
      MemorySlicer(_parcels).sliceRecent(count);

  /// Returns the [custom] list as-is for manual selection convenience.
  List<ContextParcel> selectCustom(List<ContextParcel> custom) =>
      List<ContextParcel>.from(custom);

  /// Renders a simple numbered preview of [parcels] to [out].
  void preview(List<ContextParcel> parcels, {StringSink? out}) {
    final sink = out ?? stdout;
    if (parcels.isEmpty) {
      sink.writeln('(no entries)');
      return;
    }
    for (var i = 0; i < parcels.length; i++) {
      final p = parcels[i];
      final tags = <String>[
        ...p.inlineTags.map((e) => '[${e.label}]'),
        ...p.tags.map((e) => '[${e}]'),
      ];
      final tagStr = tags.isNotEmpty ? '${tags.join(' ')} ' : '';
      sink.writeln('${i + 1}. $tagStr${p.summary.trim()}');
    }
  }

  /// Prompts the user to choose entries from [parcels].
  /// Returns the selected list or empty if none chosen.
  Future<List<ContextParcel>> interactiveSelect(
    List<ContextParcel> parcels, {
    String? Function()? readInput,
    StringSink? out,
  }) async {
    final sink = out ?? stdout;
    final read = readInput ?? stdin.readLineSync;
    if (parcels.isEmpty) {
      sink.writeln('MemorySelector: no entries to select.');
      return [];
    }
    preview(parcels, out: sink);
    sink.write('Enter indices separated by commas: ');
    final line = read()?.trim();
    if (line == null || line.isEmpty) return [];
    final indices = line
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .where((i) => i != null && i! > 0 && i! <= parcels.length)
        .map((i) => i! - 1)
        .toSet();
    return indices.map((i) => parcels[i]).toList();
  }

  /// Converts [parcels] to [InjectableContext] entries.
  List<InjectableContext> toInjectable(List<ContextParcel> parcels, {String? role}) =>
      parcels.map((p) => InjectableContext.fromParcel(p, role: role)).toList();
}
