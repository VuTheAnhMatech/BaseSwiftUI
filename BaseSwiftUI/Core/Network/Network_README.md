# BaseSwiftUI Network Guide

The network base uses Alamofire, async/await, typed `Decodable` responses,
request interception, refresh coordination, multipart upload, array responses,
business-response validation, cancellation, and request/response logging.

## Main types

- `APIEnvironment`: base URL selection; current URLs are placeholders.
- `APIRequestType`: typed request contract and associated `Response`.
- `APIServiceProtocol` / `APIService`: request, array, and multipart execution.
- `OAuth2Handler`: authorization header injection and coordinated 401 refresh.
- `TokenStoreProtocol`: token persistence boundary.
- `BusinessResponseValidatable`: maps successful HTTP responses with failed
  business codes to `NetworkError.business`.
- `NetworkError`: normalized transport, HTTP, business, decoding, cancellation,
  and underlying errors.

## Typed request

```swift
struct UserDetailRequest: APIRequestType {
    typealias Response = BaseSingleResponse<User>

    let userID: Int

    var path: String { "/users/\(userID)" }
    var method: HTTPMethod { .get }
}
```

Call the service from a Service/Repository layer, never directly from a
SwiftUI View:

```swift
let response = try await apiService.request(UserDetailRequest(userID: 1))
```

Use `requestArray` only when the response root is an array. Use
`uploadMultipart` with `MultipartDataExt` for file parts.

## Configuration requirements

1. Replace empty URLs in `APIEnvironment` before making real requests.
2. Provide an `AuthRefresherProtocol` implementation when 401 refresh is
   required. The coordinator already deduplicates concurrent refresh work.
   Before production use, ensure retry policy attempts refresh at most once per
   request and only for endpoints that require authorization; otherwise a
   rejected replacement token or a public 401 can create a refresh loop.
3. Register the selected `APIServiceProtocol` implementation through Factory
   when a feature needs networking. Avoid relying on `APIService.shared` in new
   feature code.
4. Set `requiresAuthorization = false` for public endpoints.
5. Adjust `BaseResponse` coding keys and business-success rules to match the
   backend contract.

## Security

TokenStore stores the access/refresh pair atomically in a Keychain generic-password
item using AfterFirstUnlockThisDeviceOnly accessibility. Its service is namespaced
by bundle ID. The token-store Factory registration remains overridable.

Legacy UserDefaults tokens migrate on read only when no secure item exists. They
are removed after a successful secure write; failed migration preserves them.
Existing secure values take precedence. Read/decode errors return no token and
never fall back to stale plaintext credentials.

save/clear throw on storage failures; callers must handle them. OAuth2Handler only
retries after save succeeds. A failed clear suppresses token reads in the current
process and retries deletion on later reads. Callers must handle a logout deletion
failure before considering persistent logout complete across process restarts.
Storage tests use isolated doubles; real Keychain accessibility and device lock
behavior need signed-device validation.

- Never log authorization headers, refresh tokens, credentials, or sensitive
  response bodies. `LoggerNetwork` currently redacts selected headers but may
  print small response bodies in DEBUG; disable body logging or add
  field/endpoint-aware redaction for authentication and personal data.
- Never commit real base URLs containing credentials or local secret config.
- Do not place refresh or request logic in Views.
- Preserve cancellation and acceptable status-code validation when extending
  `APIService`.
