# /feedback

Run feedback capture for the most recent verification run, or for a specific report.

## Usage

```
/feedback
/feedback reports/verification-report-SATHREE-41816-2026-03-15.md
```

## What This Does

Loads the specified (or most recent) verification report and runs Stage 8:
- Mode A: Auto-draft feedback for approval
- Mode B: Interactive Q&A

Saves results to `reports/feedback-log.json`.

Checks for pattern promotion candidates and proposes new patterns if warranted.

## When to Use

Use `/feedback` if:
- The verification run ended before feedback was captured
- You want to add additional feedback after reflection
- You want to promote a pattern candidate
