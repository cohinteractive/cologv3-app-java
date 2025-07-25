import '../models/context_parcel.dart';

/// Lightweight context snapshot optimized for prompt injection.
class InjectableContext {
  /// Concise summary text of the conversation segment.
  final String summary;

  /// Optional tags describing this context block.
  final List<String> tags;

  /// Optional role metadata (e.g. 'user', 'assistant').
  final String? role;

  /// When this context was generated.
  final DateTime? timestamp;

  /// Optional feature association for routing.
  final String? feature;

  /// Optional system or component name.
  final String? system;

  /// Optional module identifier.
  final String? module;

  InjectableContext({
    required this.summary,
    List<String>? tags,
    this.role,
    this.timestamp,
    this.feature,
    this.system,
    this.module,
  }) : tags = tags ?? [];

  /// Builds an [InjectableContext] from a [ContextParcel].
  factory InjectableContext.fromParcel(
    ContextParcel parcel, {
    String? role,
    DateTime? timestamp,
  }) => InjectableContext(
    summary: parcel.summary,
    tags: parcel.tags,
    role: role,
    timestamp: timestamp,
    feature: parcel.feature,
    system: parcel.system,
    module: parcel.module,
  );

  /// Returns a compact string suitable for direct LLM injection.
  String toInjectionString() {
    final buffer = StringBuffer();
    if (timestamp != null) {
      buffer.write('${timestamp!.toIso8601String()} ');
    }
    if (role != null && role!.isNotEmpty) {
      buffer.write('[$role] ');
    }
    buffer.write(summary.trim());
    if (tags.isNotEmpty) {
      buffer.write(' {${tags.join(', ')}}');
    }
    final meta = <String>[];
    if (feature != null) meta.add('feature:$feature');
    if (system != null) meta.add('system:$system');
    if (module != null) meta.add('module:$module');
    if (meta.isNotEmpty) {
      buffer.write(' <${meta.join(', ')}>');
    }
    return buffer.toString().trim();
  }

  /// Concatenates multiple contexts into a single injection string.
  static String concatenate(List<InjectableContext> entries) =>
      entries.map((e) => e.toInjectionString()).join('\n');
}
