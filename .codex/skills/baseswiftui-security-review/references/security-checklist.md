# BaseSwiftUI security checklist

## Authentication and authorization

- Tokens use Keychain or an approved secure store in production.
- Refresh is single-flight, bounded, cancellable, and limited to protected
  requests; logout clears every credential copy.
- Authorization decisions are server-enforced. Client role/entitlement state
  controls presentation only.

## Input and transport

- URLs, route parameters, deep links, Remote Config values, filenames, MIME
  types, and decoded payloads are validated before use.
- Production endpoints use HTTPS and no certificate-validation bypass ships.
- Redirects and WebView navigation do not carry credentials to a new origin.
- Upload size/type/content and local file scope are constrained.

## Data and privacy

- Logs, analytics, crash reports, traces, screenshots, previews, and clipboard
  paths exclude tokens and sensitive payloads.
- Client-facing models are built from an allowlist of safe fields; type casts or
  UI hiding are not redaction.
- Cache/persistence has least retention, clear-on-account-removal behavior, and
  suitable file protection.
- Privacy manifest and usage descriptions match actual SDK/API behavior.

## Verification

- Add negative cases for rejected tokens, repeated 401, malicious/deep-link
  inputs, cross-origin redirects, oversized/invalid uploads, and secret-bearing
  responses where applicable.
- Confirm Release behavior separately from DEBUG logging and diagnostics.
