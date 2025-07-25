import 'package:test/test.dart';

import '../../lib/models/context_parcel.dart';
import '../../lib/services/tag_indexer.dart';

void main() {
  group('TagIndexer', () {
    test('indexes parcels by inline tags', () {
      final parcels = [
        ContextParcel(summary: '[BUG_FIX] fix a', mergeHistory: [0]),
        ContextParcel(summary: '[DECISION] use b\n[PLAN] step', mergeHistory: [1]),
        ContextParcel(summary: 'no tag\n[ANSWER] done', mergeHistory: [2]),
      ];
      final indexer = TagIndexer.indexAllTags(parcels);
      expect(indexer.tagIndex['BUG_FIX'], [0]);
      expect(indexer.tagIndex['DECISION'], [1]);
      expect(indexer.tagIndex['PLAN'], [1]);
      expect(indexer.tagIndex['ANSWER'], [2]);
    });

    test('excludes invalid tags', () {
      final parcels = [
        ContextParcel(summary: '[UNKNOWN] text', mergeHistory: [0]),
      ];
      final indexer = TagIndexer.indexAllTags(parcels);
      expect(indexer.tagIndex.isEmpty, isTrue);
    });
  });
}
