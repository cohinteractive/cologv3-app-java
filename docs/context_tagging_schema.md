# Context Tagging Schema

ContextParcels may include inline tags to mark the role or purpose of a line. Tags make it easier for tools and reviewers to locate key information.

## Supported Tags

| Tag | Meaning |
| --- | ------- |
| `[DECISION]` | Captures important project or architectural decisions |
| `[BUG_FIX]` | Describes the nature of a fix or its discussion |
| `[ARCH_NOTE]` | Denotes architectural commentary or notes |
| `[QUESTION]` | Marks a question raised in the conversation |
| `[ANSWER]` | Indicates an explicit answer or solution |
| `[PLAN]` | Outlines a plan or next steps |
| `[BLOCKER]` | Identifies something preventing progress |

## Format

- Tags appear at the **start of a line**.
- The tag text is wrapped in square brackets with uppercase letters and underscores.
- Example: `[DECISION] Switch to gRPC for service communication.`

A line without a recognized tag is treated as regular summary text.

## Examples

```text
[DECISION] Adopt repository pattern for data access.
[BUG_FIX] Fixed null pointer when user ID is missing.
[ARCH_NOTE] Parser layer separated from UI for testing.
[PLAN] Implement caching next sprint.
```

### Instruction Snippet

The LLM summarization template encourages tagging inline:

```text
Analyze the prompt and response carefully and capture only high-value context.
- Ignore filler text or social niceties.
- Prioritize concrete facts, decisions, bug fixes, and architectural insights.
- Preserve code snippets or key configuration details exactly as written.
- Omit prompts or responses that add no new insight.
- Use tags [DECISION], [BUG_FIX], [PLAN], [BLOCKER], [ARCH_NOTE] at the start of relevant lines when helpful.
```
