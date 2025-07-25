> ⚠️ This file has been archived as of 2025-07-22.  
> It reflects an outdated monolithic task system and **must not** be used for future task tracking.  
> All new development tasks are tracked under atomic task sets in the `tasks/` folder.

# TASKS

## ✅ Completed
- Placeholder for completed tasks
- Add initial Flutter app skeleton
- Implement file selection and JSON preview
- Display scrollable conversation and exchange views
- Integrate custom JSON parser for ChatGPT export format
- Build dynamic mapping of JSON into Exchanges grouped by Conversation
- Apply dark theme styling throughout
- Add conversation list header panel with labels
- App opens in dark mode with menu bar and File > Open/Exit
- Left panel lists conversations with index, title, exchange count, and timestamp
- Clicking a conversation highlights it and populates the right panel with exchanges
- Clicking an exchange expands/collapses to show full text
- Dark theme with distinct colors and white fonts for readability


## 🕰️ Legacy Tasks (Pre-UI Redesign)
- Set up initial project structure and documentation
- Define build and run scripts

- Support toggleable expand/collapse per Exchange
- Preserve expand state and scroll position
- Automatically summarize exchanges and infer tags
- Support multi-conversation JSON files
- Implement full-text search and filter UI
- Add summary sidebar with clickable exchange navigation
- Add tag-based filtering with interactive labels
- Implement tag label interactivity
- Format Exchange prompt and response sections
- Display preview summary lines per exchange
- Indent responses in a wrapper panel
- Show exchange counts in conversation rows

## 🔜 Upcoming
- Implement expandable Exchange panels that toggle on click
- Add hover-based action icons (e.g., summarize, collapse) on Exchange containers
- Visually delineate prompt/response pairs using background color and indentation
- Create a collapsible left sidebar for browsing collapsed conversation titles
- Add responsive layout with central content column and left/right padding
- Enable fast, smooth scrolling for large conversation files
- Display styled inline error panel on JSON parse failure (non-blocking)
- Integrate Exchange rendering using parsed Exchange model objects
- Preserve escape characters in rendered text (e.g., newlines shown correctly)
- Load and render full conversations from large JSON files efficiently
- Render a vertical, scrollable list of conversations in the left panel
- Display conversation metadata (index, timestamp, title) using two-line layout
- Add divider lines beneath each conversation entry for visual separation
- Remove left border; use smart spacing for visual cleanliness
- Highlight the selected conversation on click by inverting colors
- Ensure only one conversation is highlighted at a time (de-highlight others)
- Keep the selected conversation visually pinned during scroll
- Deselect conversation via right-click
- Add right-click context menu to conversation entries with:
  - Custom<Clicked Element> stubbed function
  - About stubbed function
- Show the selected conversation's prompt/response view in the right panel
- Ensure left and right panels scroll independently
- Fix missing response display in exchanges
- Improve expand/collapse animations to feel more natural and anchored
- Add 3-dot hover menu to conversation labels and exchanges
- Implement context menu triggered by 3-dot menu with single “About” option
- Create “About” dialog with app name, version, author, and copyright
