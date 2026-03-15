---
name: Playwright modal click timing
description: not_eligible and other fast-dismissing modals must be clicked immediately — snapshotting first causes stale ref
type: feedback
---

For modals that may auto-dismiss (especially `not_eligible`), do NOT take a snapshot before clicking. Use `browser_wait_for` on the modal heading text, then immediately click the button without an intermediate snapshot call.

**Why:** The modal appears briefly and can auto-dismiss in Playwright headless mode. Taking a snapshot after the modal appears consumes enough time that the ref becomes stale by the time the click fires.

**How to apply:**
```
1. browser_wait_for(text: "Not eligible for this offer")
2. browser_evaluate → find button by textContent and click() directly
   (do NOT browser_snapshot first — this causes the ref to go stale)
```

Cookie cleanup is only triggered by explicit button interaction (Continue or Close). Auto-dismiss does NOT remove the cookie.
