import 'dart:convert';
import 'dart:io';

import 'routing_config.dart';

/// Loads [RoutingConfig] from a JSON [path].
/// Returns `null` if the file does not exist.
Future<RoutingConfig?> loadRoutingConfig([String path = 'routing_config.json']) async {
  final file = File(path);
  if (!await file.exists()) return null;
  final content = await file.readAsString();
  final data = jsonDecode(content) as Map<String, dynamic>;
  return RoutingConfig.fromJson(data);
}
