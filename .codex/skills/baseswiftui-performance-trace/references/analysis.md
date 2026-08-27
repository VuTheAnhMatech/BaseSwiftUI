# Instruments analysis

## Evidence order

1. Confirm run, duration, process, and available schemas from the TOC.
2. Find hangs and animation hitches in the requested time window.
3. Check whether the main thread is CPU-bound or waiting on I/O, locks, XPC, or
   synchronous work.
4. Inspect user-code symbols and overlapping SwiftUI view updates.
5. Check invalidation sources: broad observed state, unstable identity,
   environment/AppStorage fan-out, type replacement, and layout feedback.
6. Check image decoding, formatting, filtering/sorting, persistence, and
   networking initiated from render or main-thread paths.

## Interpretation

- Dense main-thread samples with a hot user symbol suggest CPU work.
- Sparse running samples during a hang suggest waiting/blocking; the visible
  stack may identify the initiator rather than the blocked work.
- A repeated expensive view is a symptom until its invalidation source is
  identified.
- System-only hitches without matching app work are residual risk, not proof of
  an app defect.

Report the trace time/window, duration/count, matching symbol/view, and source
location when available. Route static SwiftUI remediation patterns to
`baseswiftui-swiftui-review`.
