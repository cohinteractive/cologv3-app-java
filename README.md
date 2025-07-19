# Colog V3 — Prompt and Context Organisation App

**Colog V3** is a lightweight Java desktop application that turns your exported ChatGPT conversations into a structured, searchable, and summarized knowledge base — making your entire AI-assisted development process readable, reusable, and navigable.

## 🧠 Why Use Colog?

If you're a developer who uses ChatGPT or Codex daily, you probably:

- Start new chats and lose project continuity
- Forget where previous solutions were discussed
- Waste time re-explaining bugs or prompts you've already solved

Colog V3 fixes this by turning your chat history into a **project memory system**.

---

## ✨ Features

- **ChatGPT JSON Importer**
  Parse exported `.json` files and convert them into structured conversations and exchanges. Supports files containing multiple conversations.

- **Conversation & Project Grouping**  
  Organize exchanges by conversation and associate conversations with larger projects.

- **Full-Text Search**  
  Instantly search prompts, responses, and tags across your entire history.

- **AI Summarization**  
  Use LLMs to generate readable summaries of large groups of prompts (e.g., onboarding flow evolution across 200+ prompts).

- **Meta-Tagging System**  
  Add tags like `bug`, `fix`, `decision`, or `feature` for fast filtering and classification.

- **Context Snapshot Generator**  
  Automatically generate high-fidelity summaries to continue ChatGPT sessions without losing context.

- **Fix & Error Recall**  
  Automatically detect bug/fix discussions and store them in a searchable issue database.

- **Markdown Work Journals** *(Optional)*  
  Export readable summaries of daily or project work for time-tracking, reporting, or review.

---

## 🛠️ Tech Stack

- Language: **Java 21+**
- UI: **Swing**
- Build: **No build tools** — compiled via script or IDE (no Gradle/Maven dependency overhead)
- Version Control: **Git + GitHub**
- LLM Integration: **Optional API (e.g. OpenAI)**

---

## 💡 Design Philosophy

> “Use AI like a collaborator — but never forget what you’ve already solved.”

Colog V3 is designed for developers who prototype and debug via LLMs but want a structured way to:
- Track progress
- Reuse past fixes
- Avoid redundant debugging
- Share or document what’s been done

---

## 🚧 Status

Actively in development. All implementation is handled by [GitHub Copilot / Codex] under direct human supervision. Features are added incrementally and tracked via markdown-based task files.

---

## 📥 Get Involved

This project is public for transparency and community inspiration. If you're interested in AI memory tooling, dev workflow enhancement, or prompt engineering tools, feel free to fork, watch, or follow along.

---

## 📄 License

MIT License
