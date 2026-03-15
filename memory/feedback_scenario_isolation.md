---
name: Scenario Isolation — Clear Storage Between Scenarios
description: Before each new test scenario, clear all cookies, localStorage, and sessionStorage to simulate a fresh incognito window
type: feedback
---

## Rule

At the start of every new test scenario, clear all browser storage before proceeding.

**Why:** Each scenario must run in isolation — like a fresh incognito window. Leftover auth cookies, session tokens, or campaign state from a previous scenario will pollute the new scenario's results.

**How to apply:** Run this before each scenario start:

```js
// Clear all cookies
document.cookie.split(";").forEach(c => {
  document.cookie = c.replace(/^ +/, "").replace(/=.*/, `=;expires=${new Date(0).toUTCString()};path=/;domain=.members-testqa.seeking.com`);
  document.cookie = c.replace(/^ +/, "").replace(/=.*/, `=;expires=${new Date(0).toUTCString()};path=/`);
});
// Clear storage
localStorage.clear();
sessionStorage.clear();
```

Then navigate to `/login` for a clean starting point.
