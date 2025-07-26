# TASKS_add_ui_entrypoint_for_llm_summarization.md

## 🧠 Add UI Entrypoint for Exchange Summarization via LLM

These tasks create a functional user-accessible path to summarize any prompt/response Exchange using an LLM.

---

1. **Add a "Summarize with LLM" option to the 3-dot hover menu of every prompt and response block.**
   - Only one option per Exchange (deduplicated if prompt and response are both visible)
   - Trigger action with a click handler that receives the full Exchange object

2. **Route the selected Exchange to `SingleExchangeProcessor.process()`**
   - Construct the prompt using `InstructionTemplates.forStrategy()`
   - Use the selected Exchange as input
   - Execute asynchronously with loading state and error handling

3. **Display the returned `ContextParcel.summary` below the Exchange**
   - Style the summary as a read-only Markdown block or expandable panel
   - Support clearing/dismissing the summary

4. **Log all summarization attempts in `DebugLogger.logLLMCall()`**
   - Include the instruction used and Exchange ID for traceability

5. **(Optional) Highlight or badge Exchanges that have already been summarized**
   - Use a visual cue to indicate processed status

---

### 📎 Context

This milestone enables direct, live use of the LLM from the UI. It is the first true end-to-end integration: user ➜ prompt ➜ LLM ➜ parsed summary ➜ visible result.
