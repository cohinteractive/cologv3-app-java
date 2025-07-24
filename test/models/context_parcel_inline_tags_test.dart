import 'package:test/test.dart';

import '../../lib/models/context_parcel.dart';
import '../../lib/models/context_tag.dart';

void main() {
  group('ContextParcel inline tag extraction', () {
    test('extracts tags from multiline summary', () {
      final summary = '[BUG_FIX] Fixed A\nSome text\n[DECISION] Use B';
      final parcel = ContextParcel(summary: summary, mergeHistory: []);
      expect(parcel.inlineTags.contains(ContextTag.bugFix), isTrue);
      expect(parcel.inlineTags.contains(ContextTag.decision), isTrue);
      expect(parcel.inlineTags.length, 2);
    });

    test('deduplicates duplicate tags', () {
      final summary = '[PLAN] Step1\n[PLAN] Step2';
      final parcel = ContextParcel(summary: summary, mergeHistory: []);
      expect(parcel.inlineTags, {ContextTag.plan});
    });

    test('returns empty set when no tags present', () {
      final parcel = ContextParcel(summary: 'No tags here', mergeHistory: []);
      expect(parcel.inlineTags, isEmpty);
    });

    test('ignores invalid tags', () {
      final summary = '[UNKNOWN] Text\n[BUG_FIX] ok';
      final parcel = ContextParcel(summary: summary, mergeHistory: []);
      expect(parcel.inlineTags, {ContextTag.bugFix});
    });
  });
}
