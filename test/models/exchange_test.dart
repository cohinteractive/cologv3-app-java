import 'package:test/test.dart';

import '../../lib/models/exchange.dart';

void main() {
  group('Exchange.isValid', () {
    test('returns true when prompt and response are non-empty', () {
      final ex = Exchange(
        prompt: 'hi',
        promptTimestamp: DateTime.now(),
        response: 'there',
        responseTimestamp: DateTime.now(),
      );
      expect(ex.isValid(), isTrue);
    });

    test('returns false when prompt or response empty', () {
      final ex1 = Exchange(
        prompt: '',
        promptTimestamp: DateTime.now(),
        response: 'a',
        responseTimestamp: DateTime.now(),
      );
      final ex2 = Exchange(
        prompt: 'a',
        promptTimestamp: DateTime.now(),
        response: '',
        responseTimestamp: DateTime.now(),
      );
      expect(ex1.isValid(), isFalse);
      expect(ex2.isValid(), isFalse);
    });
  });
}
