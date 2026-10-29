# Home sample

Home loads public sample posts from `https://jsonplaceholder.typicode.com/posts`.
It requires internet access, not credentials. The external service has no
availability guarantee for this template; failures show a retry action.
Replace the sample endpoint/repository when building a real product.

## Follow the code

1. `MT-Screens/Home/HomeView.swift` sends `.load` on appearance and renders
   loading, error, empty, or list content using `BaseLazyListView`.
2. `HomeContainer` receives `LoadHomePostsUseCase` through its initializer.
   It owns the task, state, and `BaseDataSource<HomeItem>`.
3. `Domain/UseCases/LoadHomePosts.swift` fetches through `HomePostRepository`,
   checks cancellation, removes blank-title posts and duplicate IDs, preserving
   server order. This gives the use case a concrete feed policy.
4. `Data/Repositories/RemoteHomePostRepository.swift` sends `HomePostsRequest`
   through `APIServiceProtocol.requestArray`, then maps DTOs into domain posts.
5. `Data/DTOs/HomePostDTO.swift` owns decoding and the small DTO-to-domain mapping.
   No separate mapper/service is needed for this one request.
6. The Container maps `HomePost` to UI-owned `HomeItem`. List selection reaches
   the Container through `BaseDataSource.selectedValue`, then pushes
   `AppNavigationRoute.detail(item)`. `HomeDetailView` displays that snapshot
   and uses SwiftUI's dismiss action to return.

Paths above are relative to `BaseSwiftUI`; Domain/Data live under
`MT-CleanArchitecture`. `MT-Factory/FactoryHome.swift` constructs the API,
repository, and use case. `FactoryContainer.swift` injects the use case.
The API uses a custom public base URL, no auth refresher, no event monitors,
and a 20-second request timeout. The request explicitly disables authorization.
Global production API/auth configuration is not changed by this sample.

## Lifecycle and ownership

- Repeated `.load` calls during a request do not start duplicate work.
- A successful result, including an empty array, is retained when returning
  from detail. `.retry` explicitly requests another load.
- Failure shows a user-facing message and a retry button. It does not become
  an empty success or silently fall back to mock content.
- `.disappear` cancels the owned request. Cancellation does not publish an
  error, and a late cancelled result cannot overwrite a later load.
- The task captures the use case independently and the Container weakly.
- DTOs stay in Data; business entities in Domain; UI items in the feature.
  Defaults/fixtures belong beside the model they describe, in its own layer.

## Verification scenarios

The workspace build checks compilation, not these runtime interactions:

| Scenario | Expected behavior |
| --- | --- |
| Open Home online | Loading, then posts with stable server IDs |
| Select a post, then Back | Matching title/body; existing list remains |
| Open offline, then reconnect and Try again | Error then successful list |
| Use a fake use case returning `[]` | Empty state with Reload |
| Send load/retry repeatedly while waiting | One active request |
| Disappear during a slow request | No cancelled result/error published |
| Return after cancellation | New load can complete normally |
| Large text / VoiceOver | Readable content; rows expose an open action |

For deterministic checks, inject a fake `LoadHomePostsUseCase` into the
Container, or a fake `HomePostRepository` into `LoadHomePosts`. Network tests
should stub the API boundary; a public endpoint's uptime must not decide
whether a pull request passes. XCTest/UI-test targets and CI are deferred
pending the CI design decision. Simulator interaction has not been validated
merely by adding this sample.
