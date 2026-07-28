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

The script copies the template, renames the app, target, scheme, project and
bundle identifier, then runs `pod install`. It does not copy Git history,
generated build files, Pods, Xcode user data, or `.team-tools/.env`.

If the destination already contains an Xcode project, its existing contents are
moved to a timestamped sibling backup folder first. An existing `.git` directory
is preserved.

### Always use the latest version from GitHub

Copy `scripts/BaseSwiftUI.sh` to a stable location such as the
Desktop. From the destination project folder, run:

```sh
sh /Users/vutheanh/Desktop/BaseSwiftUI.sh
```

The bootstrap script downloads the latest `main` branch from GitHub into a
temporary directory and creates the project from that fresh copy.
