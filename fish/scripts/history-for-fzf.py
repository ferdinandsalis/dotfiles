#!/usr/bin/env python3
"""Emit fish history entries for fzf, newest first, NUL-delimited.

Reads fish_history directly instead of going through the `history` builtin,
so no `history merge` is needed to see other sessions' commands, and the
concurrent-session history desync bugs (fish-shell #10300, #12447) cannot
take effect. The history file itself is always complete.

Usage: history-for-fzf.py [--time-format FMT] [HISTORY_FILE]
Output per record: "<formatted time> │ <command>\0"
"""
import argparse
import os
import sys
import time


def unescape(cmd):
    # fish's mini-escape in the history file: \n for newline, \\ for backslash.
    out = []
    i = 0
    while i < len(cmd):
        if cmd[i] == "\\" and i + 1 < len(cmd):
            nxt = cmd[i + 1]
            if nxt == "n":
                out.append("\n")
            elif nxt == "\\":
                out.append("\\")
            else:
                out.append(nxt)
            i += 2
        else:
            out.append(cmd[i])
            i += 1
    return "".join(out)


def parse_history(text):
    entries = []
    cmd = None
    for line in text.splitlines():
        if line.startswith("- cmd: "):
            cmd = line[len("- cmd: "):]
        elif line.startswith("  when: ") and cmd is not None:
            try:
                entries.append((int(line[len("  when: "):]), unescape(cmd)))
            except ValueError:
                pass
            cmd = None
    return entries


def format_entries(entries, time_format):
    # Re-running a command appends a duplicate with a fresh timestamp;
    # keep only the most recent instance, like fish's own dedupe.
    latest = {}
    for when, cmd in entries:
        if cmd not in latest or when > latest[cmd]:
            latest[cmd] = when
    deduped = sorted(latest.items(), key=lambda kv: kv[1], reverse=True)
    return "".join(
        time.strftime(time_format, time.localtime(when)) + " │ " + cmd + "\0"
        for cmd, when in deduped
    )


def main():
    default_file = os.path.join(
        os.environ.get("XDG_DATA_HOME", os.path.expanduser("~/.local/share")),
        "fish", "fish_history",
    )
    parser = argparse.ArgumentParser()
    parser.add_argument("history_file", nargs="?", default=default_file)
    parser.add_argument("--time-format", default="%m-%d %H:%M:%S")
    args = parser.parse_args()

    try:
        with open(args.history_file, encoding="utf-8") as f:
            text = f.read()
    except FileNotFoundError:
        return
    sys.stdout.write(format_entries(parse_history(text), args.time_format))


if __name__ == "__main__":
    main()
