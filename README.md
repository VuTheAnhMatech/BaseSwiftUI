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
- A small Home feature demonstrating the expected folder structure
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
    Domain/Entities/
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

### Use a committed template snapshot

Copy `scripts/BaseSwiftUI.sh` to `~/Desktop/SDKBase/`. From the destination
project folder, run:

```sh
sh /Users/vutheanh/Desktop/SDKBase/BaseSwiftUI.sh
```

The launcher prefers the committed HEAD of the nearby
`~/Desktop/Githubs/BaseSwiftUI` checkout (or its own parent when run from this
repo's `scripts/`). It exports a clean snapshot, including committed skills
and references, and validates the agent setup before project generation.
Uncommitted changes and ignored, untracked files are not included.

Without a nearby checkout it downloads GitHub `main`. Use `--remote` to force
that source, or `--local /path/to/BaseSwiftUI` to select a checkout explicitly.
Local commits reach the local launcher immediately; remote users receive them
only after they are pushed. Run `--help` for usage. The destination replacement
rules above still apply; the launcher refuses to run in the source checkout.
