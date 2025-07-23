import 'package:test/test.dart';

import '../../lib/models/context_parcel.dart';
import '../../lib/models/exchange.dart';
import '../../lib/memory/single_exchange_processor.dart';
import '../../lib/services/llm_client.dart';

void main() {
  group('SingleExchangeProcessor', () {
    final originalSender = LLMClient.sendPrompt;
    tearDown(() => LLMClient.sendPrompt = originalSender);

    test('returns new ContextParcel from LLM', () async {
      LLMClient.sendPrompt =
          (prompt) async => '{"summary":"merged","mergeHistory":[0]}';
      final input = ContextParcel(summary: '', mergeHistory: []);
      final ex = Exchange(
        prompt: 'Hello',
        promptTimestamp: DateTime.now(),
        response: 'Hi',
        responseTimestamp: DateTime.now(),
      );
      final result = await SingleExchangeProcessor.process(input, ex);
      expect(result.summary, 'merged');
      expect(result.mergeHistory, [0]);
    });

    test('malformed exchange returns input parcel', () async {
      final input = ContextParcel(summary: 'keep', mergeHistory: [1]);
      final ex = Exchange(
        prompt: '',
        promptTimestamp: DateTime.now(),
        response: '',
        responseTimestamp: DateTime.now(),
      );
      final result = await SingleExchangeProcessor.process(input, ex);
      expect(identical(result, input), isTrue);
    });

    test('throws MergeException on empty LLM response', () async {
      LLMClient.sendPrompt = (prompt) async => '';
      final input = ContextParcel(summary: '', mergeHistory: []);
      final ex = Exchange(
        prompt: 'Hi',
        promptTimestamp: DateTime.now(),
        response: 'There',
        responseTimestamp: DateTime.now(),
      );
      expect(
        () => SingleExchangeProcessor.process(input, ex),
        throwsA(isA<MergeException>()),
      );
    });
  });
}
