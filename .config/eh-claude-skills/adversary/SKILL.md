---
name: adversary
description: Investigate a task, then have an independent second agent review the findings and negotiate to consensus with loop protection. Use when the user invokes /adversary, or asks for adversarial mode, a second opinion from another agent, or for work to be double-checked by an independent reviewer before they act on it.
---

# adversary

Two agents check each other's work on one task. Not a debate for its own sake —
by definition, on any point of contention one of them is wrong, and the goal is
to find out which, or to stop and say that neither side knows.

## Invocation

```
/adversary <task>
```

Run the whole cycle: investigate the task first, then hand the work to a
reviewer, then negotiate. The user sees the investigation as it happens; the
review is not a surprise second phase to hide.

If the user's phrasing names an existing session — "use existing session
backend-refactor", "have the session in ~/foo review it" — use that session as
the reviewer instead of a subagent (see **Reviewer: existing session**).

If the user gives a round budget ("up to 5 rounds"), use it in place of the
default of 3.

## Phase 1 — Investigate

Do the task properly, as if no review were coming. A deliberately thin first
pass wastes the reviewer's time and biases the whole exercise.

Then write a brief to the scratchpad as `adversary-brief.md`:

- **Task** — the user's request, verbatim. Not a paraphrase. Paraphrasing
  launders your own assumptions into the review and is the single easiest way
  to get a useless second opinion.
- **Answer** — what you concluded, concretely enough to be wrong.
- **Evidence** — files, line numbers, command output, docs. What you actually
  checked, and how.
- **Assumptions** — what you took as given without verifying.
- **Known soft spots** — where you are least sure. Declare these. A reviewer
  who independently lands on a soft spot you already flagged is a much stronger
  signal than one who finds it after you hid it.

Include the diff or the proposed code in full if there is one.

## Phase 2 — Review

### Reviewer: subagent (default)

Spawn with the `Agent` tool, `subagent_type: "claude"`, no `model` override so
it inherits the current model. Use a fresh agent, **not** `fork` — the point is
an unanchored reading of the task, and a fork inherits the reasoning you are
asking it to check.

The prompt is the brief plus these instructions:

> Review this independently. You are checking whether the answer is correct,
> not whether it is well written.
>
> Verify the load-bearing claims yourself — read the files, run the commands,
> check the docs. Do not accept a claim in the brief because it is stated
> confidently.
>
> Report, per point:
> - the claim you are disputing, quoted from the brief
> - what you believe is true instead
> - the evidence for it, or an explicit note that you could not verify
> - your confidence: high / medium / low
>
> Also report: anything the brief missed, any assumption that does not hold,
> and any simpler approach that was not considered.
>
> Do not manufacture disagreement. If a point is sound, say so and move on;
> filler objections cost real rounds. If the whole thing is sound, say that
> plainly — that is a valid review outcome, not a failure to find something.
> Style and naming are out of scope unless they cause a defect.

### Reviewer: existing session

`ListAgents` to resolve the name the user gave, then `SendMessage` with the
full brief inlined — that session has its own context and cannot see the
scratchpad's contents by assumption, though it can read the file if it is on
the same machine.

Prefer a local session. A cloud session receives the message but cannot reply
back to this one; if the only match is a cloud session, say so and fall back to
a subagent rather than waiting for a reply that will never arrive.

## Phase 3 — Negotiate

The review is evidence, not a verdict. Two failure modes to avoid, and they are
symmetrical:

- Folding on contact. The reviewer is the same model with less context. Being
  told you are wrong is not proof that you are.
- Digging in. You wrote the brief, which makes every objection feel like an
  attack on it. It isn't.

Maintain a ledger and **print it after every round** — it is both the user's
view of progress and the loop detector:

| # | Point | Reviewer | Me | Status |
|---|-------|----------|-----|--------|
| 1 | short claim | position (conf) | position (conf) | agreed / conceded / contested / settled-by-check |

For each point, classify before responding:

**Settleable by checking.** Can a command, a file read, a test, or a doc
resolve it? Then go check. Do not spend a round arguing about something a
30-second verification answers. This is the most common case and the cheapest
exit — reach for it first.

**I'm wrong.** Say so, fix it, mark conceded. No throat-clearing.

**Reviewer is wrong.** Rebut with evidence, not with restatement. A rebuttal
that adds no new evidence is a circling signal, and you should treat your own
as one too.

**Genuine judgment call.** No fact settles it — it's a trade-off. One round to
state both positions clearly, then stop and put it to the user. Do not
negotiate taste.

Send rebuttals back to the same reviewer (`SendMessage` with the agent's ID or
name) so it keeps its context. Include only the still-contested points and the
new evidence.

## Loop protection

Stop and report — do not start another round — the moment any of these holds:

1. **Round cap.** 3 exchanges after the initial review. Hard.
2. **No new evidence.** A round in which neither side introduced a fact,
   file, command output, or citation that wasn't already on the table. Two
   agents restating themselves more politely is not progress, and it can run
   forever because it always feels one round from resolution.
3. **Ledger frozen.** A contested point's row is unchanged across two
   consecutive rounds.
4. **Confidence collapse.** Neither side is at high confidence on a contested
   point. Nobody knows; more rounds will not manufacture knowledge.
5. **Oscillation.** Either side reverses a position and then reverses back, or
   a point that was marked agreed reopens.
6. **Drift.** The exchange has moved onto ground the user's task did not cover.

Convergence is also a stop: when every point is agreed, conceded, or
settled-by-check, you are done. Don't run remaining rounds out of budget.

## Reporting

**On consensus** — the answer, and a short note of what the review changed. If
it changed nothing, say that; it is a real result and worth the user knowing.

**On a stop** — lead with it, don't bury it after the agreed parts:

- which stop condition fired
- what is settled
- each open point: both positions, both confidences, and **what evidence would
  settle it** — a command to run, a file to look at, a decision only the user
  can make

Then ask. An open point handed back with a concrete next check is a good
outcome; a forced consensus reached by one side getting tired is not.

Never present a contested point as resolved because the round budget ran out.
