# TASKS_add_debug_logging_and_state_tracking.md

## 🔧 Debug Logging and State Tracking

These tasks focus on enhancing visibility into the LLM interaction and context merge process.

---

1. **Create a debug mode that logs each LLM call, including:**
   - Instructions
   - Exchange input
   - Returned ContextParcel
2. **Add timestamped checkpoints of the ContextParcel state after each merge.**
3. **Log any anomalies such as repeated context, LLM failure, or skipped merges.**
4. **Optionally store a diff log between ContextParcel states.**
5. **Allow toggling debug mode globally via config.**
