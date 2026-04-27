---
name: Selfie bypass URL param timing
description: Add qaSimulateLiveness=APPROVE at /member redirect during username step, not at selfie step
type: feedback
---

## Rule

Append `?qaSimulateLiveness=APPROVE` to the URL **at the /member redirect after join**, during the username/firstname step — NOT when the selfie step actually appears.

**Why:** Waiting until the selfie step appears can cause timing issues. Adding the param earlier ensures it's already in place when the flow reaches the liveness check.

**How to apply:**
- After successful join, when redirected to `/member`, add `?qaSimulateLiveness=APPROVE` to the URL
- Do this at the username/firstname step of IPCF, before reaching selfie
- Do NOT wait for the selfie step to appear before adding the param
- Do NOT use direct liveness qa-callback API calls as the primary approach — the URL param should work

**Validated:** 2026-03-25 (supersedes earlier feedback about using qa-callback API)
