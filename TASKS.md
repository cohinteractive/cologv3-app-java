# TASKS

## 🔨 Active

- [ ] Add live search bar to left panel that filters conversations based on typed substring across all prompts and responses (case-insensitive).
- [ ] Add top status line above search bar in left panel showing: absolute file path, visible/total conversations, and current time
- [ ] Move status line to bottom of window and expand it across full width to display file path, conversation count, and current time
- [ ] Display per-conversation prompt index numbers in right panel using styled label inside each prompt box, aligned to left
- [ ] Add fixed header to right panel showing metadata for currently expanded exchange and auto-scroll to dock it under header
- [ ] Add summary text region to pinned header and simulate LLM summary placeholder for expanded exchange
- [ ] Fix exchange toggle so clicking prompt or response expands/collapses both together
- [ ] Visually de-emphasize collapsed exchanges in right panel by reducing background intensity, padding, and text color to create visual hierarchy
- [ ] Handle malformed or empty Exchange inputs in SingleExchangeProcessor.process()
