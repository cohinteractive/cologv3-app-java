/// Merge behavior options for combining new exchange data with existing context.
enum MergeStrategy {
  /// Replace previous context entirely with new information.
  replace,

  /// Append new exchange information to the end of existing context.
  append,

  /// Intelligently merge new information with existing context, preserving
  /// important prior details.
  smart,
}

extension MergeStrategyParser on MergeStrategy {
  /// Parses a string representation into a [MergeStrategy]. Defaults to
  /// [MergeStrategy.smart] when [value] is null or unrecognized.
  static MergeStrategy fromString(String? value) {
    switch (value) {
      case 'replace':
        return MergeStrategy.replace;
      case 'append':
        return MergeStrategy.append;
      case 'smart':
        return MergeStrategy.smart;
      default:
        return MergeStrategy.smart;
    }
  }
}
