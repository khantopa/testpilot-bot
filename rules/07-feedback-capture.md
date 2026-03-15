# Stage 8: Feedback Capture

Run this stage AFTER the report is saved. It is non-negotiable.

Every verification run must produce a feedback entry. This is how the system learns.

---

## Ask the User

```
📋 Feedback Capture

The verification report is saved. Before we close, I need to capture feedback
so the system learns from this run.

Choose your mode:
  (A) Quick — I'll draft it, you approve or edit (2 min)
  (B) Interactive — I'll ask you questions, you answer (5 min)

Which works for you right now?
```

---

## Mode A: Auto-Draft

Generate a draft feedback entry based on what happened in this run.

For each check that was FAIL or INCONCLUSIVE:

```markdown
## Check: <check_name>
**My Verdict**: FAIL / INCONCLUSIVE
**Confidence I Reported**: HIGH / MEDIUM / LOW
**Pattern Used**: <pattern.id or "none — standard investigation">

**Draft: Was My Verdict Correct?**
<Compare system verdict to actual ground truth if user knows>
[ ] Yes — confirmed bug
[ ] Partial — right direction, wrong detail
[ ] No — this was actually expected behaviour / won't fix

**Draft: Was the evidence I cited accurate?**
[ ] Yes — evidence exactly matched the issue
[ ] Partial — evidence was relevant but incomplete
[ ] No — evidence was misleading or wrong

**Draft: Should this become a verification pattern?**
<If this check has a repeatable setup/verification path worth encoding>
[ ] Yes — extract pattern
[ ] No — one-off or too feature-specific

**Draft: Notes**
<Any context not captured above — e.g., "the failing check was actually a known issue from SATHREE-XXXXX">
```

Then say:

```
Here's my draft feedback. Does this look correct?
- Edit anything that's wrong
- Type APPROVE to save as-is
- Type SKIP to discard (not recommended)
```

---

## Mode B: Interactive

Ask these questions one at a time. Wait for the answer before asking the next.

**Q1**: "Were any of my verdicts wrong? Walk me through what really happened."

**Q2**: "For each FAIL I reported — was it a real bug, a known issue, or expected behaviour?"

**Q3**: "Was any check I marked INCONCLUSIVE actually testable? What was I missing?"

**Q4**: "Is the setup protocol working correctly? Any steps that are brittle or need improvement?"

**Q5**: "Is there a verification pattern here worth encoding for future runs of similar features?"

---

## Saving Feedback

After approval (Mode A) or completion (Mode B), write to `reports/feedback-log.json`:

```json
{
  "run_id": "<timestamp>",
  "report_file": "reports/verification-report-<TICKET_ID>-<timestamp>.md",
  "jira_ticket": "<TICKET_ID>",
  "test_env": "<TEST_ENV_URL>",
  "captured_at": "<iso_timestamp>",
  "checks": [
    {
      "check_name": "<name>",
      "category": "visual | business_logic | responsiveness | regression",
      "system_verdict": "PASS | FAIL | INCONCLUSIVE",
      "actual_verdict": "PASS | FAIL | INCONCLUSIVE | KNOWN_ISSUE | WONT_FIX",
      "verdict_correct": "yes | partial | no",
      "confidence_reported": "HIGH | MEDIUM | LOW",
      "evidence_accurate": "yes | partial | no",
      "pattern_used": "<pattern.id or null>",
      "new_pattern_candidate": true,
      "new_pattern_trigger": "<one sentence — what conditions trigger this check pattern>",
      "new_pattern_protocol": "<brief steps that would run this verification efficiently>",
      "notes": "<freeform>"
    }
  ],
  "setup_feedback": {
    "setup_successful": true,
    "brittle_steps": ["<step name if any failed or needed workaround>"],
    "setup_notes": "<freeform>"
  },
  "overall_run_feedback": "<freeform notes about the run quality>"
}
```

---

## Pattern Promotion

After saving feedback, check for `new_pattern_candidate: true` entries.

Say:

```
🧠 Pattern Candidate Detected

You flagged "<check_name>" as a potential new pattern.
Trigger: "<new_pattern_trigger>"

Should I:
  (A) Draft a new pattern file now and add it to the registry
  (B) Save for later — I'll accumulate more instances first
  (C) Skip — this was a one-off
```

If **(A)**: Generate a new `patterns/<pattern-id>.md` with this structure:

```markdown
# Pattern: <Pattern Name>

## Trigger

**Keywords** (must appear in feature name, ticket, or description):
- <keyword 1>
- <keyword 2>

**Conditions** (any of these):
- <condition 1>
- <condition 2>

**Confidence Threshold**: 4 (same as triage assistant scoring)

## Protocol

When this pattern is matched, execute these steps instead of the standard flow:

1. <step 1>
2. <step 2>
3. <step 3>

## Termination Conditions

| If | Then |
|----|------|
| <condition A> | PASS — <reason> |
| <condition B> | FAIL — <reason> |
| <condition C> | INCONCLUSIVE — <reason> |

## Known Instances

| Date | Ticket | Outcome | Notes |
|------|--------|---------|-------|
| <date> | <ticket> | <outcome> | <what happened> |
```

Update `patterns/index.json` with the new entry.

If **(B)**: Add to `patterns/candidates.json`:
```json
{
  "trigger": "<trigger sentence>",
  "protocol_sketch": "<brief steps>",
  "instances": ["<run_id>"],
  "promote_after": 3
}
```

---

## Setup Protocol Feedback Loop

If `setup_feedback.brittle_steps` is non-empty:

Say:
```
🔧 Setup Protocol Improvement Opportunity

You flagged these setup steps as brittle:
- <step name>: <what went wrong>

Should I update rules/02-setup-protocol.md with an improved error handler for this case?
(A) Yes — show me the proposed change
(B) No — one-off issue
```

If (A): Propose a specific edit to the relevant section of `rules/02-setup-protocol.md`.
Do NOT auto-apply — show the diff and wait for approval.

---

## Why This Is Non-Negotiable

Every skipped feedback entry is a lost data point.

After 10 runs of consistent feedback:
- Pattern library has real, validated verification patterns
- Common feature types (registration flows, payment flows, search features) have structured protocols
- Token costs drop as patterns replace full-step setup scripts
- Setup failures are documented and the protocol improves

After 10 runs of skipped feedback:
- The system is identical to today
- You are still the reasoning engine for every check

The feedback loop IS the system improvement.
