"""Regression checks for starter content, source isolation and preflight safety."""
import hashlib
from pathlib import Path
import shutil
import tempfile
import unittest

import apply_starter_profile as profile


def digest(root):
    return {
        str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
        for p in root.rglob("*") if p.is_file()
    }


class StarterProfileTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="starter-profile-")
        self.addCleanup(self.temp.cleanup)
        self.destination = Path(self.temp.name) / "MinimalApp"
        self.destination.mkdir()
        for name in ("BaseSwiftUI", "docs", ".codex", "scripts"):
            shutil.copytree(profile.TEMPLATE / name, self.destination / name)
        shutil.copy2(profile.TEMPLATE / "README.md", self.destination / "README.md")

    def test_two_screen_output_preserves_layers_and_skills(self):
        original = digest(profile.TEMPLATE / "BaseSwiftUI")
        skills = digest(self.destination / ".codex")
        profile.apply(self.destination)
        app = self.destination / "BaseSwiftUI"
        self.assertEqual({p.name for p in (app / "Presentation/Screens").iterdir()},
                         {"Splash", "Home"})
        swift = "\n".join(p.read_text() for p in app.rglob("*.swift"))
        for demo in ("TranslationDemo", "WallpaperPaywall", "HomeDetailView", "HomeItem",
                     ".translationDemo", ".wallpaperPaywall"):
            self.assertNotIn(demo, swift)
        for name in profile.REMOVE:
            self.assertFalse((self.destination / name).exists(), name)
        for layer in ("Core/Container", "Core/Network", "Core/CoreData", "Core/DI",
                      "Domain/Entities", "Domain/Repositories", "Domain/UseCases",
                      "Data/DTOs", "Data/Repositories", "Data/Services",
                      "Presentation/DataSource", "Presentation/Views", "Utils", "Widgets", "Libs"):
            self.assertTrue((app / layer).is_dir(), layer)
        for layer in ("Domain", "Data", "Widgets", "Libs", "Core/Network", "Core/CoreData"):
            self.assertEqual(digest(app / layer), digest(profile.TEMPLATE / "BaseSwiftUI" / layer))
        result_skills = digest(self.destination / ".codex")
        self.assertEqual(skills.keys(), result_skills.keys())
        changed = [p for p in skills if skills[p] != result_skills[p]]
        self.assertEqual(changed, ["skills/baseswiftui-iphone-duo/references/layout-patterns.md"])
        self.assertEqual(original, digest(profile.TEMPLATE / "BaseSwiftUI"))
        splash = (app / "Presentation/Screens/Splash/SplashView.swift").read_text()
        self.assertIn("router.navigate(to: .home, .asRoot)", splash)
        self.assertNotIn("#if DEBUG", splash)
        home = (app / "Presentation/Screens/Home/HomeContainer.swift").read_text()
        for call in ("loadPosts", "execute()", "dispatchSystem", "runTask"):
            self.assertNotIn(call, home)
        readme = (self.destination / "README.md").read_text()
        self.assertIn("Home only\nrenders its title", readme)
        for missing in ("docs/home-sample.md", "docs/wallpaper-paywall-demo.md",
                        "docs/translation-adaptive-demo.md", "scripts/test_starter_profile.py"):
            self.assertNotIn(missing, readme)

    def test_reapplication_is_idempotent(self):
        profile.apply(self.destination)
        before = digest(self.destination)
        profile.apply(self.destination)
        self.assertEqual(before, digest(self.destination))

    def test_source_and_overlapping_destinations_are_rejected(self):
        for path in (profile.TEMPLATE, profile.TEMPLATE / "scripts", profile.TEMPLATE.parent):
            with self.assertRaisesRegex(ValueError, "outside the source"):
                profile.apply(path)

    def test_contract_drift_fails_without_partial_changes(self):
        target = self.destination / "BaseSwiftUI/Core/DI/README.md"
        target.write_text("Changed contract")
        before = digest(self.destination)
        with self.assertRaisesRegex(ValueError, "contract changed"):
            profile.apply(self.destination)
        self.assertEqual(before, digest(self.destination))

    def test_missing_input_fails_without_partial_changes(self):
        (self.destination / "BaseSwiftUI/Core/DI/ScreenDIFactory.swift").unlink()
        before = digest(self.destination)
        with self.assertRaisesRegex(ValueError, "Missing starter input"):
            profile.apply(self.destination)
        self.assertEqual(before, digest(self.destination))

    def test_symlink_cannot_redirect_writes_to_source(self):
        target = self.destination / "BaseSwiftUI/Core/DI/AppDIFactory.swift"
        target.unlink()
        source = profile.TEMPLATE / "BaseSwiftUI/Core/DI/AppDIFactory.swift"
        target.symlink_to(source)
        before = source.read_bytes()
        with self.assertRaisesRegex(ValueError, "Symlink"):
            profile.apply(self.destination)
        self.assertEqual(before, source.read_bytes())


if __name__ == "__main__":
    unittest.main()
