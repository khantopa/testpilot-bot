---
name: Selfie / Liveness Bypass in IPCF
description: Append qaSimulateLiveness=APPROVE to bypass selfie step
type: feedback
---

## Rule

Append `?qaSimulateLiveness=APPROVE` to the URL **early** — at the /member redirect during the username/firstname IPCF step. Do NOT wait until the selfie step appears.

### Timing

- Add the param when first redirected to `/member` after join
- Do it at the username/firstname step, before selfie appears
- The param persists through IPCF navigation and is ready when liveness check fires

### What Does NOT Work

- UI "Skip" link — unreliable, may not be present
- qa-callback API calls as primary approach — unnecessary complexity
- qa-set-trusted-member alone — sets BE flag but doesn't advance FE
- Waiting until selfie step appears — timing issues

**Validated:** 2026-03-25 (updated from 2026-03-15)
