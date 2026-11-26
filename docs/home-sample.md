# Home sample

Home loads `https://jsonplaceholder.typicode.com/posts` without credentials.
Failures stay visible with a retry action; no fake fallback hides an API error.

## Flow

1. `Presentation/Screens/Home/HomeView` renders state and attaches its Container.
2. `HomeContainer.dispatchSystem(.onAppear)` starts the load; the Container owns
   cancellable work and `BaseDataSource<HomeItem>`.
3. `Domain/UseCases/LoadHomePosts` consumes HomePostRepository, removing blank
   titles and duplicate IDs while preserving response order.
4. `Data/Repositories/RemoteHomePostRepository` consumes HomePostService and maps
   HomePostDTO to Domain HomePost after checking cancellation.
5. `Data/Services/Home/RemoteHomePostService` sends HomePostsRequest through
   Core/Network APIServiceProtocol, returning decoded DTOs.
6. Home maps Domain posts to UI-owned HomeItem. Selection emits a navigate Effect;
   the View calls Environment router. HomeDetailView calls router.goBack().

Paths are relative to BaseSwiftUI. Core/DI splits registration by Service,
Repository, UseCase and Screen; AppRouteFactory constructs the routed screen.
The public API uses no auth refresher or event monitors, and a 20-second timeout.

## Lifecycle

- Repeated loads during a request do not duplicate work.
- A successful list or empty result survives returning from detail.
- Retry explicitly reloads. Errors do not become empty success.
- attachContainer cancels owned work on disappearance; cancelled results/errors
  are not published. Returning after cancellation can restart the load.
- The task captures its UseCase independently and Container weakly.
- DTOs stay in Data, business entities in Domain, UI items in Presentation.

## Verification

`python3 scripts/test_core_behavior.py` covers domain filtering, Home's injected
UseCase and navigation Effect, cancellation/task identity and navigation state.
It does not call the live API or exercise native animations. Device checks should
cover online/offline retry, empty result, Back preserving the list, cancellation
on dismissal, large text and VoiceOver. Simulator checks require explicit request.
