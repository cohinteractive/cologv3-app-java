# WORKFLOW

This project uses a task-based development model driven by ChatGPT and Codex.
All tasks are tracked in `TASKS.md`.

## Protocol

### T0 – Repository Sync and Preparation
- Pull latest changes and ensure local tree is clean
- Update all markdown files as needed

### T1 – Determine Next Tasks
- Review `TASKS.md` and select the next logical items

### T2 – Prepare Codex Prompt
- Craft a detailed prompt describing the selected tasks
- Include relevant context from `CONTEXT.md` and `FUNCTIONALITY.md`

### T3 – Submit Tasks to Codex
- Send the prompt to Codex for implementation

### T4 – Merge PRs and Pull Locally
- Review Codex PRs
- Merge when approved and sync locally

### T5 – Run and Test Changes
- Execute any required tests or manual checks

### T6 – Update TASKS.md and Logs
- Mark tasks complete or move them between sections
- Append entries to `CODEXLOG.md`

Interruptions are handled by simply picking up the next tasks from `TASKS.md`.

---

## PROMPTS

### T0_SYNC
```
Codex, check the current state of the repo and update all `.md` files including FUNCTIONALITY.md, TASKS.md, and CONTEXT.md to reflect the current codebase. Save the changes and commit them with the message: "Sync state update."
```

### T1_NEXT_TASKS
```
ChatGPT, analyze the current TASKS.md file. Suggest a logical set of next tasks to tackle, grouped by priority or logical dependencies.
```

### T3_EXECUTE_CODEX
```
Codex, perform the selected tasks from TASKS.md as specified. Use the updated context from CONTEXT.md and any details in FUNCTIONALITY.md. Return a PR or file diff showing changes.
```

### T6_FINAL_SYNC
```
Codex, perform a final sync of the repository state and update all relevant `.md` files. Commit as: "Final sync for task update."
```

