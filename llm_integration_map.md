# LLM Integration Map

## 📤 Prompt Preparation
- **lib/llm/instruction_templates.dart** – `InstructionTemplates.forStrategy` returns merge instruction strings for the selected strategy.
- **lib/src/instructions/llm_instruction_templates.dart** – Provides `singleExchangeInstruction`, `mergeInstruction`, and prompt templates used when summarizing exchanges.
- **lib/src/instructions/instruction_templates.dart** – Additional instruction blocks for different summarization strategies.
- **lib/memory/single_exchange_processor.dart** – Builds a prompt containing merge instructions, the prior context JSON, and the new exchange text.
- **lib/widgets/conversation_panel.dart** – `_summarize` formats a single-exchange prompt using `initialExchangePromptTemplate`.

## 📬 LLM API Interaction
- **lib/services/llm_client.dart** – `LLMClient.sendPrompt` posts the prompt to OpenAI's chat completions API.
- **lib/memory/single_exchange_processor.dart** – Sends prompts via `LLMClient.sendPrompt` and receives JSON.
- **lib/memory/iterative_merge_engine.dart** – Runs `SingleExchangeProcessor` across multiple exchanges in sequence.
- **lib/widgets/conversation_panel.dart** – Calls `LLMClient.sendPrompt` to fetch a summary for a single exchange.

## 🧠 Context Injection or Memory Slicing
- **lib/injection/injectable_context.dart** – Converts `ContextParcel` objects into compact strings for injection.
- **lib/injection/injection_formatter.dart** – Formats lists of `InjectableContext` entries for ChatGPT, Codex, or JSON outputs.
- **lib/services/memory_slicer.dart** – Extracts parcels by tag, topic, or recency and can convert them to `InjectableContext`.
- **lib/services/memory_selector.dart** – Interactive selector that renders previews and converts selections to `InjectableContext` entries.

## 📝 Summarization or Annotation
- **lib/memory/single_exchange_processor.dart** – Parses the LLM JSON into a `ContextParcel` and logs the result.
- **lib/memory/iterative_merge_engine.dart** – Merges a sequence of exchanges and logs context deltas.
- **lib/services/context_memory_builder.dart** – Produces a final `ContextMemory` from the latest parcel and history.
- **lib/services/tag_indexer.dart** – Scans parcels for inline tags and builds an index.
- **lib/models/context_parcel.dart** – Data model storing summary text, tags, and inline tag detection.
- **lib/models/context_memory.dart** – Container for merged memory with notes, confidence, and completeness.
- **lib/widgets/conversation_panel.dart** – Stores the returned summary text inside each `Exchange`.

## 🔁 Response Handling
- **lib/memory/single_exchange_processor.dart** – Validates LLM output and throws `MergeException` on failures.
- **lib/debug/debug_logger.dart** – Provides `logLLMCall`, `logLLMCallRaw`, and error logging for troubleshooting.
- **lib/services/manual_reviewer.dart** – Allows manual acceptance or editing of LLM-generated parcels before merge.
- **lib/widgets/conversation_panel.dart** – Displays errors when summarization fails.

## 🧪 Test or Debug Utilities
- **test/memory/single_exchange_processor_test.dart** – Exercises merge logic and error paths.
- **test/debug/debug_logger_test.dart** – Basic test of `DebugLogger.logLLMCall`.
- **test/injection/injection_formatter_test.dart** – Tests formatting of injection strings.
- **test/injection/injectable_context_test.dart** – Tests `InjectableContext` creation and concatenation.
- **test/services/memory_slicer_test.dart** – Verifies slicing and conversion to injectable contexts.
- **test/services/memory_selector_test.dart** – Tests interactive selection and preview behavior.
- **test/services/tag_indexer_test.dart** – Ensures inline tags are correctly indexed.
- **test/context_memory_test.dart** – Checks serialization of `ContextMemory` and parcels with manual edits.
