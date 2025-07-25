# TASKS_add_context_role_tagging_and_markup.md

## 🏷️ Add Context Role Tagging and Markup

These tasks introduce role-based tagging and markup to improve the structure and searchability of ContextMemory data.

---

1. **Define a tagging schema to label parts of the ContextMemory (e.g., `[DECISION]`, `[BUG_FIX]`, `[ARCH_NOTE]`).**
2. **Modify the `ContextParcel` structure to support inline role tags or markup sections.**
3. **Update the LLM instruction template to encourage role tagging where applicable.**
4. **Add a post-merge step to scan and index tags across the final memory.**
5. **Write unit tests for tag parsing and rendering.**

---

### 📎 Context
This milestone expands ContextMemory to include explicit role annotations for easier filtering and analysis.
