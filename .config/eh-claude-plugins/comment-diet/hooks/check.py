#!/usr/bin/env python3

# Denies edits that add comments breaking rule.txt. A reminder injected at
# PreToolUse arrives after the tool input is already written, so only a denial
# forces a rewrite. Judging needs a model; the judge fails open.

import json
import os
import re
import sys
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
JUDGE_TIMEOUT = 45

HASH = ("#",)
SLASH = ("//", "/*", "*")
DASH = ("--",)
PREFIXES = {
    **dict.fromkeys(
        "sh bash zsh fish py rb pl yml yaml toml conf cfg ini nix r mk cmake tf dockerfile makefile".split(),
        HASH,
    ),
    **dict.fromkeys(
        "js jsx ts tsx mjs cjs go rs c h cc cpp hpp java kt swift scala cs php kdl css scss less jsonc proto zig dart".split(),
        SLASH,
    ),
    **dict.fromkeys("lua sql hs elm".split(), DASH),
    "vim": ('"',),
    "el": (";",),
    "clj": (";",),
    "html": ("<!--",),
    "xml": ("<!--",),
    "vue": ("//", "/*", "<!--"),
    "svelte": ("//", "/*", "<!--"),
}


def prefixes_for(path):
    name = os.path.basename(path).lower()
    ext = name.rsplit(".", 1)[-1] if "." in name else name
    return PREFIXES.get(ext)


def comment_lines(text, prefixes):
    out = []
    for i, line in enumerate(text.splitlines()):
        s = line.strip()
        if s.startswith("#!") and i == 0:
            continue
        if any(s.startswith(p) for p in prefixes) and not re.fullmatch(r"[#/*\-\s]*", s):
            out.append((i, s))
        else:
            for p in prefixes:
                if p in ("*", "#"):
                    continue
                idx = s.find(" " + p + " ")
                if idx > 0:
                    out.append((i, s[idx + 1 :]))
                    break
    return out


def added_comments(old, new, prefixes):
    seen = {s for _, s in comment_lines(old, prefixes)}
    return [(i, s) for i, s in comment_lines(new, prefixes) if s not in seen]


SCHEMA = json.dumps(
    {
        "type": "object",
        "properties": {
            "violations": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "comment": {"type": "string"},
                        "reason": {"type": "string"},
                    },
                    "required": ["comment", "reason"],
                },
            }
        },
        "required": ["violations"],
    }
)


def judge(rule, cases):
    prompt = "\n\n".join(
        f"File: {path}\nAdded comments:\n"
        + "\n".join(s for _, s in added)
        + f"\nEdited code:\n{new}"
        for path, added, new in cases
    )
    system = (
        rule
        + "\nYou judge comments added by an edit against the rule above. Flag a "
        "comment that restates the code; narrates the edit; argues for the chosen "
        "approach against alternatives the reader never sees (that belongs in the "
        "commit message); cites what prompted the change; or spends several lines "
        "where one would carry the constraint. Do not flag a comment that concisely "
        "states a real invariant, workaround reason, or hidden constraint, even if "
        "it also names what the code does."
    )
    try:
        out = subprocess.run(
            [
                "claude", "-p", "--model", os.environ.get("COMMENT_DIET_MODEL", "sonnet"), "--tools", "",
                "--setting-sources", "", "--no-session-persistence",
                "--output-format", "json", "--json-schema", SCHEMA,
                "--system-prompt", system, prompt,
            ],
            capture_output=True, text=True, timeout=JUDGE_TIMEOUT,
            env={**os.environ, "COMMENT_DIET_JUDGE": "1"},
        )
        return json.loads(out.stdout)["structured_output"]["violations"]
    except Exception:
        return []


def pairs(tool, inp):
    path = inp.get("file_path") or inp.get("notebook_path") or ""
    if tool == "Edit":
        yield path, inp.get("old_string", ""), inp.get("new_string", "")
    elif tool == "MultiEdit":
        for e in inp.get("edits", []):
            yield path, e.get("old_string", ""), e.get("new_string", "")
    elif tool == "Write":
        try:
            with open(path) as f:
                old = f.read()
        except OSError:
            old = ""
        yield path, old, inp.get("content", "")


def deny(reason):
    json.dump(
        {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
            }
        },
        sys.stdout,
    )
    sys.exit(0)


def main():
    if os.environ.get("COMMENT_DIET_JUDGE"):
        return
    data = json.load(sys.stdin)
    cases = []
    for path, old, new in pairs(data.get("tool_name", ""), data.get("tool_input", {})):
        prefixes = prefixes_for(path)
        if not prefixes:
            continue
        added = added_comments(old, new, prefixes)
        if added:
            cases.append((path, added, new))
    if not cases:
        return

    with open(os.path.join(HERE, "rule.txt")) as f:
        rule = f.read()
    violations = judge(rule, cases)
    if not violations:
        return

    listing = "\n".join(f"  {v['comment']}\n    -> {v['reason']}" for v in violations)
    deny(
        f"Blocked: these comments break the user's comment rule. Delete them (or "
        f"rewrite to state only the constraint the code cannot show) and resubmit."
        f"\n\n{listing}\n\n{rule}"
    )


if __name__ == "__main__":
    main()
