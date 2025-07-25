import 'dart:convert';
import 'package:test/test.dart';

import '../../lib/models/context_parcel.dart';
import '../../lib/models/context_memory.dart';
import '../../lib/models/context_tag.dart';
import '../../lib/export/markdown_resume_exporter.dart';
import '../../lib/export/structured_json_exporter.dart';

void main() {
  group('ContextParcel inline tag parser', () {
    test('parses valid tag at start of line', () {
      final parcel = ContextParcel(summary: '[DECISION] Choose A', mergeHistory: []);
      expect(parcel.inlineTags, {ContextTag.decision});
    });

    test('detects multiple tags', () {
      final summary = '[DECISION] A\n[BUG_FIX] Fixed B';
      final parcel = ContextParcel(summary: summary, mergeHistory: []);
      expect(parcel.inlineTags.contains(ContextTag.decision), isTrue);
      expect(parcel.inlineTags.contains(ContextTag.bugFix), isTrue);
      expect(parcel.inlineTags.length, 2);
    });

    test('ignores malformed tags', () {
      final summary = '[INVALID\nDECISION]\n[]\n[PLAN] ok';
      final parcel = ContextParcel(summary: summary, mergeHistory: []);
      expect(parcel.inlineTags, {ContextTag.plan});
    });

    test('deduplicates duplicate tags', () {
      final summary = '[PLAN] Step1\n[PLAN] Step2';
      final parcel = ContextParcel(summary: summary, mergeHistory: []);
      expect(parcel.inlineTags, {ContextTag.plan});
    });

    test('handles empty content', () {
      final parcel = ContextParcel(summary: '', mergeHistory: []);
      expect(parcel.inlineTags, isEmpty);
    });

    test('ignores tags mid-line', () {
      final summary = 'We decided [PLAN]\n[PLAN] Start';
      final parcel = ContextParcel(summary: summary, mergeHistory: []);
      expect(parcel.inlineTags, {ContextTag.plan});
    });

    test('ignores tags with surrounding noise', () {
      final parcel = ContextParcel(summary: '- [PLAN] bullet', mergeHistory: []);
      expect(parcel.inlineTags, isEmpty);
    });
  });

  group('Inline tag rendering', () {
    test('renders tags in Markdown export', () {
      final memory = ContextMemory(
        parcels: [ContextParcel(summary: '[PLAN] Do it', mergeHistory: [0])],
      );
      final exporter = MarkdownResumeExporter();
      final output = exporter.export(memory);
      expect(output.contains('_Inline Tags:_ PLAN'), isTrue);
    });

    test('renders tags in structured JSON export', () {
      final memory = ContextMemory(
        parcels: [ContextParcel(summary: '[BUG_FIX] fix', mergeHistory: [0])],
      );
      final exporter = StructuredJsonExporter();
      final jsonStr = exporter.export(memory);
      final data = jsonDecode(jsonStr);
      expect(data['parcels'][0]['inlineTags'], ['BUG_FIX']);
    });
  });
}
