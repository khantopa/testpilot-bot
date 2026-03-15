---
name: Cookie set requires page refresh
description: After setting _join_inputValues cookie, always refresh the page before interacting — cookie detection is not reactive
type: feedback
---

After setting the `_join_inputValues` campaign cookie via `document.cookie`, always do a full page refresh (navigate to the same URL again) before proceeding.

**Why:** The cookie detector is not reactive — it only runs on page load. Setting the cookie mid-session does not trigger modal detection or enrollment logic until the next full page load.

**How to apply:** In Stage 3 setup, after `browser_evaluate` sets the cookie, immediately call `browser_navigate` to the current URL to force a page reload before continuing with any registration or navigation steps.
