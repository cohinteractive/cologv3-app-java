# Context Memory Merge Strategies

## appendWithRefinement (default)
- **Behavior:** new parcels are appended only if they are not redundant with existing ones.
- **Use case:** gradual context growth while keeping prior summaries intact.
- **Pros:** preserves history, avoids accidental overwrites.
- **Cons:** may accumulate near-duplicates if redundancy heuristic fails.

## replaceOnConflict
- **Behavior:** new parcels replace existing ones when summaries or tags appear to match.
- **Use case:** prefer most recent or refined summaries when conflicts arise.
- **Pros:** keeps memory concise and up to date.
- **Cons:** prior details can be lost if replacements are incorrect.

The default strategy is `appendWithRefinement` to maintain a conservative merge until explicitly overridden.
