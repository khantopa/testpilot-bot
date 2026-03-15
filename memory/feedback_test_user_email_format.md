---
name: Test user email format
description: Email naming convention for test accounts created during verification runs
type: feedback
---

Always use these formats when creating test users on seeking test environments:

- **Attractive users:** `khan+attr<identifier>@incube8.sg`
- **Generous users:** `khan+gen<identifier>@incube8.sg`

Use a short identifier (e.g. ticket number or sequence: `attr01`, `attr02`, or `attr41277a`).

**Why:** User prefers trackable emails under their own domain so test accounts are easy to find and clean up later.

**How to apply:** Whenever Stage 3 requires creating attractive or generous test users, use these formats. Do not use the generic `testpilot_<timestamp>@seeking-test.com` format unless no other format is specified.

**BUC campaign note:** Setting `_join_inputValues` cookie with a valid `submission_uid` BEFORE registration causes BE to enroll the new user in the campaign automatically.
