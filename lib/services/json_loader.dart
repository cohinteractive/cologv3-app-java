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
  final exchanges = <Exchange>[];

  for (final node in mapping.values) {
    if (node is Map) {
      final message = node['message'];
      if (message is Map) {
        final author = message['author'];
        if (author is Map && author['role'] == 'user') {
          final children = node['children'];
          if (children is List && children.isNotEmpty) {
            final child = mapping[children.first];
            if (child is Map) {
              final childMsg = child['message'];
              if (childMsg is Map) {
                final childAuthor = childMsg['author'];
                if (childAuthor is Map && childAuthor['role'] == 'assistant') {
                  final userText = _extractText(message);
                  final agentText = _extractText(childMsg);
                  final userTimeSeconds = message['create_time'];
                  final agentTimeSeconds = childMsg['create_time'];
                  final userTime = userTimeSeconds is num
                      ? DateTime.fromMillisecondsSinceEpoch(
                          (userTimeSeconds * 1000).toInt())
                      : ts;
                  final agentTime = agentTimeSeconds is num
                      ? DateTime.fromMillisecondsSinceEpoch(
                          (agentTimeSeconds * 1000).toInt())
                      : userTime;
                  exchanges.add(Exchange(
                    user: userText,
                    agent: agentText,
                    userTime: userTime,
                    agentTime: agentTime,
                  ));
                }
              }
            }
          }
        }
      }
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
