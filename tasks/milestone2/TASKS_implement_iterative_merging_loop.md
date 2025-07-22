# TASKS_implement_iterative_merging_loop.md

## 🔄 Iterative Merging Loop

These tasks outline how to build the engine that incrementally merges Exchanges into context memory.

---

1. **Create an engine that accepts a list of Exchanges and processes them in order.**
2. **For each step, pass the current `ContextParcel` and next Exchange to the LLM.**
3. **Use the response as the new `ContextParcel` and continue.**
4. **Track which Exchanges contributed to the final memory (for metadata/debugging).**
5. **Log memory state at each step if debugging is enabled.**
6. **Allow injection of different LLM merge strategies via configuration or flags.**

---

### 📎 Context
This file continues milestone 2 work on the memory merging pipeline.
