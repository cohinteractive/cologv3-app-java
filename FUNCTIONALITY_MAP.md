# FUNCTIONALITY_MAP.md

## 🧠 LLM Integration and Context Memory System

### ✅ Prompt Generation
- Uses predefined instruction templates to control LLM behavior
  - Located in: `instruction_templates.dart`, `llm_instruction_templates.dart`
  - Strategies supported: initial prompt, merge prompt, single Exchange extraction

### ✅ LLM Communication Pipeline
- `LLMClient.sendPrompt()` makes real calls to OpenAI (`gpt-3.5-turbo`)
- Accepts text prompt and returns parsed JSON response
- Environment-based API key access (`OPENAI_API_KEY_COLOG`)
- Logged via `DebugLogger`

### ✅ Single Exchange Processing
- `SingleExchangeProcessor.process(prompt)`:
  - Builds prompt from Exchange
  - Calls LLM via `LLMClient`
  - Parses response into `ContextParcel`
  - Logs full trace and errors

### ✅ Iterative Merge Engine
- `IterativeMergeEngine.run()`:
  - Processes a sequence of Exchanges into a single merged ContextMemory
  - Supports configurable merge strategies (append, overwrite)
  - Logs each step’s intermediate state

### ✅ Manual Review Support
- Optionally allows user to review, edit, or reject each LLM-generated ContextParcel before merge
- Supports diffs, inline editing, and final acceptance
- Controlled by configuration flag

### ✅ Batch Processing (Completed)
- CLI batch runner supports:
  - Folder- or file-based batch input
  - Filtering by tag, date range, title
  - Per-conversation error handling
  - Output to structured JSON and logs

### ✅ Role-Based Tagging and Markup
- ContextParcel entries can be tagged (e.g. `[BUG_FIX]`, `[DECISION]`)
- Role tags are extractable for filtering and summarization

### 🔄 Context Routing and Output Targets
- ContextMemory can be routed by:
  - Feature/module association metadata
  - Destination configuration (filesystem, doc generator, fix archive)
- Extensible routing engine (planned)

### 📤 Export Formats
- Supports exporting context memory in multiple formats:
  - Markdown (conversation resumption blocks)
  - JSON (automation)
  - Design/feature summaries
- Export module supports pluggable formatters

### 🧩 Context Injection Support
- ContextMemory slices can be injected into other agents (ChatGPT, Codex)
- Selector/filter available to control what gets injected
- Output templates for Markdown and JSON

---

## 🖥️ UI Capabilities

### ⬜ Hover Menu (Planned)
- 3-dot menu per Exchange
- Will support:
  - “Summarize with LLM”
  - Show response inline (transient or attached)
  - Track summarized state

### 🗂️ Exchange and Conversation Browsing
- Prompts and responses grouped into Exchanges
- Exchanges grouped under original ChatGPT conversations
- Conversations grouped under Projects

### 🔍 Search and Filter
- Full-text search over prompts, responses, or both
- Filter by tags, type (bug, fix, feature)
- Search across all conversations and projects

---

## 🔧 Developer Tools and Utilities

### ✅ CLI Runner
- Build context memory from exported JSON or Exchange logs
- Filterable and scriptable for automation
- Logs all output to file

### ✅ Debug Logging
- Logs raw LLM responses and prompts
- Tracks anomalies, duplicates, and merge errors
- Optional memory diffs

### ✅ Output Routing
- Supports configurable routing to:
  - Filesystem
  - Feature/module folders
  - Placeholder documentation modules

---

## 📦 Core Data Models

### ContextParcel
- Summary text
- Tags, source Exchanges
- Optional confidence/completeness
- Optional inline annotations or markup

### ContextMemory
- Final merged memory across all processed Exchanges
- Merge history (if versioning enabled)
- Can be sliced, exported, injected

---

## ✅ Completed Functional Milestones

| Milestone | Description |
|----------|-------------|
| Instruction Templates | `forStrategy()` and string templates complete |
| Context Data Model | `ContextParcel`, `ContextMemory`, merge strategy |
| Single Exchange Processor | LLM integration complete |
| Manual Review Mode | Fully implemented |
| CLI Batch Processor | Implemented with filters and logging |
| Role Tagging | Tag system and scanner stubbed |
| Export Formats | Markdown + JSON views scaffolded |

---

## ⬜ Not Yet Implemented

| Area | Missing Pieces |
|------|----------------|
| UI Access to LLM | No hook to trigger LLM summarization from UI |
| Summarization Display | No visual response renderer or feedback panel |
| Feature Routing | Context routing engine stub only |
| Fix/Issue Database | No live indexing of errors/fixes |
| Vault Diffing | Not implemented |
| Timeline View | Not implemented |
| Local LLM Support | Not yet added |

---
```
