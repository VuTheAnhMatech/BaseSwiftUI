# BaseSwiftUI

Reusable iOS starter project extracted from EmojiAIMaker's proven foundations.

## Included

- SwiftUI app targeting iOS 17+
- MVI containers with state and intent boundaries
- Factory dependency injection
- Typed navigation supporting push, sheet, fullscreen cover, and fade cover
- BaseDataSource collection views
- Reusable text, button, input, navigation, loading, and web-view components
- Alamofire-based networking foundation
- UserDefaults property wrapper
- Plus Jakarta Sans and reusable color assets
- An API-backed Home sample with loading, error/retry, empty state, and typed detail navigation
- Filesystem-synchronized Xcode folders, matching the EmojiAIMaker project

## Project structure

```text
BaseSwiftUI/
  Base/
    AppRouter/
    CoreData/
    DataSource/
    Helpers/
    MVI/
    Network/
    UserDefault/
    Views/
  Exts/
  Helper/
  Libs/
  MT-CleanArchitecture/
    Domain/{Entities,Repositories,UseCases}/
    Data/{DTOs,Repositories}/
  MT-Factory/
  MT-Screens/
  Resources/
  Utils/
  Widgets/
```

## Intentionally excluded

- EmojiAIMaker branding and feature screens
- Gemini/backend/App Attest code
- Firebase, ads, tracking, Remote Config, and analytics
- IAP SDK and purchase flows
- Messages extension and app-specific entitlements
- Private binary frameworks; dependencies use CocoaPods

## Home sample and CI planning

See [Home sample](docs/home-sample.md) for the complete Container → UseCase →
Repository → API flow. The sample uses the public JSONPlaceholder posts API;
it needs internet access but no account or API key. Errors remain visible with
a retry action; no successful response is silently replaced with fake content.

See [CI options](docs/ci-options.md) for a proposed adoption path. This document
is advice only; application CI and new test targets have not been configured.

## Generate and build

```sh
ruby scripts/generate_project.rb
pod install
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -workspace BaseSwiftUI.xcworkspace -scheme BaseSwiftUI \
  -configuration Debug -destination generic/platform=iOS \
  -derivedDataPath /private/tmp/BaseSwiftUIDerivedData \
  CODE_SIGNING_ALLOWED=NO build
```

## Create a new project from this template

Create a folder whose name is a valid Swift identifier, open Terminal in that
folder, then run:

```sh
sh /Users/vutheanh/Desktop/Githubs/BaseSwiftUI/scripts/create_project.sh
```

The script copies the template, renames the app, target, scheme and project,
sets the bundle identifier to `com.emoji.ai.maker.stickermaker`, then runs
`pod install`. It initializes a fresh `main` Git repository with a baseline
commit so GitNexus can index immediately. It does not copy template Git
history, generated build files, Pods, Xcode user data, or `.team-tools/.env`.

If the destination already contains an app or Xcode project, its existing
contents are deleted before generation. No backup is created. An existing
`.git` directory is preserved. For safety, a non-empty destination must contain
a top-level `.xcodeproj`; unrelated non-empty folders are rejected.

### Use the latest published template

Copy `scripts/BaseSwiftUI.sh` to `~/Desktop/SDKBase/`. From the destination
project folder, run:

```sh
sh /Users/vutheanh/Desktop/SDKBase/BaseSwiftUI.sh
```

Every default run downloads the latest pushed GitHub `main`, including skills,
references, and the project bootstrap script. A nearby local checkout does not
override that source. The launcher prints the selected commit and validates
agent setup before generation. Internet access is required; download failure
stops before generation without falling back to potentially stale local code.

`--remote` explicitly selects the same default behavior. For an intentional
offline/local snapshot, use `--local /path/to/BaseSwiftUI`: this exports that
checkout's committed HEAD and excludes uncommitted/ignored files. Push new
template commits to `main` before expecting the default launcher to use them.
Run `--help` for usage. The destination replacement rules above still apply;
the launcher refuses to run in the source checkout.
