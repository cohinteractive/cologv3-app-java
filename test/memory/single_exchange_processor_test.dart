import 'dart:async';
import 'package:test/test.dart';

import '../../lib/config/app_config.dart';
import '../../lib/models/context_parcel.dart';
import '../../lib/models/exchange.dart';
import '../../lib/memory/single_exchange_processor.dart';
import '../../lib/services/llm_client.dart';
import '../../lib/models/llm_merge_strategy.dart';

void main() {
  group('SingleExchangeProcessor', () {
    late PromptSender originalSender;

    setUp(() {
      originalSender = LLMClient.sendPrompt;
      AppConfig.debugMode = false;
    });

    tearDown(() {
      LLMClient.sendPrompt = originalSender;
      AppConfig.debugMode = false;
    });

    test('valid merge returns new ContextParcel', () async {
      LLMClient.sendPrompt = (prompt) async => {
            'choices': [
              {
                'message': {
                  'content': '{"summary":"merged","mergeHistory":[0]}'
                }
              }
            ]
          };
      final input = ContextParcel(summary: '', mergeHistory: []);
      final ex = Exchange(
        prompt: 'Hello',
        promptTimestamp: DateTime.now(),
        response: 'Hi',
        responseTimestamp: DateTime.now(),
      );
      final result = await SingleExchangeProcessor.process(
          input, ex, MergeStrategy.defaultStrategy);
      expect(result.summary, 'merged');
      expect(result.mergeHistory, [0]);
    });

    test('empty Exchange returns input parcel without calling LLM', () async {
      var called = false;
      LLMClient.sendPrompt = (prompt) async {
        called = true;
        return {'choices': []};
      };
      final input = ContextParcel(summary: 'keep', mergeHistory: [1]);
      final ex = Exchange(
        prompt: '',
        promptTimestamp: DateTime.now(),
        response: '',
        responseTimestamp: DateTime.now(),
      );
      final result = await SingleExchangeProcessor.process(
          input, ex, MergeStrategy.defaultStrategy);
      expect(identical(result, input), isTrue);
      expect(called, isFalse);
    });

    test('throws MergeException on malformed LLM response', () async {
      LLMClient.sendPrompt = (prompt) async => {
            'choices': [
              {
                'message': {'content': 'not json'}
              }
            ]
          };
      final input = ContextParcel(summary: '', mergeHistory: []);
      final ex = Exchange(
        prompt: 'Hi',
        promptTimestamp: DateTime.now(),
        response: 'There',
        responseTimestamp: DateTime.now(),
      );
      expect(
        () => SingleExchangeProcessor.process(
            input, ex, MergeStrategy.defaultStrategy),
        throwsA(isA<MergeException>()),
      );
    });

    test('debug logging prints when enabled', () async {
      AppConfig.debugMode = true;
      LLMClient.sendPrompt = (prompt) async => {
            'choices': [
              {
                'message': {
                  'content': '{"summary":"d","mergeHistory":[0]}'
                }
              }
            ]
          };
      final input = ContextParcel(summary: '', mergeHistory: []);
      final ex = Exchange(
        prompt: 'Hi',
        promptTimestamp: DateTime.now(),
        response: 'There',
        responseTimestamp: DateTime.now(),
      );
      final logs = <String>[];
      await runZoned(() async {
        await SingleExchangeProcessor.process(
            input, ex, MergeStrategy.defaultStrategy);
      }, zoneSpecification: ZoneSpecification(print: (self, parent, zone, line) {
        logs.add(line);
      }));
      expect(logs.any((l) => l.contains('SingleExchangeProcessor prompt')), isTrue);
    });
  });
}
