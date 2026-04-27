---
name: Factory API functions over response interception
description: Always prefer real E2E user creation via API over Playwright response interception — interception hides BE bugs
type: feedback
---

## Rule

Always prefer creating real test users via factory API endpoints (register, onboard, enroll, approve) over Playwright response interception. Response interception breaks E2E testing because it bypasses the BE entirely — if the BE is broken, interception will still show PASS.

**Why:** Response interception masks BE bugs. The whole point of E2E verification is to confirm FE + BE work together. If we intercept, we're only testing FE rendering in isolation.

**How to apply:**
- Default approach: use factory functions (API register, API onboard, API approve, real enrollment)
- Use encryption keys/functions when provided by the user to create real `hashed_email` values
- Only use response interception when the user **explicitly** says "use interception for this"
- If a test is blocked by a missing API capability, ask the user before falling back to interception

**Validated:** 2026-03-25
