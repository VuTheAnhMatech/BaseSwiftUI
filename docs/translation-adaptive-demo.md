# Adaptive Translate UI sample

Source: [Figma node 13467:10823](https://www.figma.com/design/dV6Yl8gvPAjDclEGBPLEVq/-GTA--UI-ver-4.4?node-id=13467-10823).

Run the **Debug** scheme from `BaseSwiftUI.xcworkspace`. After splash, the app
opens the [wallpaper paywall preview](wallpaper-paywall-demo.md); close it to reach
Translate. Tap Settings to reopen the IAP preview; its X dismisses back to the
same Translate draft. Hold Settings → **Open API sample** presents the existing Home
sample; Done dismisses it. Release continues to open Home.

## What this demonstrates

- Compact windows retain the supplied phone composition: language controls,
  editor, input tools, Dynamic Island card, and bottom actions.
- At 800pt and wider, the editor and supporting card use two columns. Language
  controls and overall content have readable maximum widths. This breakpoint
  comes from the panes' space needs, not a device name or orientation.
- Accessibility text uses one column. Short windows keep the page scrollable;
  long drafts scroll inside the editor. The bottom actions use the safe area.
- A single `@StateObject` Container owns the draft, languages, and preview toggle.
  `AnyLayout` changes axis without separate editor branches or size-based IDs.
- Four Xcode Preview declarations cover phone, wide, short, and large-text
  configurations. They are inspection entry points, not executed test results.

Text editing, language selection and swapping work locally. Translation,
offline downloads, photo/camera input, recording, history, AI and Live Activities
are **not connected**. Their actions disclose the preview state. The toggle
only changes local UI; it does not read the clipboard or enable Dynamic Island.
Drafts are retained during layout changes, not persisted across app launches.

## Design mapping

The screen reuses BaseText, BaseTextEditor, BaseButton and bundled Inter fonts.
Ten original Figma SVG icons are stored in the TranslationDemo asset namespace.
Photo input uses the exact SF Symbol named in the design. New scoped colors
preserve Figma values where existing project tokens differ; existing white and
5% black tokens are reused. Glass uses the base button and a native capsule
surface on iOS 26+, with a material fallback on older systems. This node supplies
a light appearance only, so the demo explicitly uses that appearance.

The wide composition is an adaptation, not an additional Figma design. System
status bars, keyboard and home indicators remain system-owned. Available
height adjusts the editor's flexible area instead of scaling all controls.

## Validation and remaining checks

Generic iOS Debug build passed using Xcode 26.4, minimum iOS 17, targeting iPhone
and iPad. A Simulator Debug build also passed using Xcode 27.0 on 2026-10-30.
The app was installed, launched and captured on:

| Simulator | Runtime | Observed initial layout |
| --- | --- | --- |
| iPhone SE (3rd generation) | iOS 26.4 | One column |
| iPhone 17 Pro Max | iOS 26.4 | One column |
| iPad Pro 11-inch (M5) | iPadOS 27.0 | Two columns |

Runtime captures exposed near-transparent imported colors: asset alpha `1`
needed normalized decimal notation `1.000`. All demo color alpha values were
normalized, both builds repeated, and all three apps relaunched and recaptured.
Captures are stored locally in `/private/tmp/BaseSwiftUI-simulator-captures/`.
The installed device-type/runtime inventory contains no iPhone Duo profile,
so Duo could not be launched. No automated pixel diff, interactive resize,
keyboard, accessibility or fold-pose checks were performed in this run.

Before treating this as production-ready, exercise:

1. Type a long draft, then continuously resize between one and two columns;
   check draft, selection, focus and text scroll position.
2. Use a short/narrow iPad window with keyboard open; reach every control and
   dismiss the keyboard. Repeat with accessibility text and VoiceOver.
3. Compare the compact screen with Figma on a real runtime, including SVG
   rendering, glass, safe areas and font metrics.
4. Open the API sample, navigate to detail, go Back and dismiss the sheet.
5. On an available Duo SDK/runtime, check outer/inner and folded arrangements
   and any reserved regions. This sample implements available-space adaptation
   only; it does not query hinge geometry or claim fold-region avoidance.

The new feature and Factory files are isolated under TranslationDemo. Remove
the Debug branch in ContentView to restore Home as the initial screen in every
configuration; no shared Base component needs changing.
