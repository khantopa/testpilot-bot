---
name: Default test environment
description: User's preferred default test environment URL when none is specified
type: feedback
---

Always default to `https://members-testqa.seeking.com` as the test environment URL when the user does not explicitly provide one.

**Why:** User explicitly instructed this as default — saves being asked every time.

**How to apply:** At Stage 1 input collection, if no test env URL is provided in the command arguments, use `https://members-testqa.seeking.com` automatically without asking. Note the defaulted URL in the test plan.
