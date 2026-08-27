---
name: baseswiftui-performance-trace
description: Record or analyze Instruments traces for BaseSwiftUI hangs, hitches, launch, CPU, main-thread, SwiftUI-update, layout, image, or scrolling problems. Use swiftui-review for source-only performance checks.
---

# BaseSwiftUI Performance Trace

Use trace evidence to localize a performance problem before proposing code
changes. Recording and analysis do not authorize edits.

## Workflow

1. Read `references/recording.md` when capturing a trace.
2. Read `references/analysis.md` when a `.trace` exists.
3. Confirm target and scope: launch, attach, device/simulator, interaction, and
   time window. Prefer app-scoped capture.
4. Inspect available templates/devices with `xcrun xctrace list`.
5. Export the trace table of contents before choosing schemas:

   ```sh
   xcrun xctrace export --input /path/session.trace --toc
   ```

6. Correlate hangs/hitches with main-thread stacks, SwiftUI updates, signposts,
   and user-code symbols. Match symbols to repository files; do not infer a
   source line from a system frame alone.
7. Return findings ordered by user impact, evidence, suspected owner, and the
   smallest verification/fix. Edit only when requested and after GitNexus
   impact analysis.

## Privacy

- App-scoped recording is the default. System-wide capture may include other
  applications and requires explicit user approval.
- Do not pass secrets through command arguments or expose trace content that is
  unrelated to the scoped app diagnosis.
- Do not overwrite an existing trace bundle.
