# Figma visual validation

Read this for `compare`, pixel-exact work, multi-screen flows, or when the fast
path has ambiguous visual evidence. Skip it for routine single-screen
implementation, analysis-only, and asset-only work.

Do not select a Simulator destination, build, boot, run, or capture Simulator
output unless the user explicitly requests Simulator validation. A `compare`
or pixel-exact request alone does not grant Simulator use.

## Evidence

1. Keep the Figma MCP screenshot for the exact selected node as the design
   reference.
2. Without an explicit Simulator request, compare Figma evidence with the
   implementation structure and report that runtime visual validation did not
   run. When Simulator validation is explicitly requested, build and run the
   relevant screen on the requested device(s), then capture with:

   ```sh
   xcrun simctl io booted screenshot /private/tmp/baseswiftui-actual.png
   ```

3. Compare the same state, content, locale, appearance, and safe-area context.
   Never present unlike states as a pixel comparison.

## Comparison order

Check hierarchy and missing regions first, then outer geometry, spacing,
typography, color/opacity, radius/borders/shadows, asset glyph geometry, safe
areas, overlays, and scroll behavior. Fix high-area structural differences
before small decorative differences.

Use `sips` only for deterministic inspection or dimension normalization when
available. If no image-diff tool is installed, perform a structured visual
comparison and say that no numeric pixel-diff score was produced; do not add a
package dependency or invent a percentage.

Also validate compact width, long text, Dynamic Type implications, touch
targets, VoiceOver labels/order, Reduce Motion, loading/content/empty/error,
and every route, sheet, dismissal, retry, and back edge present in a functional
flow.

Report the device/state compared, confirmed differences fixed, remaining
ambiguities, and whether validation was visual-only or tool-measured.
