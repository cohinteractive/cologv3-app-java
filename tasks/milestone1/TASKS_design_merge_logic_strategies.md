# TASKS_design_merge_logic_strategies.md

## 🔀 Memory Merge Strategy Design (2025-07-22)

This file outlines tasks for refining how context memory is merged during LLM conversations.

---

### ✅ [IN SCOPE]

1. **Define at least two merging strategies for how LLM should treat prior and new context:**
   - Append with refinement (default)
   - Replace on conflict (aggressive overwrite)
2. **Specify logic for detecting redundancy or contradiction in natural language** (even if only heuristic or delegated to LLM).
3. **Allow developer to choose merge strategy per run or per exchange.**
4. **Consider optional versioning:** snapshotting context memory at each merge step.
5. **Document pros/cons of each strategy and usage recommendations.**

---

### 📎 Context
See `CURRENT_CONTEXT.md` for background on memory design.
