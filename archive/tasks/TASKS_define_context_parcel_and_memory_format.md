# TASKS_define_context_parcel_and_memory_format.md

## 📦 Context Parcel and Memory Format

These tasks specify how context information is packaged and stored.

---

1. **Define a `ContextParcel` data structure**
   - Contains a human-readable summary of context so far.
   - Holds metadata describing which Exchanges contributed.
   - Supports optional tags, assumptions, or confidence markers.
2. **Create a `ContextMemory` object**
   - Maintains the latest merged context across Exchanges.
3. **Clarify `ContextDelta` representation**
   - Specify its structure if separate from `ContextParcel` and whether it remains after merges.
4. **Decide on merge history handling**
   - Define if previous context versions are stored or discarded in `ContextMemory`.
5. **Document structures with examples**
   - Include example JSON or object schemas in comments.

---

### 📎 Context
This file introduces the foundational data model for managing conversation context.
