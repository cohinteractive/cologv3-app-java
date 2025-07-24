# TASKS_build_single_exchange_processor.md

## ⚙️ Single Exchange Processor (2025-07-22)

This file specifies tasks for processing a single Exchange into context memory.

---

1. **Implement a method that takes a single Exchange (prompt + response) and an empty or existing ContextParcel.**
2. **Inject both the Exchange and instructions into a Codex/LLM prompt to extract relevant context.**
3. **Return the updated ContextParcel, optionally logging intermediate results.**
4. **Handle malformed or empty Exchange cases gracefully.**
5. **Write test cases for the single Exchange processor using a few sample Exchanges.**

---

### 📎 Context
See `CURRENT_CONTEXT.md` for the current milestone roadmap.
