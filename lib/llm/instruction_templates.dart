import "../models/merge_strategy.dart";

class InstructionTemplates {
  static String forStrategy(MergeStrategy strategy) {
    switch (strategy) {
      case MergeStrategy.replace:
        return _replace;
      case MergeStrategy.append:
        return _append;
      case MergeStrategy.smart:
        return _smart;
    }
  }

  static const String _replace = '''
  You are a context merger. Merge the new exchange into the existing context, updating summary, tags, and metadata as needed.
  ''';

  static const String _append = '''
  Merge conservatively: prefer not to overwrite existing context unless critical new information is found.
  ''';

  static const String _smart = '''
  Merge aggressively: favor newer information and overwrite older context when there's a conflict.
  ''';
}
