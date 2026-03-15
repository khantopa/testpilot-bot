---
name: SPA Navigation — Use In-App Links/Buttons
description: In the Seeking SPA, navigate between routes using in-app buttons/links, not browser.goto(). Hard navigation resets React state.
type: feedback
---

## Rule

Navigate between routes within the Seeking app using in-app navigation (links, buttons) — NOT `browser_navigate` / `page.goto()`.

**Why:** Seeking is a single-page application. Using `browser_navigate` to go to a different route causes a full page reload, which resets Redux state, clears any in-progress modal state, and may miss modals that depend on SPA state transitions.

**How to apply:**
- To go to `/billing/memberships`: click the "Upgrade" button in the nav, or the "Upgrade Now" link in the top banner
- To go back to `/member`: click the Seeking logo or "Member" nav link
- To go to `/search`: click the "Search" nav link
- Only use `browser_navigate` / `page.goto()` when:
  - Starting a brand new session (e.g., navigating to `/login`)
  - Calling QA endpoints that require a page reload to take effect (e.g., force-approve, liveness qa-callback) — in those cases a hard nav to `/member` is appropriate to pick up the updated state

**Exception:** After calling QA API endpoints that mutate backend state (force-approve, qa-callback), a hard navigation is acceptable and sometimes necessary to trigger Redux state re-fetch.
