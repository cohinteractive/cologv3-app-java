class AppConfig {
  static bool debugMode = false;

  /// Merge strategy used by the LLM when processing exchanges.
  static String mergeStrategy = 'defaultStrategy';

  /// Directory where debug logs are written.
  static String debugOutputDir = 'debug';
}
