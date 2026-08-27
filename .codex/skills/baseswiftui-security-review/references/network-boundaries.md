# Network and navigation boundaries

## User-controlled destinations

For a URL, host, base URL, deep link, Remote Config destination, WebView link,
or callback:

1. Parse with `URLComponents` or a typed route; reject embedded credentials,
   unexpected schemes, hosts, ports, and malformed encodings.
2. Apply an allowlist when the product knows valid hosts/routes.
3. Revalidate every redirect or navigation decision and strip sensitive headers
   when origin changes.
4. Never let a remote flag silently replace a production API host or widen a
   permission boundary.

Mobile apps are not classic server-side SSRF targets, but unsafe destinations
can still reach local-network services, leak credentials, enable phishing, or
cross app/WebView trust boundaries.

## Uploads and files

- Treat extension and MIME type as hints; validate content, size, pixel count,
  and decode result.
- Use scoped file URLs and avoid path traversal or broad photo/file access.
- Remove metadata when the product does not need it and avoid retaining a
  second sensitive copy after upload.

## TLS

Use platform trust by default. If pinning is a deliberate product requirement,
provide rotation and failure telemetry without logging secrets. Reject any
Release configuration that disables trust evaluation.
