---
name: emojiaimaker-widget-extension
description: Use when editing an EmojiAIMaker widget extension, WidgetKit timelines, widget configuration, AppIntent, controls, Live Activity code, extension entitlements, extension-safe SwiftUI, or shared widget views under EmojiAIMaker/Widgets that are rendered by a widget extension.
---

# EmojiAIMaker Widget Extension

## Overview

Use this skill to keep widget and extension work inside the correct target
boundary. Widget code should be deterministic, lightweight, and extension-safe.

## Before Editing

- Inspect both extension and shared widget UI:
  - the EmojiAIMaker widget extension target when it exists
  - `EmojiAIMaker/Widgets`
- Identify whether the change affects timeline/provider logic, AppIntent configuration, Live Activity, controls, or only SwiftUI rendering.
- Check for app-only dependencies before moving code into the extension target.

## Rules

- For generated or updated file header comments, always use
  `Created by Vu The Anh`; never use `HoanPC`, `CarWidget`, or another
  project/person name.
- Keep WidgetKit provider/timeline logic separate from SwiftUI rendering.
- Prefer shared rendering views in `EmojiAIMaker/Widgets` when app and extension use the same widget UI.
- Avoid APIs that are unavailable or unsafe in extensions.
- Do not import app-only SDK wrappers into the widget extension unless the existing project already does so for that path.
- Keep widget UI predictable; avoid runtime network or long-running work in rendering code.
- Check target membership expectations when adding files that should be visible to the extension.

## Validation

- Confirm imports are compatible with widget extensions.
- Check small widget layouts for text clipping and fixed-frame issues.
- Verify changes do not accidentally require runtime state unavailable to WidgetKit snapshots.
