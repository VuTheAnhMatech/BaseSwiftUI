# Widgets

This folder follows the proven CatTranslate pattern for:

- visual components shared by multiple screens or Containers;
- generic SwiftUI layouts and UIKit/SwiftUI view adapters;
- app-wide presentation UI such as overlays and notices.

Feature-specific UI stays beside its screen. Non-visual helpers stay in their
own utility or service layer.

Each widget must:

- expose the smallest reusable input and actions for its category;
- never own a feature Container, networking, persistence, or business logic;
- reuse Base components and design tokens;
- have a real call site and document its file, purpose, inputs/actions, and one
  minimal usage below.

## Catalog

Add one entry per widget:

```text
WidgetName — Purpose
Input: WidgetType or WidgetModel
Actions: onSelect, onDismiss
Usage: WidgetName(model: model, onSelect: { ... })
```
