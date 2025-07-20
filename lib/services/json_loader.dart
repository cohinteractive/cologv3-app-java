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
  final mapping = raw['mapping'] as Map? ?? {};
  final messages = <Map>[];
  for (final node in mapping.values) {
    if (node is Map) {
      final msg = node['message'];
      if (msg is Map) messages.add(msg);
    }
  }

  messages.sort((a, b) {
    final at = a['create_time'];
    final bt = b['create_time'];
    if (at is num && bt is num) return at.compareTo(bt);
    return 0;
  });

  final exchanges = <Exchange>[];
  for (int i = 0; i < messages.length; i++) {
    final msg = messages[i];
    final author = msg['author'];
    if (author is Map && author['role'] == 'user') {
      final promptText = _extractText(msg);
      final promptSec = msg['create_time'];
      final promptTime = promptSec is num
          ? DateTime.fromMillisecondsSinceEpoch((promptSec * 1000).toInt())
          : null;

      String? responseText;
      DateTime? responseTime;

      if (i + 1 < messages.length) {
        final nextMsg = messages[i + 1];
        final nextAuthor = nextMsg['author'];
        if (nextAuthor is Map && nextAuthor['role'] == 'assistant') {
          responseText = _extractText(nextMsg);
          final respSec = nextMsg['create_time'];
          responseTime = respSec is num
              ? DateTime.fromMillisecondsSinceEpoch((respSec * 1000).toInt())
              : null;
          i++; // skip assistant
        }
      }

      exchanges.add(Exchange(
        prompt: promptText,
        promptTimestamp: promptTime,
        response: responseText,
        responseTimestamp: responseTime,
      ));
    }
  }

  return Conversation(title: title, timestamp: ts, exchanges: exchanges);
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
