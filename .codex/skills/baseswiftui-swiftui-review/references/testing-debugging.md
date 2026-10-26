# Conditional testing and debugging

Read this only for an explicit bug, test, regression, or test-gap task.
For diagnosis or a test plan only, report without edits, builds, or indexing.
A request to find/fix a bug authorizes a scoped fix; a question does not.

## Debugging

1. Reproduce or define the failing state, expected result, and smallest affected
   flow. Do not edit from an error string alone.
2. Inspect the named code and direct callers first. Use indexed GitNexus
   queries when a cross-file flow needs them; a local diagnosis does not load
   another skill or index the app automatically. Follow the root
   code-intelligence gate before shared edits.
3. Confirm the cause in source or runtime evidence. Separate the root cause
   from nearby cleanup.
4. Apply the smallest architecture-compatible fix, then exercise the original
   failure and its closest negative path.

## Testing

- Follow the existing test target, framework, naming, and fixture style; do not
  add a test library solely for one feature.
- Prioritize state transitions, route ownership, mapping, repository/use-case
  behavior, cancellation, errors, and regression boundaries. Avoid brittle
  pixel or implementation-detail assertions.
- For UI flows, cover loading, content, empty, error/retry, cancellation, and
  back/dismiss when those states exist.
- If the project lacks a suitable test target or seam, report the precise gap
  and verify with the workspace build plus a focused manual scenario. Do not
  claim unexecuted tests passed.

Run only the narrow relevant tests first when execution is in scope, then a
`generic/platform=iOS` workspace build when Swift code changed. Never select,
boot, or run Simulator unless explicitly requested. If tests require it and no
authorized physical-device destination exists, report tests as not run and
give the focused manual scenario. Report commands, results, and untested risk.
