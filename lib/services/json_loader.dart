import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/conversation.dart';
import '../models/exchange.dart';

class JsonLoader {
  static Future<List<Conversation>> loadConversations(String path) {
    return compute(_parseFile, path);
  }
}

Future<List<Conversation>> _parseFile(String path) async {
  try {
    final raw = await File(path).readAsString();
    final data = jsonDecode(raw);
    return _parseData(data);
  } on FormatException catch (e) {
    throw JsonLoadException(e.message);
  } on Exception catch (e) {
    throw JsonLoadException(e.toString());
  }
}

List<Conversation> _parseData(dynamic data) {
  if (data is Map && data.containsKey('conversations')) {
    final list = data['conversations'];
    if (list is List) {
      return list.map((c) => _parseConversation(c)).toList();
    }
  }
  if (data is List) {
    return data.map((c) => _parseConversation(c)).toList();
  }
  if (data is Map) {
    return [_parseConversation(data)];
  }
  return [];
}

Conversation _parseConversation(Map raw) {
  final title = raw['title'] as String? ?? 'Untitled';
  final tsSeconds = raw['create_time'];
  final ts = tsSeconds is num
      ? DateTime.fromMillisecondsSinceEpoch((tsSeconds * 1000).toInt())
      : DateTime.now();
  final fullMapping = raw['mapping'] as Map? ?? {};
  final mapping = <String, Map<String, dynamic>>{};
  final nodes = <Map<String, dynamic>>[];
  for (final entry in fullMapping.entries) {
    final node = entry.value;
    if (node is Map<String, dynamic> && node['message'] is Map) {
      final copy = Map<String, dynamic>.from(node);
      copy['id'] = entry.key;
      nodes.add(copy);
      mapping[entry.key] = copy;
    }
  }

  nodes.sort((a, b) {
    final at = a['message']?['create_time'];
    final bt = b['message']?['create_time'];
    if (at is num && bt is num) return at.compareTo(bt);
    return 0;
  });

  final exchanges = <Exchange>[];
  for (final node in nodes) {
    final msg = node['message'] as Map;
    final author = msg['author'];
    if (author is Map && author['role'] == 'user') {
      final promptText = _extractText(msg);
      final promptSec = msg['create_time'];
      final promptTime = promptSec is num
          ? DateTime.fromMillisecondsSinceEpoch((promptSec * 1000).toInt())
          : null;

      String? responseText;
      DateTime? responseTime;
      bool responseIsEmpty = true;

      final assistantNode = _findFirstNonEmptyAssistant(fullMapping, node['id']);

      if (assistantNode != null) {
        final respMsg = assistantNode['message'] as Map;
        responseText = _extractText(respMsg);
        final respSec = respMsg['create_time'];
        responseTime = respSec is num
            ? DateTime.fromMillisecondsSinceEpoch((respSec * 1000).toInt())
            : null;
        responseIsEmpty = responseText.trim().isEmpty;
      }

      final promptIsEmpty = promptText.trim().isEmpty;

      if (!promptIsEmpty || !responseIsEmpty) {
        final normalizedPrompt =
            promptIsEmpty ? '[[ Empty Prompt ]]' : promptText;
        final normalizedResponse = responseIsEmpty
            ? '[[ Empty Response ]]'
            : responseText!;

        exchanges.add(Exchange(
          prompt: normalizedPrompt,
          promptTimestamp: promptTime,
          response: normalizedResponse,
          responseTimestamp: responseTime,
        ));
      }
    }
  }

  return Conversation(title: title, timestamp: ts, exchanges: exchanges);
}

Map<String, dynamic>? _findFirstNonEmptyAssistant(
    Map fullMapping, String parentId) {
  final visited = <String>{};
  var currentId = parentId;

  while (true) {
    if (visited.contains(currentId)) return null;
    visited.add(currentId);

    final node = fullMapping[currentId];
    if (node == null) return null;
    final msg = node['message'];
    if (msg is Map && msg['author']?['role'] == 'assistant') {
      final content = msg['content'];
      final parts = content is Map ? content['parts'] : null;
      if (parts is List && parts.isNotEmpty &&
          parts.first.toString().trim().isNotEmpty) {
        return node as Map<String, dynamic>;
      }
    }

    final children = node['children'];
    if (children is List && children.isNotEmpty) {
      currentId = children.first;
    } else {
      return null;
    }
  }
}

String _extractText(Map msg) {
  final content = msg['content'];
  if (content is Map) {
    final parts = content['parts'];
    if (parts is List && parts.isNotEmpty) {
      final text = parts.first;
      if (text is String) return text;
    }
  }
  return '';
}

class JsonLoadException implements Exception {
  final String message;
  JsonLoadException(this.message);

  @override
  String toString() => message;
}
