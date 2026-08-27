---
name: baseswiftui-security-review
description: Audit BaseSwiftUI security/privacy boundaries: tokens, storage, networking, redirects, links, uploads, WebViews, config, logs, permissions, and SDK data. Use for dedicated audits; use swiftui-review for general quality review.
---

# BaseSwiftUI Security Review

Trace sensitive data and untrusted input from source to storage, transport,
logging, presentation, and deletion. Preserve current app architecture; this
skill adds security gates, not a parallel networking layer.

## Required context

1. Read `references/security-checklist.md` for every review.
2. Read `references/network-boundaries.md` for URLs, deep links, WebViews,
   redirects, networking, Remote Config, and uploads.
3. Read `references/secret-data-flow.md` for credentials, personal data,
   storage, logs, analytics, and response projection.
4. Read `BaseSwiftUI/Base/Network/Network_README.md` and inspect the actual
   request/interceptor/token-store path.

## Workflow

1. Define assets, attacker/control surface, entrypoints, trust boundaries, and
   existing mitigations.
2. Trace each source to every sink. Include negative/error/debug paths, not only
   the success path.
3. Use GitNexus taint/PDG evidence when available, then verify findings in code.
4. Require validation at the layer where data enters and again where stale or
   redirected data can cross a new boundary.
5. Report findings first by severity with file/line, exploit or privacy impact,
   evidence, and smallest safe remediation. Distinguish confirmed issues from
   hardening suggestions and missing validation.
6. Implement fixes only when explicitly requested and after the root
   code-intelligence gate.

## BaseSwiftUI known baseline

- The current `UserDefaults` token store is scaffold-only, not production-safe.
- DEBUG response-body logging can expose authentication or personal data even
  when authorization headers are redacted.
- A 401 refresh/retry path must be bounded to one refresh for requests that
  require authorization.
