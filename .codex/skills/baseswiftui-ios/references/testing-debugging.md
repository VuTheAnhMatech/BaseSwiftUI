# Conditional testing and debugging

Read this only for an explicit bug, test, regression, or test-gap task.

## Debugging

1. Reproduce or define the failing state, expected result, and smallest affected
   flow. Do not edit from an error string alone.
2. Use the installed `gitnexus-debugging` workflow to trace callers, state, and
   execution flow. Follow the root code-intelligence gate before shared edits.
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

Run only the narrow relevant tests first, then the workspace build when Swift
code changed. Report commands, results, and untested risk.
