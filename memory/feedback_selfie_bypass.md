---
name: Selfie / Liveness Bypass in IPCF
description: Append qaSimulateLiveness=APPROVE to bypass selfie step
type: feedback
---

## Rule

Append `?qaSimulateLiveness=APPROVE` to the URL when reaching the IPCF
selfie verification step. This auto-approves liveness without camera.

Can be appended at any point during IPCF — does NOT need to be set
from the start of /join.

### What Does NOT Work

- UI "Skip" link — unreliable, may not be present
- qa-callback API timing tricks — unnecessary complexity
- qa-set-trusted-member alone — sets BE flag but doesn't advance FE

**Validated:** 2026-03-15
