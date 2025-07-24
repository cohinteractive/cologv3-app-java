import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:colog_v3/config/app_config.dart';
import 'package:colog_v3/export/exporter_registry.dart';
import 'package:colog_v3/export/export_formats.dart';
import 'package:colog_v3/services/json_loader.dart';
import 'package:colog_v3/memory/iterative_merge_engine.dart';
import 'package:colog_v3/services/context_memory_builder.dart';
import 'package:colog_v3/models/conversation.dart';
import 'package:colog_v3/models/exchange.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('input', abbr: 'i', help: 'Input file or directory', valueHelp: 'path')
    ..addOption('output-format',
        abbr: 'o',
        help: 'Output format',
        allowed: ['markdown', 'json'],
        defaultsTo: 'json')
    ..addOption('start-id', help: 'Start Exchange ID (inclusive)')
    ..addOption('end-id', help: 'End Exchange ID (inclusive)')
    ..addFlag('debug', abbr: 'd', help: 'Enable debug logging', defaultsTo: false)
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage');

  late ArgResults results;
  try {
    results = parser.parse(args);
  } on ArgParserException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln(parser.usage);
    exit(1);
  }

  if (results['help'] == true) {
    stdout.writeln(parser.usage);
    return;
  }

  final inputPath = results['input'] as String?;
  if (inputPath == null) {
    stderr.writeln('Error: --input is required');
    stderr.writeln(parser.usage);
    exit(1);
  }

  final entityType = FileSystemEntity.typeSync(inputPath);
  if (entityType == FileSystemEntityType.notFound) {
    stderr.writeln('Input path does not exist: $inputPath');
    exit(1);
  }

  if (results['debug'] == true) {
    AppConfig.enableDebug();
  }

  stdout.writeln('Context Builder: starting build process');

  final List<String> files = [];
  if (entityType == FileSystemEntityType.directory) {
    final dir = Directory(inputPath);
    for (final f in dir.listSync()) {
      if (f is File && f.path.toLowerCase().endsWith('.json')) {
        files.add(f.path);
      }
    }
  } else {
    files.add(inputPath);
  }

  if (files.isEmpty) {
    stderr.writeln('No JSON files found at $inputPath');
    exit(1);
  }

  final List<Conversation> conversations = [];
  for (final path in files) {
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

  var startIndex = 0;
  var endIndex = exchanges.length - 1;
  final startOpt = results['start-id'] as String?;
  final endOpt = results['end-id'] as String?;
  if (startOpt != null) {
    final val = int.tryParse(startOpt);
    if (val != null && val >= 0 && val < exchanges.length) {
      startIndex = val;
    }
  }
  if (endOpt != null) {
    final val = int.tryParse(endOpt);
    if (val != null && val >= startIndex && val < exchanges.length) {
      endIndex = val;
    }
  }
  final filtered = exchanges.sublist(startIndex, endIndex + 1);

  stdout.writeln(
      'Processing ${conversations.length} conversation(s) with ${filtered.length} exchange(s)...');

  final engine = IterativeMergeEngine.fromConfig();
  final parcel = await engine.mergeAll(filtered);

  final memory = ContextMemoryBuilder.buildFinalMemory(
    latest: parcel,
    sourceConversationId:
        conversations.length == 1 ? conversations.first.title : null,
    totalExchangeCount: filtered.length,
    mergeStrategy: engine.strategy.name,
  );

  final formatName = results['output-format'] as String;
  final format = formatName == 'markdown'
      ? ExportFormat.markdownResume
      : ExportFormat.structuredJson;
  final exporter = ExporterRegistry.getExporter(format);

  stdout.writeln('Context build complete. Outputting memory to terminal.');
  if (exporter != null) {
    stdout.writeln(exporter.export(memory));
  } else {
    stdout.writeln(jsonEncode(memory.toJson()));
  }
}
