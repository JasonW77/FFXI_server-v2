---
name: lsb-pr
description: Open, update, and respond to LandSandBoat/server pull requests from this fork. Use when submitting retail-accurate core work upstream, cherry-picking from LIVE, addressing LSB review comments, or stripping Cursor co-authors.
---

# LSB PRs

Target: [LandSandBoat/server](https://github.com/LandSandBoat/server) `base`. Head repo is `lsb-fork` (`JasonW77/lsb-server`), not `origin` (`LIVE`).

Read `documentation/ai_agents/README.md` and the PR template checkboxes. Leave review-thread resolve to LSB.

## Before opening

1. Diff the change against current `upstream/base`, not `LIVE`. LIVE can lag a core fix (example: THF AF2 `qm2` was already correct on LSB).
2. Search open PRs/issues for the same topic. A C++ fix can supersede a Lua guard (example: `getMaxGearMod` → #11180 closed #11178).
3. One concern per PR. Do not open from `LIVE`.
4. Wiki is a lead. Do not invent message IDs, animation IDs, or fail-path packets. Mark unverified lines TODO and ask for a capture.

## Commits

Hard rules:

- **Subject ≤ 72 characters** (Sanity Checks fails longer titles).
- **Never** include `Co-authored-by: Cursor` (or other agent trailers). Reviewers reject them.

Cursor's `git commit` wrapper often re-adds that trailer. After every commit:

```
git log -1 --format=%B
git log -1 --format=%s   # confirm length ≤ 72
```

If the trailer is present, strip it before push. On Windows (path spaces break `sed`), use the skill script:

```
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --msg-filter "python .cursor/skills/lsb-pr/scripts/strip_cursor_trailer.py" HEAD~1..HEAD
```

Run from the PR worktree; adjust the python path if the worktree is outside this repo. Do not `--no-verify`.

Push with `--force-with-lease` only to the unmerged PR branch on `lsb-fork`. Never force-push `LIVE`.

## Review replies

- Fix: make the smallest change, reply on the thread, do not resolve it.
- Capture ask: say we do not have a retail client if true; leave the guessed value or `0` plus a TODO. Do not copy a nearby potion/food animation.
- When a reviewer posts capture dumps, **apply them on the same PR** (parse → patch → push → comment with IDs). Do not wait for them to fill in values.
- File-private constants stay `local`. Do not hang them on `xi.itemUtils`.
- If they closed in favor of another PR, stop. Do not keep pushing the superseded branch.

## Captures

Item use: packetviewer `0x028` (animation + success message), `0x029`/`0x02A` (unable-to-use), caplog for printed text. Silent refuse may be `onItemCheck` `-1` (`RefuseSilently`) when there is no fail `0x029`. See the `retail-captures` skill.
