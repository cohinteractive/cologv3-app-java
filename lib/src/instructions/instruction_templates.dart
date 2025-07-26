class InstructionTemplates {
  static String forStrategy(String strategy) {
    switch (strategy) {
      case 'singleExchange':
        return _singleExchangeSummary;
      case 'mergeWithContext':
        return _mergeWithContext;
      case 'firstExchangeOnly':
        return _firstExchangeBootstrap;
      case 'contextSummarySnapshot':
        return _contextSummarySnapshot;
      case 'debugRawExcerpt':
        return _debugRawExcerpt;
      default:
        throw ArgumentError('Unknown strategy: $strategy');
    }
  }

  static const String _singleExchangeSummary = '''
You will be given a single user <-> assistant exchange from a software development conversation.

Your task is to extract only the **important contextual insights** from this exchange.

Summarize the intent, any problems discussed, solutions proposed, decisions made, and any implementation notes.

Omit conversational fluff, pleasantries, or reiteration of the full exchange.

Return only a valid JSON object in the form: { "summary": "..." }
Do not include any explanation or commentary outside the JSON object.
Example:
{
  "summary": "User proposed adding a hover menu option to trigger LLM summarization. Assistant agreed and outlined required changes.",
  "tags": ["feature", "LLM integration", "UI"]
}
''';

  static const String _mergeWithContext = '''
You will be given:
1. The current context memory object as a JSON block.
2. A new user <-> assistant exchange.
Your task is to merge the new exchange into the context memory.

Update or append to the summary as needed.
Preserve any prior important information unless it is clearly superseded or contradicted.

Return only a valid JSON object in the form: { "summary": "..." }
Do not include any explanation or commentary outside the JSON object.
Example:
{
  "summary": "Initial CLI added. Later refined to support filters. Now extended with LLM summarization trigger.",
  "tags": ["cli", "filters", "LLM"],
  "notes": "No known contradictions"
}
''';

  static const String _firstExchangeBootstrap = '''
You will be given a single user <-> assistant exchange.
Build the initial context memory by summarizing what occurred and tagging it.

Return only a valid JSON object in the form: { "summary": "..." }
Do not include any explanation or commentary outside the JSON object.
Example:
{
  "summary": "User wants to structure their AI coding logs using ContextParcels. Assistant outlined file and model structure.",
  "tags": ["logging", "ContextParcel", "design"]
}
''';

  static const String _contextSummarySnapshot = '''
You will be given a complete context memory JSON object representing merged conversation history.
Provide a concise snapshot capturing key features, decisions, and unresolved issues.

Return only a valid JSON object in the form: { "summary": "..." }
Do not include any explanation or commentary outside the JSON object.
Example:
{
  "summary": "Memory includes CLI batch mode, manual review, and debug logging. UI integration remains in progress.",
  "tags": ["CLI", "manual review", "debug", "UI"]
}
''';

  static const String _debugRawExcerpt = '''
A raw conversation excerpt or context block will be provided for debugging purposes.
Return the text exactly as received under the `raw` field without modification.

Respond ONLY with a JSON object. Example:
{
  "raw": "<original text here>"
}
''';
}
