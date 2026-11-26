"""Apply the two-screen starter only to a copied template, before project rename."""
from pathlib import Path
import argparse
import shutil

TEMPLATE = Path(__file__).resolve().parents[1]
OVERLAY = TEMPLATE / "scripts/starter"
SWIFT_FILES = (
    "Core/Navigation/AppRoute.swift",
    "Core/Navigation/AppRouteFactory.swift",
    "Core/DI/AppDIFactory.swift",
    "Core/DI/ScreenDIFactory.swift",
    "Presentation/Screens/Home/HomeContainer.swift",
    "Presentation/Screens/Home/HomeView.swift",
    "Presentation/Screens/Splash/SplashView.swift",
)
REMOVE = (
    "BaseSwiftUI/Presentation/Screens/TranslationDemo",
    "BaseSwiftUI/Presentation/Screens/WallpaperPaywall",
    "BaseSwiftUI/Presentation/Screens/Home/HomeDetailView.swift",
    "BaseSwiftUI/Presentation/Screens/Home/HomeItem.swift",
    "BaseSwiftUI/Resources/Assets.xcassets/TranslationDemo",
    "BaseSwiftUI/Resources/Assets.xcassets/WallpaperPaywall",
    "BaseSwiftUI/Resources/Colors.xcassets/TranslationDemo",
    "BaseSwiftUI/Resources/Colors.xcassets/WallpaperPaywall",
    "docs/home-sample.md",
    "docs/translation-adaptive-demo.md",
    "docs/wallpaper-paywall-demo.md",
    # These exercise the upstream demos/generator/canonical launcher, not an app.
    "scripts/test_core_behavior.py",
    "scripts/test_starter_profile.py",
    "scripts/test_bootstrap_launcher.py",
)
# Exact, checked replacements: fail before editing if template contracts drift.
REPLACEMENTS = {
    "README.md": [
        ("- API-backed Home plus existing Translate and wallpaper paywall UI previews",
         "- Splash → minimal Home in Debug and Release; no automatic API requests"),
    ],
    "docs/architecture.md": [
        ("- Keep current assets, UI previews and the public API Home sample. Debug opens\n  Translate with the paywall preview; Release opens Home after Splash.",
         "- Start with Splash → minimal Home in every configuration. Demo screens and\n  their assets are omitted; data layers remain available for future features."),
    ],
    "BaseSwiftUI/Core/DI/README.md": [
        ("through ScreenDIFactory's resolver closure.", "through ScreenDIFactory.registry."),
        ("composition tests. ScreenDIFactory also accepts a UseCase resolver for isolated\nhost tests. It returns fresh Containers without launching requests at construction.",
         "composition tests. ScreenDIFactory returns fresh Containers. Splash and Home\nhave no data dependencies; add UseCase injection when a feature needs data."),
    ],
    "BaseSwiftUI/Core/Navigation/README.md": [
        ("router.navigate(to: .wallpaperPaywall, .modal)", "router.navigate(to: .home, .modal)"),
        ("The host regression script tests", "The upstream base's host regression script tests"),
    ],
    "BaseSwiftUI/Core/Container/README.md": [
        ("See Home for the complete data flow and Splash for a local lifecycle/effect flow.",
         "Home is a minimal state-only screen. Splash illustrates a local lifecycle/effect\nflow. Domain, Data and Factory registrations remain available for data features."),
    ],
    "BaseSwiftUI/Presentation/DataSource/BaseListView_README.md": [
        ("See `Presentation/Screens/Home/HomeContainer.swift` for the executable example: it receives\n`LoadHomePostsUseCase`, maps domain posts into presentation `HomeItem` values,\nupdates its data source, and subscribes to `selectedValue` to send `.select`.\nSelection pushes `.detail(item)` on the existing router. See\n`docs/home-sample.md` for loading, errors, retry, cancellation, and DI.",
         "A data feature's Container receives a UseCase, maps domain entities into UI\nitems, owns the data source and translates selection into an Intent/Effect.\nThe View handles navigation Effects with its Environment router. The starter\nHome is intentionally minimal and does not fetch data or own a list."),
    ],
    ".codex/skills/baseswiftui-iphone-duo/references/layout-patterns.md": [
        ("`HomeView`/`HomeContainer` under `BaseSwiftUI/Presentation/Screens/Home` illustrate the\nbase's data source, selection intent and load/cancellation. HomeContainer emits\nnavigation Effects; HomeView receives them and uses its Environment router;\nthey are not already a Duo split implementation.",
         "The generated `HomeView`/`HomeContainer` are minimal state-only examples.\nFor data features, keep the data source, selection and cancellable work in the\nContainer; emit navigation Effects and handle them in the View's Environment\nrouter. The starter does not implement a Duo split presentation."),
        ("moving boundaries: the Home sample, for example, cancels loading on disappear.",
         "moving boundaries: BaseContainer cancels owned work on disappear."),
    ],
    "docs/ci-options.md": [
        ("Home\n  success/error/empty/retry", "data-feature\n  success/error/empty/retry (khi đã triển khai)"),
        ("mở Home, lỗi/thử lại, chọn item, Back; sau đó sheet/dismiss.",
         "Splash → Home; thêm lỗi/thử lại, chọn item, Back và sheet/dismiss khi có feature tương ứng."),
    ],
}


def replace_checked(text, old, new, path):
    if old in text:
        return text.replace(old, new)
    if new in text:  # Reapplying to an already prepared starter is harmless.
        return text
    raise ValueError(f"Starter contract changed: {path}: {old[:70]!r}")


def section(text, start, end, replacement):
    a = text.index(start)
    b = text.index(end, a)
    return text[:a] + replacement + "\n\n" + text[b:]


def safe_path(root, relative):
    path = root / relative
    # Never follow symlinks while replacing or deleting copied content.
    for candidate in (path, *path.parents):
        if candidate == root:
            break
        if candidate.is_symlink():
            raise ValueError(f"Symlink in starter path: {candidate}")
    if path.is_dir() and any(p.is_symlink() for p in path.rglob("*")):
        raise ValueError(f"Symlink in starter directory: {path}")
    return path


def prepare(root):
    writes = {}
    for relative in SWIFT_FILES:
        relative = "BaseSwiftUI/" + relative
        target = safe_path(root, relative)
        if not target.is_file():
            raise ValueError(f"Missing starter input: {target}")
        writes[target] = (OVERLAY / relative).read_text()
    for relative, replacements in REPLACEMENTS.items():
        target = safe_path(root, relative)
        text = target.read_text()
        for old, new in replacements:
            text = replace_checked(text, old, new, relative)
        writes[target] = text
    readme = root / "README.md"
    writes[readme] = section(writes[readme], "## Home sample and CI planning", "## Generate and build", """## Home sample and CI planning

This generated app starts with Splash → Home in Debug and Release. Home only
renders its title; it does not load the sample API or open a demo/paywall.
All architecture layers, shared components, agent guidance and skills remain.
The Domain/Data sample registrations are available but unused by startup.

The original demo screens and their regression tests live in the upstream
BaseSwiftUI template repository. See [CI options](docs/ci-options.md) for planning;
application CI and test targets have not been configured.""")
    # Bootstrap distribution instructions belong to the upstream base. Keeping
    # them here would rename the canonical launcher path to a nonexistent file.
    bootstrap_heading = "## Create a new project from this template"
    if bootstrap_heading in writes[readme]:
        writes[readme] = writes[readme].split(bootstrap_heading)[0].rstrip() + "\n"
    architecture = root / "docs/architecture.md"
    text = writes[architecture]
    writes[architecture] = text[:text.index("## Verification")] + """## Verification

Build the workspace for generic iOS after feature changes. The upstream base
keeps host regressions for its demo flows; those demo-dependent tests are not
included in this starter. Add behavior checks for the features you implement.
Simulator testing requires an explicit request; compile success is not UI evidence.
"""
    for relative in REMOVE:
        safe_path(root, relative)
    return writes


def apply(root):
    root = root.resolve(strict=True)
    if root == TEMPLATE or TEMPLATE in root.parents or root in TEMPLATE.parents:
        raise ValueError("Starter destination must be outside the source template")
    writes = prepare(root)  # Validate every input and removal before any mutation.
    for target, text in writes.items():
        target.write_text(text)
    for relative in REMOVE:
        path = root / relative
        if path.is_dir():
            shutil.rmtree(path)
        elif path.exists():
            path.unlink()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", nargs="?", type=Path)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    try:
        if args.check:
            prepare(TEMPLATE)
            print("Starter profile inputs validated.")
        elif args.destination:
            apply(args.destination)
            print("Applied starter profile: Splash → minimal Home (no demos).")
        else:
            parser.error("provide a copied template destination or --check")
    except (OSError, ValueError) as error:
        parser.exit(1, f"Starter profile error: {error}\n")


if __name__ == "__main__":
    main()
