import '../models/conversation.dart';

/// Placeholder controller for supervised merge flow.
class SupervisedMergeController {
  /// Starts a supervised merge beginning at [startIndex] of [conversation].
  static Future<void> start(Conversation conversation, int startIndex) async {
    // TODO: implement merge dialog and logic.
    print(
        '[DEBUG] Supervised merge from index $startIndex in "${conversation.title}"');
  }
}

