✅ ARCHIVED — Milestone 1 (LLM Instruction Templates) completed as of 2025-07-23.
# TASKS_specify_llm_instruction_templates.md

## 🧠 LLM Instruction Templates (2025-07-22)

This task file outlines how to design reusable instruction blocks and prompt templates for the LLM runner.

---

### ✅ [IN SCOPE]

1. **Create a reusable instruction block that tells the LLM how to analyze a single Exchange and extract only high-value context.**
2. **Add merging instructions that clarify:**
   - What information should be pruned or overwritten
   - What should be preserved
   - How to handle contradictions or uncertainty
3. **Write template prompts for:**
   - First Exchange (no prior context)
   - Subsequent Exchanges (merging into prior context)
4. **Include examples for each prompt template using a fake prompt/response pair.**
5. **Document how instruction sets are embedded and passed to the LLM runner.**

---

### 📎 Context
See `CURRENT_CONTEXT.md` for overarching project direction.
