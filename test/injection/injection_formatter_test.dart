import 'dart:convert';

import 'package:test/test.dart';

import '../../lib/injection/injection_formatter.dart';
import '../../lib/injection/injectable_context.dart';

void main() {
  group('InjectionFormatter', () {
    test('formats single entry for ChatGPT', () {
      final ctx = InjectableContext(
        summary: 'Route context by feature',
        tags: ['DECISION'],
      );
      final formatter = InjectionFormatter([ctx]);
      expect(formatter.toChatFormat(), '[DECISION] Route context by feature');
    });

    test('formats multiple entries for ChatGPT', () {
      final entries = [
        InjectableContext(summary: 'Do A', tags: ['PLAN']),
        InjectableContext(summary: 'Do B', tags: ['PLAN']),
      ];
      final formatter = InjectionFormatter(entries);
      expect(
        formatter.toChatFormat(),
        '[PLAN] Do A\n[PLAN] Do B',
      );
    });

    test('formats single entry for Codex', () {
      final ctx = InjectableContext(
        summary: 'Extract routing',
        tags: ['PLAN'],
      );
      final formatter = InjectionFormatter([ctx]);
      expect(formatter.toCodexFormat(), '// PLAN: Extract routing');
    });

    test('formats multiple entries for Codex', () {
      final entries = [
        InjectableContext(summary: 'Note one', tags: ['ARCH_NOTE']),
        InjectableContext(summary: 'Note two'),
      ];
      final formatter = InjectionFormatter(entries);
      expect(
        formatter.toCodexFormat(),
        '// ARCH_NOTE: Note one\n// NOTE: Note two',
      );
    });

    test('formats single entry as JSON', () {
      final ts = DateTime.parse('2025-07-25T12:45:00Z');
      final ctx = InjectableContext(
        summary: 'Fix bug',
        tags: ['BUG_FIX'],
        timestamp: ts,
      );
      final formatter = InjectionFormatter([ctx]);
      final json = jsonDecode(formatter.toJsonSummary()) as Map<String, dynamic>;
      expect(json['tag'], 'BUG_FIX');
      expect(json['summary'], 'Fix bug');
      expect(json['timestamp'], ts.toIso8601String());
    });

    test('formats multiple entries as JSON array', () {
      final entries = [
        InjectableContext(summary: 'A'),
        InjectableContext(summary: 'B'),
      ];
      final formatter = InjectionFormatter(entries);
      final json = jsonDecode(formatter.toJsonSummary()) as List<dynamic>;
      expect(json.length, 2);
      expect(json[0]['summary'], 'A');
      expect(json[1]['summary'], 'B');
    });
  });
}
