import 'dart:convert';
import 'dart:io';

import '../models/context_parcel.dart';
import '../models/context_tag.dart';

/// Builds an index of inline tags across a list of [ContextParcel]s.
class TagIndexer {
  /// Maps tag labels to the list of parcel indices containing them.
  final Map<String, List<int>> tagIndex = {};

  TagIndexer();

  /// Generates a [TagIndexer] for [parcels].
  factory TagIndexer.indexAllTags(List<ContextParcel> parcels) {
    final indexer = TagIndexer();
    for (var i = 0; i < parcels.length; i++) {
      final parcel = parcels[i];
      for (final tag in parcel.inlineTags) {
        indexer.tagIndex.putIfAbsent(tag.label, () => []).add(i);
      }
    }
    return indexer;
  }

  /// Returns indices of parcels associated with [label].
  List<int> getParcelsWithTag(String label) =>
      List<int>.unmodifiable(tagIndex[label] ?? const []);

  /// Saves the index to [filePath] as JSON.
  void saveToFile(String filePath) {
    final file = File(filePath);
    final data = tagIndex;
    file.writeAsStringSync(jsonEncode(data));
  }

  /// Loads a previously saved index from [filePath].
  static TagIndexer loadFromFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return TagIndexer();
    try {
      final data = jsonDecode(file.readAsStringSync());
      if (data is Map<String, dynamic>) {
        final indexer = TagIndexer();
        data.forEach((key, value) {
          if (!ContextTag.isValidTagName(key)) return;
          if (value is List) {
            indexer.tagIndex[key] = value.whereType<int>().toList();
          }
        });
        return indexer;
      }
    } catch (_) {
      // Ignore malformed cache
    }
    return TagIndexer();
  }
}
