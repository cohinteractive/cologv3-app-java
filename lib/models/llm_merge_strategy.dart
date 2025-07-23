enum MergeStrategy {
  defaultStrategy,
  conservative,
  aggressive,
}

extension MergeStrategyParser on MergeStrategy {
  static MergeStrategy fromString(String? value) {
    switch (value) {
      case 'conservative':
        return MergeStrategy.conservative;
      case 'aggressive':
        return MergeStrategy.aggressive;
      default:
        return MergeStrategy.defaultStrategy;
    }
  }
}
