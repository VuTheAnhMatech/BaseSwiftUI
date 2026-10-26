"""Exercise launcher source selection using disposable Git repositories."""

from pathlib import Path
import os
import shutil
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("BaseSwiftUI.sh")
GIT = shutil.which("git")


class LauncherTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="BaseSwiftUI-launcher-")
        self.root = Path(self.temp.name)
        self.source = self.root / "Githubs/BaseSwiftUI"
        self.target = self.root / "Destination with spaces"
        self.target.mkdir()
        (self.source / "scripts").mkdir(parents=True)
        (self.source / "BaseSwiftUI.xcodeproj").mkdir()
        (self.source / "BaseSwiftUI.xcodeproj/project.pbxproj").write_text("fixture\n")
        (self.source / "value.txt").write_text("committed snapshot\n")
        (self.source / "scripts/create_project.sh").write_text(
            '#!/bin/sh\nset -eu\n'
            'fixture_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)\n'
            'cp "$fixture_root/value.txt" ./generated.txt\n'
        )
        self.git("init", "-q", "-b", "main")
        self.git("add", ".")
        self.git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
                 "-c", "commit.gpgSign=false", "commit", "-qm", "fixture")
        self.sdk = self.root / "SDKBase"
        self.sdk.mkdir()
        self.launcher = self.sdk / "BaseSwiftUI.sh"
        shutil.copy2(SCRIPT, self.launcher)

    def tearDown(self):
        self.temp.cleanup()

    def git(self, *args):
        subprocess.run([GIT, "-C", str(self.source), *args], check=True, capture_output=True)

    def run_launcher(self, *args, cwd=None, env=None, success=True):
        result = subprocess.run(["sh", str(self.launcher), *map(str, args)],
                                cwd=cwd or self.target, env=env, capture_output=True, text=True)
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result

    def test_auto_uses_committed_local_snapshot(self):
        (self.source / "value.txt").write_text("uncommitted edit\n")
        result = self.run_launcher()
        self.assertIn("committed local", result.stdout)
        self.assertEqual((self.target / "generated.txt").read_text(), "committed snapshot\n")
        self.assertEqual((self.source / "value.txt").read_text(), "uncommitted edit\n")

    def test_explicit_local_path_with_spaces(self):
        relocated = self.root / "Template with spaces"
        self.source.rename(relocated)
        self.run_launcher("--local", relocated)
        self.assertTrue((self.target / "generated.txt").exists())

    def test_rejects_source_checkout_without_mutation(self):
        before = (self.source / "value.txt").read_bytes()
        for args in ((), ("--remote",), ("--local", self.source)):
            self.run_launcher(*args, cwd=self.source, success=False)
        nested = self.source / "Nested"
        nested.mkdir()
        self.run_launcher("--local", self.source, cwd=nested, success=False)
        self.assertEqual((self.source / "value.txt").read_bytes(), before)

    def test_help_invalid_arguments_and_invalid_source_do_not_generate(self):
        self.run_launcher("--help")
        for args in (("--unknown",), ("--local",), ("--local", self.target), ("", "extra")):
            self.run_launcher(*args, success=False)
        self.assertFalse((self.target / "generated.txt").exists())

    def test_remote_selection_uses_clone_without_network_in_fixture(self):
        bindir = self.root / "bin"
        bindir.mkdir()
        fake = bindir / "git"
        fake.write_text(
            "#!/usr/bin/python3\nimport os,sys\n"
            "args=sys.argv[1:]\n"
            "if args[0]=='clone':\n"
            "    args=['clone','--quiet',os.environ['FIXTURE_SOURCE'],args[-1]]\n"
            "os.execv(os.environ['FIXTURE_GIT'],[os.environ['FIXTURE_GIT'],*args])\n"
        )
        fake.chmod(0o755)
        env = dict(os.environ, PATH=str(bindir) + os.pathsep + os.environ["PATH"],
                   FIXTURE_SOURCE=str(self.source), FIXTURE_GIT=GIT)
        result = self.run_launcher("--remote", env=env)
        self.assertIn("Downloading", result.stdout)
        self.assertEqual((self.target / "generated.txt").read_text(), "committed snapshot\n")


if __name__ == "__main__":
    unittest.main()
