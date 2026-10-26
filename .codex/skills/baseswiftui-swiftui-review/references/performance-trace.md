# BaseSwiftUI Performance Trace

Use trace evidence to localize a performance problem before proposing code
changes. Recording and analysis do not authorize edits.

## Workflow

1. Read `recording.md` when capturing a trace.
2. Read `analysis.md` when a `.trace` exists.
3. Confirm target and scope: launch, attach, device/simulator, interaction, and
   time window. Prefer app-scoped capture.
4. For new recordings, inspect available templates/devices with
   `xcrun xctrace list`. Analysis of an existing trace needs no device discovery.
5. Export the trace table of contents before choosing schemas:

   ```sh
   xcrun xctrace export --input /path/session.trace --toc
   ```

6. Correlate hangs/hitches with main-thread stacks, SwiftUI updates, signposts,
   and user-code symbols. Match symbols to repository files; do not infer a
   source line from a system frame alone.
7. Return findings ordered by user impact, evidence, suspected owner, and the
   smallest verification/fix. Edit only when requested and after the root
   code-intelligence gate.

Simulator use requires an explicit user request, including selecting a
Simulator destination for recording. Existing trace analysis needs no build.

## Privacy

- App-scoped recording is the default. System-wide capture may include other
  applications and requires explicit user approval.
- Do not pass secrets through command arguments or expose trace content that is
  unrelated to the scoped app diagnosis.
- Do not overwrite an existing trace bundle.
