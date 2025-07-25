/// Instruction templates injected into LLM calls by the summarization runner.
///
/// [singleExchangeInstruction] is always included when processing a new
/// exchange. If prior context exists, [mergeInstruction] is used to merge the
/// new exchange with the previous summary instead of the initial template.

const String singleExchangeInstruction = '''
Analyze the prompt and response carefully and capture only high-value context.
- Ignore filler text or social niceties.
- Prioritize concrete facts, decisions, bug fixes, and architectural insights.
- Preserve code snippets or key configuration details exactly as written.
- Omit prompts or responses that add no new insight.
- Use tags [DECISION], [BUG_FIX], [PLAN], [BLOCKER], [ARCH_NOTE] at the start of relevant lines when helpful.
Return only a valid JSON object in the form: { "summary": "..." }
Do not include any explanation or commentary outside the JSON object.
''';

const String mergeInstruction = '''
When merging new context with existing summaries:
- Prune redundant, superseded, or irrelevant details.
- Preserve non-conflicting facts that remain important for understanding.
- If contradictions arise, prefer the most recent statement unless earlier
  information is clearly more reliable.
- Mark unresolved areas as unclear rather than discarding them.
- Maintain role tags like [DECISION], [BUG_FIX], [PLAN], [BLOCKER], [ARCH_NOTE].
Return only a valid JSON object in the form: { "summary": "..." }
Do not include any explanation or commentary outside the JSON object.
''';

const String initialExchangePromptTemplate = '''
You are summarizing a coding-related ChatGPT conversation. Here is the first exchange:
PROMPT: {{prompt}}
RESPONSE: {{response}}

Extract high-value context suitable for persistent project memory. Use the instruction set:
$singleExchangeInstruction
Return only a valid JSON object in the form: { "summary": "..." }
Do not include any explanation or commentary outside the JSON object.
''';

const String subsequentExchangePromptTemplate = '''
Continue summarizing the conversation. Prior context:
{{priorContext}}

New exchange:
PROMPT: {{prompt}}
RESPONSE: {{response}}

Apply the following merge instructions to update the context:
$mergeInstruction
Return only a valid JSON object in the form: { "summary": "..." }
Do not include any explanation or commentary outside the JSON object.
''';

String examplePrompt(bool isFirst) {
  const samplePrompt = "How do I fix a null pointer in Flutter's setState?";
  const sampleResponse =
      'Wrap the call in a mounted check. Example: if (!mounted) return; setState(() { ... });';
  const prior = 'Earlier summary about initialization issues.';

  if (isFirst) {
    return initialExchangePromptTemplate
        .replaceAll('{{prompt}}', samplePrompt)
        .replaceAll('{{response}}', sampleResponse);
  }
  return subsequentExchangePromptTemplate
      .replaceAll('{{priorContext}}', prior)
      .replaceAll('{{prompt}}', samplePrompt)
      .replaceAll('{{response}}', sampleResponse);
}
