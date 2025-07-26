# LLM Integration Map

## 📤 Prompt Preparation
- **lib/llm/instruction_templates.dart** – `InstructionTemplates.forStrategy()` returns merge instructions depending on chosen `MergeStrategy`.
- **lib/src/instructions/llm_instruction_templates.dart** – String constants like `initialExchangePromptTemplate` to build per-exchange prompts.
- **lib/src/instructions/instruction_templates.dart** – Generic templates for single exchange summaries and context merging.

## 📬 LLM API Interaction
- **lib/services/llm_client.dart** – `LLMClient.sendPrompt()` posts prompt text to the OpenAI chat completions API.
- **lib/memory/single_exchange_processor.dart** – `SingleExchangeProcessor.process()` builds merge prompt and invokes `LLMClient`.
- **lib/memory/iterative_merge_engine.dart** – `IterativeMergeEngine.mergeAll()` runs the processor across a sequence of exchanges.
- **lib/widgets/conversation_panel.dart** – `_summarize()` sends a one‑off prompt to `LLMClient` from the UI.
- **cli/context_builder.dart** – Batch command that merges exchanges using `IterativeMergeEngine` then exports the resulting memory.

## 🧠 Context Injection or Memory Slicing
- **lib/injection/injectable_context.dart** – `InjectableContext` converts `ContextParcel` objects into injection strings.
- **lib/injection/injection_formatter.dart** – `InjectionFormatter` formats lists of `InjectableContext` entries for chat, Codex, or JSON.
- **lib/services/memory_slicer.dart** – `MemorySlicer` extracts parcels by tag, topic, or recency and can convert them to `InjectableContext`.
- **lib/services/memory_selector.dart** – Provides interactive parcel selection and includes `toInjectable()` for final injection blocks.

## 📝 Summarization or Annotation
- **lib/memory/single_exchange_processor.dart** – Parses LLM JSON into `ContextParcel` objects.
- **lib/memory/iterative_merge_engine.dart** – Logs deltas, supports optional manual review, and orchestrates merging.
- **lib/services/context_memory_builder.dart** – Builds a `ContextMemory` from the latest parcel and history.
- **lib/services/tag_indexer.dart** – Scans parcels for inline tags and produces a tag index.
- **lib/services/manual_reviewer.dart** – Allows manual acceptance or editing of each LLM-generated parcel.
- **lib/models/context_parcel.dart** – Data model storing summary text, tags, and inline tag detection.
- **lib/models/context_memory.dart** – Container for merged memory with optional notes, confidence, and completeness from the LLM.

## 🔁 Response Handling
- **lib/memory/single_exchange_processor.dart** – Validates and parses LLM responses, throwing `MergeException` on failure.
- **lib/debug/debug_logger.dart** – Logs prompts, raw responses, anomalies, and parsed results for debugging.
- **lib/widgets/conversation_panel.dart** – Updates the `Exchange.llmSummary` field with parsed summaries or error state.
- **lib/services/manual_reviewer.dart** – Provides interactive editing on errors or for manual confirmation.

## 🧪 Test or Debug Utilities
- **test/memory/single_exchange_processor_test.dart** – Unit tests covering merge logic and error handling of `SingleExchangeProcessor`.
- **test/debug/debug_logger_test.dart** – Simple test exercising `DebugLogger.logLLMCall()`.
- **test/llm/instruction_templates_test.dart** – Placeholder for instruction template tests.
