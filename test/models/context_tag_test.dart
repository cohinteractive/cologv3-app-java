import 'package:test/test.dart';

import '../../lib/models/context_tag.dart';

void main() {
  group('ContextTag', () {
    test('parses valid tagged line', () {
      final tag = ContextTag.fromLine('[BUG_FIX] Fixed issue');
      expect(tag, ContextTag.bugFix);
    });

    test('returns null for untagged line', () {
      final tag = ContextTag.fromLine('No tag here');
      expect(tag, isNull);
    });

    test('validates tag names', () {
      expect(ContextTag.isValidTagName('DECISION'), isTrue);
      expect(ContextTag.isValidTagName('UNKNOWN'), isFalse);
    });

    test('detects tagged lines', () {
      expect(ContextTag.isValidTaggedLine('[PLAN] Something'), isTrue);
      expect(ContextTag.isValidTaggedLine('PLAN Something'), isFalse);
    });
  });
}
