# SwiftUI API scan manifest

Scan only the topic affected by the SDK change or request:

| Topic | Search areas |
| --- | --- |
| Navigation/presentation | `NavigationStack`, `NavigationSplitView`, `NavigationLink`, toolbar, sheet, alert, confirmation dialog |
| State/lifecycle | State wrappers, ObservableObject, task, onChange, scene phase |
| Layout/scroll | safe area, GeometryReader, container-relative layout, scroll position/target/transition |
| Styling/animation | foreground/tint, clipping, animation, transition, phase/keyframe animator |
| Input/focus | FocusState, submit, text input, keyboard behavior |
| Collections | List, ForEach identity, Table, refreshable, search |
| Content | AsyncImage, Text/localization, ShareLink, PhotosPicker, Charts |
| Accessibility | labels, traits, custom content, rotor, chart representation |

For each candidate capture: symbol, source URL/interface, introduced version,
deprecated version, replacement, semantic differences, iOS 17 fallback, and
whether BaseSwiftUI actually uses it. Build warnings outrank generic blog or
upstream-skill advice.
