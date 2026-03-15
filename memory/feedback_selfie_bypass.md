---
name: Selfie / Liveness Bypass in IPCF (Playwright)
description: How to bypass the selfie camera step during IPCF onboarding in Playwright headless — correct sequence for qa-callback
type: feedback
---

## Rule

To bypass the selfie verification step during IPCF in Playwright headless, use `qa-callback` WHILE the camera component is mounted — not before clicking Continue on the intro screen.

**Why:** The FE binds to Pusher `selfie_verification_completed` when the camera component mounts. Calling `qa-callback` before the component mounts means the Pusher event fires before the listener exists. The `qaSimulateLiveness` URL param does NOT work on testqa because `ENABLE_QA_SIMULATE_LIVENESS` env var is not set.

**How to apply:** Use this exact sequence every time the selfie IPCF step is encountered:

### Working Sequence

```
1. Navigate to /member?registered=true (with &qaSimulateLiveness=APPROVE if desired, but it has no effect)
2. Dismiss CampaignInfoModal if shown (click Continue)
3. Click Continue on "Verify with a Selfie" intro screen
4. Wait for camera component to mount (shows "This feature requires camera access" OR camera loading)
5. Call qa-delete-all-association (clear any prior liveness state):
   POST /v3/liveness/qa-delete-all-association?is_metadata=0
   Body: { "uid": "<user_uid>" }
6. Call qa-callback to fire Pusher event:
   POST /v3/liveness/qa-callback?is_metadata=0
   Body: { "uid": "<user_uid>", "recommendation": "APPROVE" }
7. Pusher selfie_verification_completed fires → IPCF advances to "Thank you for verifying!"
8. Click Continue on "Thank you for verifying!" to advance to next IPCF step
```

### What Does NOT Work

- `?qaSimulateLiveness=APPROVE` (or any value) — env var `ENABLE_QA_SIMULATE_LIVENESS` not set on testqa, hook never fires
- Calling `qa-callback` BEFORE clicking Continue on selfie intro — event fires before Pusher listener exists
- Calling `qa-callback` while on the "Verification Failed" screen — timing issue, needs clean state
- `qa-set-trusted-member` alone — sets BE flag but doesn't advance IPCF selfie step in FE

### Key Endpoints

```
POST /v3/liveness/qa-delete-all-association?is_metadata=0  { uid }   → clears liveness state
POST /v3/liveness/qa-callback?is_metadata=0  { uid, recommendation: "APPROVE" }  → fires Pusher
```

**recommendation** must be uppercase `"APPROVE"`.

**Validated:** 2026-03-15 — SATHREE-41277 Scenario 1 (Attractive user, testqa)
