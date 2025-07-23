import 'package:test/test.dart';

import '../../lib/debug/debug_logger.dart';
import '../../lib/models/context_parcel.dart';
import '../../lib/models/exchange.dart';

void main() {
  group('DebugLogger', () {
    test('stub logLLMCall', () {
      final ex = Exchange(
        prompt: 'hi',
        promptTimestamp: DateTime.now(),
        response: 'there',
        responseTimestamp: DateTime.now(),
      );
      final ctx = ContextParcel(summary: 's', mergeHistory: const []);
      DebugLogger.logLLMCall(
        instructions: 'do it',
        exchange: ex,
        context: ctx,
      );
    });
  });
}
