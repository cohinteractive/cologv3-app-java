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

const String _usageGuide = '''
Builds a ContextMemory from exported ChatGPT conversation JSON.

Usage: dart cli/context_builder.dart --input <file|directory> [options]

Required arguments:
  --input <file|directory>    Input file or directory

Optional arguments:
  --output-format <json|markdown>  (default: json)
  --output-dir <path>        Directory for generated files
  --start-id <exchangeId>     Start Exchange ID
  --end-id <exchangeId>       End Exchange ID
  --tags <tag1,tag2,...>      Only include conversations with these tags
  --from-date <yyyy-mm-dd>    Start date inclusive
  --to-date <yyyy-mm-dd>      End date inclusive
  --title-keywords <kw1,kw2,...>
                              Only include conversations whose titles contain
                              any keyword
  --debug                     Enable debug logging
  --help                      Show this usage information

Example invocations:
  dart cli/context_builder.dart --input ./exports/chat.json
  dart cli/context_builder.dart --input ./exports/ \
      --output-dir ./out --output-format markdown --debug
''';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'input',
      abbr: 'i',
      help: 'Input file or directory',
      valueHelp: 'path',
    )
    ..addOption(
      'output-format',
      abbr: 'o',
      help: 'Output format',
      allowed: ['markdown', 'json'],
      defaultsTo: 'json',
    )
    ..addOption(
      'output-dir',
      help: 'Directory to write output files',
      valueHelp: 'path',
    )
    ..addOption('start-id', help: 'Start Exchange ID (inclusive)')
    ..addOption('end-id', help: 'End Exchange ID (inclusive)')
    ..addOption('tags', help: 'Comma-separated tag filter')
    ..addOption('from-date', help: 'Start date yyyy-mm-dd')
    ..addOption('to-date', help: 'End date yyyy-mm-dd')
    ..addOption('title-keywords',
        help: 'Comma-separated conversation title keywords')
    ..addFlag(
      'debug',
      abbr: 'd',
      help: 'Enable debug logging',
      defaultsTo: false,
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage');

  late ArgResults results;
  try {
    results = parser.parse(args);
  } on ArgParserException catch (e) {
    stderr.writeln(e.message);
    stdout.writeln(_usageGuide);
    exit(1);
  }

  if (results['help'] == true || args.isEmpty) {
    stdout.writeln(_usageGuide);
    return;
  }

  final inputPath = results['input'] as String?;
  if (inputPath == null) {
    stderr.writeln('Error: --input is required');
    stdout.writeln(_usageGuide);
    exit(1);
  }

  final entityType = FileSystemEntity.typeSync(inputPath);
  if (entityType == FileSystemEntityType.notFound) {
    stderr.writeln('Input path does not exist: $inputPath');
    exit(1);
  }

  final outputDir = results['output-dir'] as String?;
  if (entityType == FileSystemEntityType.directory && outputDir == null) {
    stderr.writeln('Error: --output-dir is required when processing a directory');
    exit(1);
  }
  if (outputDir != null) {
    final dir = Directory(outputDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  if (results['debug'] == true) {
    AppConfig.enableDebug();
  }

  final startTime = DateTime.now();
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

  for (var i = 0; i < files.length; i++) {
    await _processFile(files[i], results, i, files.length, outputDir);
  }
}

String _basename(String path) =>
    path.split(Platform.pathSeparator).isNotEmpty
        ? path.split(Platform.pathSeparator).last
        : path;

String _stem(String path) {
  final base = _basename(path);
  final dotIndex = base.lastIndexOf('.');
  return dotIndex == -1 ? base : base.substring(0, dotIndex);
}

List<String> _splitCsv(String? csv) {
  if (csv == null || csv.trim().isEmpty) return [];
  return csv.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  try {
    return DateTime.parse(value);
  } catch (_) {
    return null;
  }
}

Future<void> _processFile(
  String path,
  ArgResults results,
  int index,
  int total,
  String? outputDir,
) async {
  stdout.writeln('Processing file ${index + 1} of $total: ${_basename(path)}');
  final startTime = DateTime.now();

  final List<Conversation> conversations = [];
  try {
    conversations.addAll(await JsonLoader.loadConversations(path));
  } catch (e) {
    stderr.writeln('Failed to load $path: $e');
    return;
  }

  if (conversations.isEmpty) {
    stdout.writeln('No conversations loaded from ${_basename(path)}');
    return;
  }

  final tagsFilter = _splitCsv(results['tags'] as String?);
  final titleKeywords =
      _splitCsv(results['title-keywords'] as String?).map((e) => e.toLowerCase()).toList();
  final fromDate = _parseDate(results['from-date'] as String?);
  final toDate = _parseDate(results['to-date'] as String?);

  var tagExcluded = 0;
  var dateExcluded = 0;
  var titleExcluded = 0;

  final filteredConversations = <Conversation>[];
  for (final conv in conversations) {
    final convTags = conv.tags.map((e) => e.toLowerCase()).toList();
    final byTag = tagsFilter.isNotEmpty &&
        !tagsFilter.any((t) => convTags.contains(t.toLowerCase()));
    final byDate = (fromDate != null && conv.timestamp.isBefore(fromDate)) ||
        (toDate != null && conv.timestamp.isAfter(toDate));
    final titleLower = conv.title.toLowerCase();
    final byTitle =
        titleKeywords.isNotEmpty && !titleKeywords.any(titleLower.contains);

    if (byTag) tagExcluded++;
    if (byDate) dateExcluded++;
    if (byTitle) titleExcluded++;

    if (!(byTag || byDate || byTitle)) {
      filteredConversations.add(conv);
    }
  }

  if (results['debug'] == true) {
    stdout.writeln('  Filter results for ${_basename(path)}:');
    stdout.writeln('    Excluded by tags: $tagExcluded');
    stdout.writeln('    Excluded by date: $dateExcluded');
    stdout.writeln('    Excluded by title keywords: $titleExcluded');
  }

  final exchanges = <Exchange>[];
  final titles = <String>[];
  for (final conv in filteredConversations) {
    for (final ex in conv.exchanges) {
      exchanges.add(ex);
      titles.add(conv.title);
    }
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
  final filteredTitles = titles.sublist(startIndex, endIndex + 1);

  final skippedIndices = <int>[];
  for (var i = 0; i < filtered.length; i++) {
    final ex = filtered[i];
    if (ex.prompt.trim().isEmpty &&
        (ex.response == null || ex.response!.trim().isEmpty)) {
      skippedIndices.add(i);
    }
  }

  stdout.writeln(
    'Processing ${conversations.length} conversation(s) with ${filtered.length} exchange(s)...',
  );

  final engine = IterativeMergeEngine.fromConfig();
  final parcel = await engine.mergeAll(
    filtered,
    onProgress: (idx, total, ex) {
      final title = filteredTitles[idx];
      final previewWords = ex.prompt.split(RegExp(r'\s+')).take(10).join(' ');
      stdout.writeln('Processing Exchange ${idx + 1} of $total...');
      if (results['debug'] == true) {
        stdout.writeln('  Conversation: $title');
        stdout.writeln('  Preview: $previewWords');
        if (ex.promptTimestamp != null) {
          stdout.writeln('  Prompt Time: ${ex.promptTimestamp}');
        }
        if (ex.responseTimestamp != null) {
          stdout.writeln('  Response Time: ${ex.responseTimestamp}');
        }
      }
    },
  );

  final memory = ContextMemoryBuilder.buildFinalMemory(
    latest: parcel,
    sourceConversationId: conversations.length == 1
        ? conversations.first.title
        : null,
    totalExchangeCount: filtered.length,
    mergeStrategy: engine.strategy.name,
  );

  final formatName = results['output-format'] as String;
  final format = formatName == 'markdown'
      ? ExportFormat.markdownResume
      : ExportFormat.structuredJson;
  final exporter = ExporterRegistry.getExporter(format);

  stdout.writeln('Context build complete. Outputting memory to terminal.');
  final output = exporter != null
      ? exporter.export(memory)
      : jsonEncode(memory.toJson());
  stdout.writeln(output);

  final targetDir = outputDir ?? AppConfig.memoryOutputDir;
  final dir = Directory(targetDir);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  final stem = _stem(path);
  final ext = formatName == 'markdown' ? 'md' : 'json';
  final outFilePath = '${dir.path}/$stem.context.$ext';
  final outFile = File(outFilePath);
  await outFile.writeAsString(output);
  stdout.writeln('\u2714 Saved to $outFilePath');

  final endTime = DateTime.now();
  final outputPath = outFilePath;

  stdout.writeln('\nSummary for ${_basename(path)}');
  stdout.writeln('  Conversations: ${filteredConversations.length}');
  stdout.writeln('  Exchanges: ${filtered.length}');
  stdout.writeln('  Parcels: ${memory.parcels.length}');
  stdout.writeln(
      '  Duration: ${startTime.toIso8601String()} -> ${endTime.toIso8601String()}');
  stdout.writeln('  Output location: $outputPath');

  if (results['debug'] == true) {
    for (int i = 0; i < memory.parcels.length; i++) {
      final conf = memory.parcels[i].confidence;
      if (conf.isNotEmpty) {
        stdout.writeln('  Parcel ${i + 1} confidence: $conf');
      }
    }
    if (skippedIndices.isNotEmpty) {
      stdout.writeln('  Skipped malformed exchanges: ${skippedIndices.join(', ')}');
    }
  }
}
