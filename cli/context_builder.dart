import 'dart:convert';
import 'dart:io';

import 'package:colog_v3/services/json_loader.dart';
import 'package:colog_v3/memory/iterative_merge_engine.dart';
import 'package:colog_v3/services/context_memory_builder.dart';
import 'package:colog_v3/models/conversation.dart';
import 'package:colog_v3/models/exchange.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run cli/context_builder.dart <chatgpt_export.json> [more files...]');
    exit(1);
  }

  stdout.writeln('Context Builder: starting build process');

  final List<Conversation> conversations = [];
  for (final path in args) {
    stdout.writeln('Loading $path ...');
    try {
      final convs = await JsonLoader.loadConversations(path);
      conversations.addAll(convs);
    } catch (e) {
      stderr.writeln('Failed to load $path: $e');
    }
  }

  if (conversations.isEmpty) {
    stdout.writeln('No conversations loaded.');
    exit(1);
  }

  final List<Exchange> exchanges = [];
  for (final conv in conversations) {
    exchanges.addAll(conv.exchanges);
  }

  stdout.writeln('Processing ${conversations.length} conversation(s) with ${exchanges.length} exchange(s)...');

  final engine = IterativeMergeEngine.fromConfig();
  final parcel = await engine.mergeAll(exchanges);

  final memory = ContextMemoryBuilder.buildFinalMemory(
    latest: parcel,
    sourceConversationId: conversations.length == 1 ? conversations.first.title : null,
    totalExchangeCount: exchanges.length,
    mergeStrategy: engine.strategy.name,
  );

  stdout.writeln('Context build complete. Outputting memory to terminal.');
  stdout.writeln(jsonEncode(memory.toJson()));
}
