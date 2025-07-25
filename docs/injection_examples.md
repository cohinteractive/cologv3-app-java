# Injection Output Examples

This document demonstrates how `InjectableContext` entries can be rendered for different injection targets.

## ChatGPT Prompt Style
Use when pasting context directly into a ChatGPT session. Each line begins with inline tags followed by the summary.

```
2025-07-25T09:30:00Z [DECISION] Chose to route context by feature
2025-07-25T09:50:00Z [BUG_FIX] Resolved conflict in module export paths
```

## Codex Task-Planning Format
Structured comment blocks suitable for Codex planning prompts.

```
// DECISION: Chose to route context by feature (2025-07-25T09:30:00Z)
// BUG_FIX: Resolved conflict in module export paths (2025-07-25T09:50:00Z)
```

## External Summarizer JSON
Compact JSON for downstream analyzers or summarizers.

```json
[
  {
    "tag": "DECISION",
    "summary": "Chose to route context by feature",
    "timestamp": "2025-07-25T09:30:00Z"
  },
  {
    "tag": "BUG_FIX",
    "summary": "Resolved conflict in module export paths",
    "timestamp": "2025-07-25T09:50:00Z"
  }
]
```
