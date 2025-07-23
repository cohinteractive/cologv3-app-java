import "../models/llm_merge_strategy.dart";

class InstructionTemplates {
  static String forStrategy(MergeStrategy strategy) {
    switch (strategy) {
      case MergeStrategy.defaultStrategy:
        return _default;
      case MergeStrategy.conservative:
        return _conservative;
      case MergeStrategy.aggressive:
        return _aggressive;
    }
  }

  static const String _default = '''
  You are a context merger. Merge the new exchange into the existing context, updating summary, tags, and metadata as needed.
  ''';

  static const String _conservative = '''
  Merge conservatively: prefer not to overwrite existing context unless critical new information is found.
  ''';

  static const String _aggressive = '''
  Merge aggressively: favor newer information and overwrite older context when there's a conflict.
  ''';
}
