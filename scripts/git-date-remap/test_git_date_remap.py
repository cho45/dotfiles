import unittest
import os
import shutil
import subprocess
import datetime
import re
from pathlib import Path

class TestGitDateRemap(unittest.TestCase):
    def setUp(self):
        self.test_dir = Path("test_run_dir")
        if self.test_dir.exists():
            shutil.rmtree(self.test_dir)
        self.test_dir.mkdir()
        
        self.repo_dir = self.test_dir / "repo"
        self.repo_dir.mkdir()
        self.script_path = Path(__file__).parent / "git-date-remap.py"
        self.run_git(["init", "-b", "main"], cwd=self.repo_dir)

    def tearDown(self):
        if self.test_dir.exists():
            shutil.rmtree(self.test_dir)

    def run_git(self, args, cwd=None, input=None, env=None):
        return subprocess.run(["git"] + args, cwd=cwd or self.repo_dir, 
                             input=input, env=env,
                             check=True, capture_output=True, text=(input is None)).stdout

    def create_commit(self, date, msg, cwd=None):
        env = os.environ.copy()
        env["GIT_AUTHOR_DATE"] = date
        env["GIT_COMMITTER_DATE"] = date
        subprocess.run(["git", "commit", "--allow-empty", "-m", msg], 
                       cwd=cwd or self.repo_dir, env=env, capture_output=True, check=True)

    def test_multiple_commits_preview(self):
        """Verify that multiple commits are correctly listed in the preview with their titles."""
        # Create 3 commits with distinct titles and dates
        # Use dates that are easy to check in the preview
        self.create_commit("2010-01-01T10:00:00Z", "Commit-A-Title")
        self.create_commit("2010-01-02T10:00:00Z", "Commit-B-Title")
        self.create_commit("2010-01-03T10:00:00Z", "Commit-C-Title")
        
        # Run with --dry-run
        result = subprocess.run([
            "python3", str(self.script_path), "--dry-run", 
            "2010-01-01T10:00:00Z..2010-01-03T10:00:00Z", 
            "2025-01-01T10:00:00Z..2025-01-03T10:00:00Z"
        ], cwd=self.repo_dir, capture_output=True, text=True)
        
        self.assertEqual(result.returncode, 0)
        output = result.stdout
        
        print("\n--- Dry Run Output Preview ---")
        print(output)
        print("------------------------------")
        
        self.assertIn("Total remapped commits: 3", output)
        
        # Split output into lines and find the remapped lines
        lines = [l for l in output.splitlines() if "|" in l and "->" in l]
        self.assertEqual(len(lines), 3)
        
        # Verify each line matches its title and remapped date exactly
        # Commit A (2010-01-01 -> 2025-01-01)
        self.assertTrue(any("Commit-A-Title" in l and "2010-01-01" in l and "2025-01-01" in l for l in lines), "Commit A missing or incorrect")
        # Commit B (2010-01-02 -> 2025-01-02)
        self.assertTrue(any("Commit-B-Title" in l and "2010-01-02" in l and "2025-01-02" in l for l in lines), "Commit B missing or incorrect")
        # Commit C (2010-01-03 -> 2025-01-03)
        self.assertTrue(any("Commit-C-Title" in l and "2010-01-03" in l and "2025-01-03" in l for l in lines), "Commit C missing or incorrect")

    def test_dry_run(self):
        self.create_commit("2010-01-01T00:00:00Z", "original-commit")
        old_hash = self.run_git(["rev-parse", "HEAD"]).strip()
        result = subprocess.run(["python3", str(self.script_path), "--dry-run", "2010-01-01", "2025-01-01.."], 
                                cwd=self.repo_dir, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0)
        self.assertIn("original-commit", result.stdout)
        new_hash = self.run_git(["rev-parse", "HEAD"]).strip()
        self.assertEqual(old_hash, new_hash)

    def test_non_utf8_author_protection(self):
        non_utf8_name = b"\x82\xa0"
        env = os.environ.copy()
        env["GIT_AUTHOR_NAME"] = non_utf8_name.decode('latin-1')
        env["GIT_COMMITTER_NAME"] = env["GIT_AUTHOR_NAME"]
        env["GIT_AUTHOR_DATE"] = "2000-01-01T00:00:00Z"
        env["GIT_COMMITTER_DATE"] = "2000-01-01T00:00:00Z"
        subprocess.run(["git", "commit", "--allow-empty", "-m", "non-utf8-commit"], 
                       cwd=self.repo_dir, env=env, check=True)
        ancient_hash = self.run_git(["rev-parse", "HEAD"]).strip()
        self.create_commit("2010-01-01T00:00:00Z", "new-commit")
        subprocess.run(["python3", str(self.script_path), "-f", "2005-01-01", "2025-01-01.."], 
                       cwd=self.repo_dir, check=True)
        current_ancient_hash = self.run_git(["rev-parse", "HEAD~1"]).strip()
        self.assertEqual(ancient_hash, current_ancient_hash)

    def test_absolute_history_protection(self):
        ancient_date = "2000-01-01T00:00:00Z"
        self.create_commit(ancient_date, "ancient-1")
        original_hashes = self.run_git(["rev-list", "--all", "--reverse"]).splitlines()
        self.create_commit("2010-01-01T00:00:00Z", "new-1")
        subprocess.run(["python3", str(self.script_path), "-f", "2005-01-01", "2025-01-01..2025-12-31"], 
                       cwd=self.repo_dir, check=True)
        current_hashes = self.run_git(["rev-list", "--all", "--reverse"]).splitlines()
        self.assertEqual(current_hashes[0], original_hashes[0])

    def test_time_only(self):
        now = datetime.datetime.now()
        ten_am = now.replace(hour=10, minute=0, second=0, microsecond=0).astimezone().isoformat()
        self.create_commit(ten_am, "today-10am")
        subprocess.run(["python3", str(self.script_path), "-f", "09:00..11:00", "21:00..22:00"], 
                       cwd=self.repo_dir, check=True)
        log_date = self.run_git(["log", "-1", "--format=%ai"]).strip()
        self.assertIn(" 21:30:", log_date)

    def test_chronological_order(self):
        """Verify that remapped commits maintain their relative chronological order."""
        # Create commits in order
        self.create_commit("2010-01-01T10:00:00Z", "first")
        self.create_commit("2010-01-01T11:00:00Z", "second")
        self.create_commit("2010-01-01T12:00:00Z", "third")
        
        # Remap to a future date
        subprocess.run([
            "python3", str(self.script_path), "-f",
            "2010-01-01T10:00:00Z", "2025-01-01T00:00:00Z.."
        ], cwd=self.repo_dir, check=True)
        
        # Get new dates
        log = self.run_git(["log", "--format=%at %s", "--reverse"]).splitlines()
        dates = [int(line.split()[0]) for line in log]
        
        # Verify order
        self.assertTrue(dates[0] < dates[1] < dates[2], f"Order not preserved: {dates}")

    def create_signed_commit_mock(self, date_str, msg):
        """Create a commit with a fake gpgsig header to simulate signed commits."""
        tree = self.run_git(["write-tree"]).strip()
        parent = self.run_git(["rev-parse", "HEAD"]).strip()
        # Simulate a commit object with a gpgsig header
        # Note: we use seconds since epoch for simplicity in this low-level mock
        ts = int(datetime.datetime.fromisoformat(date_str.replace('Z', '+00:00')).timestamp())
        commit_content = (
            f"tree {tree}\n"
            f"parent {parent}\n"
            f"author Test User <test@example.com> {ts} +0000\n"
            f"committer Test User <test@example.com> {ts} +0000\n"
            "gpgsig -----BEGIN PGP SIGNATURE-----\n"
            " \n"
            " iF0EABECAB0WIQ...\n"
            " -----END PGP SIGNATURE-----\n"
            "\n"
            f"{msg}\n"
        ).encode()
        
        commit_hash = subprocess.run(
            ["git", "hash-object", "-t", "commit", "-w", "--stdin"],
            cwd=self.repo_dir, input=commit_content, capture_output=True, check=True
        ).stdout.decode().strip()
        self.run_git(["update-ref", "HEAD", commit_hash])
        return commit_hash

    def test_strict_hash_stability_with_signature(self):
        """Verify that a signed commit outside the range is NOT altered (and thus keeps its signature)."""
        # 1. Create a base commit and then a SIGNED commit (pushed)
        self.create_commit("2000-01-01T10:00:00Z", "base")
        signed_hash = self.create_signed_commit_mock("2000-01-02T10:00:00Z", "signed-pushed")
        
        # 2. Create a new commit to remap
        self.create_commit("2010-01-01T10:00:00Z", "to-remap")
        
        # 3. Remap only the 2010 commit (source 2005 onwards)
        subprocess.run([
            "python3", str(self.script_path), "-f",
            "2005-01-01T00:00:00Z", "2025-01-01T00:00:00Z.."
        ], cwd=self.repo_dir, check=True)
        
        # 4. Verify the signed commit's hash is EXACTLY the same
        new_history = self.run_git(["log", "--format=%H %s", "HEAD"]).splitlines()
        # history: [new_to_remap, signed_pushed, base]
        new_signed_hash = [line.split()[0] for line in new_history if "signed-pushed" in line][0]
        
        self.assertEqual(signed_hash, new_signed_hash, 
            "Divergence! The tool stripped the GPG signature from a 'pushed' commit, changing its hash.")

if __name__ == "__main__":
    unittest.main()