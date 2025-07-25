# LLM Integration Map

## 📤 Prompt Preparation
- **lib/llm/instruction_templates.dart** – `InstructionTemplates.forStrategy()` returns merge instructions depending on the selected strategy.
- **lib/src/instructions/llm_instruction_templates.dart** – String templates used to construct prompts for initial and subsequent exchanges.
- **lib/src/instructions/instruction_templates.dart** – Exposes the common merge instruction blocks with strategy hints.

## 📥 LLM API Interaction
- **lib/services/llm_client.dart** – `LLMClient` holds a `sendPrompt` function used to contact the LLM (stubbed by default).
- **lib/memory/single_exchange_processor.dart** – Builds the prompt, calls `LLMClient.sendPrompt`, and parses the returned JSON.
- **lib/memory/iterative_merge_engine.dart** – Runs `SingleExchangeProcessor` across a sequence of exchanges and manages merge strategy.

## 🧠 Context Injection or Memory Slicing
- **lib/injection/injectable_context.dart** – `InjectableContext` converts `ContextParcel` objects into injection strings.
- **lib/injection/injection_formatter.dart** – `InjectionFormatter` formats lists of `InjectableContext` entries for ChatGPT, Codex, or JSON.
- **lib/services/memory_slicer.dart** – `MemorySlicer` extracts parcels by tag, topic, or recency and can convert them to `InjectableContext`.
- **lib/services/memory_selector.dart** – Provides interactive parcel selection and includes `toInjectable()` for final injection blocks.

## 📝 Summarization or Annotation
- **lib/memory/single_exchange_processor.dart** – Converts LLM JSON into `ContextParcel` and merges with prior context.
- **lib/memory/iterative_merge_engine.dart** – Logs deltas, supports manual review, and orchestrates merging.
- **lib/services/context_memory_builder.dart** – Builds `ContextMemory` from the latest parcel and history, tagging the result.
- **lib/services/tag_indexer.dart** – Scans parcels for inline tags and produces a tag index.
- **lib/models/context_parcel.dart** – Data model storing summary text, tags, and inline tag detection.
- **lib/models/context_memory.dart** – Container for merged memory with optional notes, confidence, and completeness from the LLM.

## 🔄 Response Handling
- **lib/memory/single_exchange_processor.dart** – Validates LLM output and throws `MergeException` when parsing fails.
- **lib/debug/debug_logger.dart** – Logs prompts, raw responses, and anomalies to aid debugging.
- **lib/services/manual_reviewer.dart** – Allows manual acceptance or editing of LLM-generated parcels before merge.

## 💪 Test or Debug Utilities
- **test/memory/single_exchange_processor_test.dart** – Tests merge logic and error handling of `SingleExchangeProcessor`.
- **test/debug/debug_logger_test.dart** – Basic test exercising the `DebugLogger.logLLMCall()` helper.
