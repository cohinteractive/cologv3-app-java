import 'llm_instruction_templates.dart';
import '../../models/llm_merge_strategy.dart';

/// Wrapper class exposing commonly used instruction blocks.
class InstructionTemplates {
  static const String merge = mergeInstruction;

  /// Returns merge instructions augmented for the given [strategy].
  static String forStrategy(MergeStrategy strategy) {
    switch (strategy) {
      case MergeStrategy.conservative:
        return '$merge\nUse a conservative merge strategy.';
      case MergeStrategy.aggressive:
        return '$merge\nUse an aggressive merge strategy that overwrites conflicting details.';
      case MergeStrategy.defaultStrategy:
        return merge;
    }
  }
}
