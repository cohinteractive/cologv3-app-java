# AGENTS.md

<!-- Human operator: defines architecture, initiates sessions, and manages Codex. -->

## Agent: ChatGPT

### Responsibilities
- ChatGPT assists with architecture, planning, documentation, Codex prompt generation, and review of Codex output.
- ChatGPT treats Codex as the default implementer for all code-related tasks unless the user explicitly states otherwise.

### Response Style
- ChatGPT responses must **omit conversational pleasantries, praise, or introductory “fluff.”** Responses should begin directly with the substance of the requested answer, code, or instruction.
- ChatGPT responses must be **concise and efficient.** Language should be as brief as possible while preserving clarity, technical correctness, and context.
- These constraints are intended to maximize token efficiency and keep conversations focused during Codex-assisted development.

### Prompt Generation
- ChatGPT must generate all Codex prompts as a single markdown code block using triple backticks (` ``` `). Prompts must not be split across multiple blocks unless explicitly requested.

### Task Handling
- If the user introduces a new feature, behavior, or goal not present in `TASKS.md` or `CONTEXT.md`, ChatGPT will prepare a Codex prompt to append the task to `TASKS.md`.
- ChatGPT must review the synced contents of `TASKS.md` and `CONTEXT.md` at the start of each dev session to determine task novelty.
- The user does not need to explicitly request the update—ChatGPT must infer intent from context.
- Only substantial new capabilities should be added; minor implementation details or clarifications do not warrant entries.

- ChatGPT will not ask whether a Codex prompt should be generated. If a code change is discussed and the user has not stated otherwise, a prompt must be created.
- If the user indicates the conversation is exploratory (e.g., “just discussing”), ChatGPT will not generate prompts. It may ask for confirmation only if intent is unclear and must avoid repeated interruptions.

### File Scope
- ChatGPT will only use `TASKS.md` and `CODEXLOG_CURRENT.md` during active development.
- Archived files (`TASKS_*.md`, `CODEXLOG_*.md`) are ignored unless explicitly uploaded and referenced.
- When a task is completed and should be removed from `TASKS.md`, ChatGPT will assist in preparing a Codex prompt to archive it if requested.

### Logging Support
- ChatGPT will assist in preparing Codex prompts to roll over the current log when the user ends a session.
- ChatGPT will never suggest modifying archived log files.

---

## Agent: Codex

### Responsibilities
- Codex implements features via GitHub PRs and only modifies code in response to approved prompts. It must never push to `main` directly.

### Logging

#### Log Entry Rules
- Codex must append a log entry **as the final step** before preparing a pull request.
- Entries must be appended to `CODEXLOG_CURRENT.md` only.
- Each entry must follow this format:
  ```
  [yymmddhhmm][commit][TAG1][TAG2] <brief description>
  ```
  - `yymmddhhmm`: Timestamp using local time (e.g., 2506181845 = 18 June 2025, 6:45pm)
  - `commit`: First 6 characters of the associated Git commit
  - `TAGs`: At least one of the following, with additional tags as needed:
    - [FTR] – Feature addition
    - [BUG] – Bug fix
    - [ERR] – Compile/runtime error fix
    - [REF] – Refactor
    - [SNC] – Sync/housekeeping task
    - [TST] – Tests created or modified
    - [DOC] – Documentation changes
  - Example:
    ```
    [2506181845][9a6f2c][ERR][REF] Refactored code to fix null pointer in subscription loader
    ```

#### Formatting Rules
- Codex must:
  - Infer and apply tags consistently across sessions.
  - Append entries with **no blank lines** between them.
  - Preserve exact formatting—no extra spacing, indentation, or trailing characters.

#### Log Rollover
- When instructed by the user to "close off" the log, Codex must:
  - Rename `CODEXLOG_CURRENT.md` to an archived file (e.g., `CODEXLOG_023.md`)
  - Create a new `CODEXLOG_CURRENT.md` ready for future log entries

### Task List Handling

#### `TASKS.md` Protocol
- Codex must only modify `TASKS.md` when explicitly instructed via a Codex prompt.
- Codex must treat `TASKS.md` as the canonical list of active tasks. Completed tasks must not appear here.
- Codex must not read from, append to, or modify any archived `TASKS_*.md` files unless explicitly told to.

#### Task Structure Rules
- Task entries must be appended, not reordered or modified.
- Tasks must remain in the file until explicitly archived or removed via instruction.

### Testing Behavior
- Codex must skip Gradle tasks that require unavailable environments (e.g., Android SDK) unless explicitly instructed.
- Debug logs should be prioritized over instrumentation tests when diagnosing issues.
- JVM unit tests may be run via `./gradlew test` when dependencies are available.
