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
