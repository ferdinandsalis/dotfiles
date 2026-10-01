#!/usr/bin/env python3
"""Tests for fish/scripts/history-for-fzf.py.

Run: python3 -m unittest discover -s fish/tests -v
"""
import importlib.util
import time
import unittest
from pathlib import Path

SCRIPT = Path(__file__).parent.parent / "scripts" / "history-for-fzf.py"


def load_module():
    spec = importlib.util.spec_from_file_location("history_for_fzf", SCRIPT)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


HISTORY = """\
- cmd: first command
  when: 1000
- cmd: second command
  when: 2000
  paths:
    - /some/path
"""


class ParseHistoryTest(unittest.TestCase):
    def setUp(self):
        self.mod = load_module()

    def test_parses_cmd_and_when(self):
        entries = self.mod.parse_history(HISTORY)
        self.assertEqual(entries, [(1000, "first command"), (2000, "second command")])

    def test_ignores_paths_and_blank_lines(self):
        text = HISTORY + "\n- cmd: third\n  paths:\n    - /x\n\n"
        entries = self.mod.parse_history(text)
        self.assertEqual(len(entries), 2)

    def test_skips_entry_without_when(self):
        entries = self.mod.parse_history("- cmd: orphan\n- cmd: ok\n  when: 5\n")
        self.assertEqual(entries, [(5, "ok")])

    def test_unescapes_newline_and_backslash(self):
        entries = self.mod.parse_history("- cmd: echo one\\ntwo\n  when: 1\n")
        self.assertEqual(entries, [(1, "echo one\ntwo")])
        entries = self.mod.parse_history("- cmd: dir C:\\\\\\\\tmp\n  when: 1\n")
        self.assertEqual(entries, [(1, "dir C:\\\\tmp")])

    def test_empty_input(self):
        self.assertEqual(self.mod.parse_history(""), [])


class FormatEntriesTest(unittest.TestCase):
    def setUp(self):
        self.mod = load_module()

    def test_newest_first_sorted_by_when(self):
        entries = [(1000, "old"), (3000, "newest"), (2000, "middle")]
        out = self.mod.format_entries(entries, "%Y")
        records = [r for r in out.split("\0") if r]
        self.assertEqual(len(records), 3)
        self.assertTrue(records[0].endswith("newest"))
        self.assertTrue(records[2].endswith("old"))

    def test_nul_terminated_and_separated(self):
        out = self.mod.format_entries([(1000, "cmd")], "%Y")
        expected_time = time.strftime("%Y", time.localtime(1000))
        self.assertEqual(out, f"{expected_time} │ cmd\0")

    def test_honors_time_format(self):
        out = self.mod.format_entries([(0, "cmd")], "%m-%d %H:%M:%S")
        expected_time = time.strftime("%m-%d %H:%M:%S", time.localtime(0))
        self.assertTrue(out.startswith(expected_time + " │ "))

    def test_dedupes_rerun_commands_keeping_latest_when(self):
        entries = [(1000, "git push"), (2000, "git push"), (1500, "ls")]
        out = self.mod.format_entries(entries, "%Y")
        records = [r for r in out.split("\0") if r]
        push_records = [r for r in records if "git push" in r]
        self.assertEqual(len(push_records), 1)
        self.assertTrue(records[0].endswith("git push"))


if __name__ == "__main__":
    unittest.main()
