# Secret and sensitive-data flow

## Storage

- Store production access/refresh tokens in Keychain with the narrowest useful
  accessibility class. Keep non-secret preferences in UserDefaults.
- Avoid duplicating credentials in singleton state, disk caches, analytics
  properties, notifications, widgets, or app-group containers.
- Clear credentials and sensitive caches on logout/account deletion and handle
  refresh replacement atomically.

## Projection and redaction

- Build safe client/UI models by allowlisting fields from decoded responses.
- A `Safe*` name or type cast does not remove secrets.
- Apply redaction before a value reaches logger, analytics, crash reporting, or
  tracing; presentation-time hiding is too late.
- Cover error descriptions, request retries, decoder failures, and small DEBUG
  response bodies.

## Third-party SDKs

Inventory data sent to analytics, ads, crash reporting, purchase, AI, and
attribution SDKs. Confirm consent, declared purpose, retention, and privacy
manifest entries. Never send raw prompts, user content, stable identifiers, or
credentials merely because an SDK accepts arbitrary metadata.
