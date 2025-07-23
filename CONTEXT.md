# CONTEXT.md

## 🚀 Elevator Pitch

**Colog V3** is a lightweight desktop app designed to tame the chaos of AI-assisted development. It parses exported ChatGPT conversation data, intelligently groups and classifies exchanges, and builds a searchable, taggable, and summarizable archive of your entire development history — across all projects, conversations, and iterations.

Colog V3 transforms overwhelming chat transcripts into a structured knowledge base that can be used to:

- Summarize long threads of work into readable snapshots
- Resurface solutions to recurring problems instantly
- Seamlessly resume ChatGPT sessions without losing any context
- Understand the evolution of features or debugging efforts across dozens (or hundreds) of prompts

It’s not just a log — it’s your **AI-augmented project memory.**

---

## 🧠 What the App Does

Colog V3 helps you *capture, structure, and reuse* your development conversations with ChatGPT and Codex by providing the following capabilities:

### 🗃️ 1. Exchange Model

- Parses your ChatGPT `.json` export file (even large ones, e.g. 50–100 MB).
- Groups each prompt and its associated response into an `Exchange` object.
- Each `Exchange` contains:
  - Prompt text
  - Response text
  - Timestamp(s)
  - Optional metadata (tags, notes, classification, etc.)

### 💬 2. Conversation Grouping

- All Exchanges are grouped under their original containing conversation from the export file.
- Conversation-level metadata is preserved if present (e.g., title, date range).
- Within each conversation, you can browse all prompts and responses linearly or via filters.

### 🏗️ 3. Project Grouping

- Conversations can be grouped into a parent **Project**.
- Grouping is inferred via:
  - Explicit assignment by the user
  - Conversation titles
  - Detected keywords or tags
- Enables viewing all conversations and exchanges within a single app/project lifecycle.

### 🔍 4. Cross-Conversation Search

- Full-text search across all prompts, responses, or both.
- Supports tag filtering and type filtering (e.g., only bug reports or only Codex instructions).
- Allows you to search by topic — e.g., “database architecture for CoachTracker” — and view every relevant Exchange, even if scattered across multiple conversations and dates.

### 🧠 5. Smart LLM Summarization

- Uses a local or remote LLM API to:
  - Summarize individual conversations
  - Summarize multiple Exchange entries as a single topic (e.g., onboarding flow evolution)
  - Provide human-readable summaries of complex threads spanning hundreds of entries
- Enables quick understanding without re-reading everything

### 🏷️ 6. Meta-Tagging

- Supports manual and automated tagging of:
  - Conversations
  - Exchanges
  - Projects
- Tags help power:
  - Search filters
  - Historical fix retrieval
  - Project analysis (e.g., how many bug fixes vs. features)

### 🔄 7. Context Resumption Aid

- Any conversation or topic group can be **summarized into a high-fidelity context block**, suitable for pasting into a new ChatGPT session.
- Ensures zero loss of context across sessions — even when conversations get split due to length limits.
- Saves time re-explaining what you were working on or what has already been tried.

### 🧩 8. Issue and Fix Database (Optional but Powerful)

- Exchange entries tagged as bugs, issues, errors, or exceptions can be indexed separately.
- Fixes and solutions are automatically extracted or tagged alongside.
- Enables instant recall of previously solved problems when similar errors occur.
- Fix entries can include:
  - Stack traces
  - File or class names
  - Fix summary
  - Link to the full discussion

### 📝 9. Work Journal Output (Optional)

- For any selected set of conversations or time range:
  - Generate a readable Markdown log summarizing the work done
  - Timestamped highlights of major decisions, implemented features, fixes, and discussions
- Great for daily standups, reporting, or personal tracking

---

## 🖥️ Tech Stack and Development Model

### 🎯 Goals

- **Cross-platform UI flexibility**
- **Maintainable modern codebase**
- **Codex-friendly, declarative structure**
- **Future compatibility with minimal maintenance overhead**

### ⚙️ Platform & Tools

| Component           | Choice                      | Notes |
|---------------------|------------------------------|-------|
| Language            | Dart                         | Primary language for Flutter |
| Framework           | Flutter (latest stable)      | For building desktop/mobile/web app |
| Editor              | VS Code                      | Codex-friendly and extensible |
| Coding Model        | Codex-led implementation     | ChatGPT handles design and coordination, Codex implements |
| Versioning          | Git + GitHub                 | Used for all source control |
| Dependency Policy   | Use latest stable packages   | Avoid future compatibility cascades |

---

## 🔮 Future Considerations

- Offline LLM summarization using local models
- Vault diffing to compare changes across versions
- Feature timeline generation (what got added/fixed and when)
- Integration with Git logs to link code commits and conversation history
- Automated conversation de-duplication and fix linking
- Export all summaries or conversations to static site for publishing or browsing

---

## 🧾 Summary

**Colog V3** is a Swing-based desktop app built to make sense of hundreds (or thousands) of AI conversations. It captures and organizes your development logs, summarizes long threads, remembers past fixes, and helps you pick up where you left off — all without overwhelming build systems, UIs, or infrastructure.

It’s built *for developers who use ChatGPT and Codex as true collaborators*, and want a structured, reusable, searchable memory of everything they’ve built together.


## Current State
The status line is now displayed at the bottom of the app window, spanning full width, and shows the loaded file path, number of visible/total conversations, and the current system time.
Prompt entries in the right panel now show per-conversation index numbers along the left side of the prompt block, matching the index box style used in the conversation list.
The right-hand conversation panel now includes a pinned status header that displays the timestamp of the currently expanded exchange. When an exchange is expanded, it scrolls to align beneath the header and updates the metadata display. The pinned header now includes a summary placeholder below the timestamp, ready for future LLM-generated content. This summary updates based on the currently expanded exchange.
Exchange expansion now occurs at the exchange level: clicking on either the prompt or the response expands both together, ensuring consistent view and scroll behavior.
