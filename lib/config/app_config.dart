class AppConfig {
  static bool debugMode = false;

  static void enableDebug() => debugMode = true;
  static void disableDebug() => debugMode = false;

  /// Merge strategy used by the LLM when processing exchanges.
  static String mergeStrategy = 'defaultStrategy';

  /// Directory where debug logs are written.
  static String debugOutputDir = 'debug';
}
