#!/usr/bin/env python3
"""Drop Cursor/agent co-author lines from a git commit message (stdin → stdout)."""
import sys

text = sys.stdin.read()
lines = [
    ln
    for ln in text.splitlines()
    if "Co-authored-by: Cursor" not in ln and "Co-authored-by: cursoragent" not in ln
]
while lines and lines[-1].strip() == "":
    lines.pop()
sys.stdout.write("\n".join(lines) + "\n")
