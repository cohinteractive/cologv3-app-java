# Routed Context Output Structure

This document describes how routed `ContextParcel` data is written to disk so that other tools can reliably read and process it.

## Folder Hierarchy

The `RoutedContextExporter` writes grouped context files under a configurable base directory (default: `export/context`). Content is organized in the following layout:

```
<base>/
  by_feature/
    <feature_name>/
      context.md
  by_module/
    <module_name>/
      context.md
  misc/               # only when includeUnassigned=true
    unassigned/
      context.md
```

Group names are sanitized by replacing illegal path characters and spaces with underscores.

## File Naming and Format

Each group directory contains a single `context.md` file. The file uses Markdown with simple headers:

```
# <group name>

## Entry 1
<parcel summary>
_Tags:_ tag1, tag2

## Entry 2
...
```

- The top `#` heading repeats the feature or module name.
- Every `## Entry N` block represents one routed `ContextParcel` in order.
- If a parcel has tags, they appear on a line beginning with `_Tags:_`.

While the current exporter writes only Markdown, the same parcel information can be serialized as JSON when needed:

```json
{
  "summary": "Fixed null pointer in loader",
  "mergeHistory": [12, 15],
  "tags": ["bug", "loader"],
  "feature": "search",
  "module": "loader"
}
```

## Example Folder Layout

```
export/context/
  by_feature/
    search/
      context.md
    auth/
      context.md
  by_module/
    ui/
      context.md
    data/
      context.md
  misc/
    unassigned/
      context.md
```

## Consuming Routed Files

1. **Path Discovery**  
   Start at the configured base directory (typically `export/context`). Traverse `by_feature` or `by_module` to locate available groups. Folder names correspond to feature or module identifiers.
2. **Parsing Metadata**  
   - The group name can be read from the folder path or the first `#` heading.  
   - Each `## Entry N` section contains the parcel summary text.  
   - A trailing `_Tags:_` line lists any tags associated with that parcel.
3. **Skipping or Aggregating Content**
   - Tools may skip the introductory group heading and treat each `## Entry` block independently.  
   - Unassigned parcels live under `misc/unassigned`; summarizers may choose to aggregate or discard them depending on context.

The structure is intentionally simple so that both humans and automated agents can parse the routed context without additional metadata files.
