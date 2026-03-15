# Stage 5: Business Logic Verification

This stage walks through each Jira acceptance criteria scenario and verifies the application behaves as specified.

**Jira AC is the source of truth for business logic verification.**
A check is only PASS when the observed behaviour exactly matches the AC statement.

---

## 5.1 — AC Extraction Format

Before running any test, structure each AC point as a testable scenario:

```markdown
### AC Check #<N>
**AC Statement**: "<exact text from Jira>"
**Preconditions**: <app state needed — which user, which page, which data>
**Action**: <what to do — click, navigate, enter, etc.>
**Expected Outcome**: <exact observable result — URL, text, state change, API call>
**Verification Method**: <DOM state / network request / visual / URL check>
```

---

## 5.2 — Precondition Verification

Before executing each AC check, confirm the preconditions are met:

```
IF precondition = "user is logged in as approved member":
  → Verify current session is the test user created in Stage 3
  → Verify user status shows "approved" (not pending, not banned)
  → If not: navigate to login, enter credentials

IF precondition = "user is on <specific page>":
  → Navigate to that URL
  → Verify page loaded (URL matches, key element visible)
  → If navigation fails: mark check as INCONCLUSIVE — Precondition failed

IF precondition = "feature flag X is enabled":
  → Check with user: "Is feature flag <X> enabled on <TEST_ENV>?"
  → Do NOT assume flag state
```

---

## 5.3 — Execution Protocol

For each AC check:

1. **Set up preconditions** (see 5.2)
2. **Perform the action** exactly as described
3. **Wait for response** — allow up to 5 seconds for async operations
4. **Capture evidence**:
   - Screenshot of the result state
   - URL if navigation occurred
   - Network request/response if AC involves an API call
   - DOM state (element text, visibility, disabled state)
5. **Compare against expected outcome**
6. **Assign verdict**: PASS / FAIL / INCONCLUSIVE

---

## 5.4 — Evidence Collection per Check Type

### DOM / UI State Checks

```javascript
// Verify element is visible
const el = document.querySelector('<selector>');
const isVisible = el && el.offsetParent !== null;

// Verify element text
const text = el?.textContent?.trim();

// Verify element is disabled
const isDisabled = el?.disabled || el?.getAttribute('aria-disabled') === 'true';

// Verify element has class
const hasClass = el?.classList.contains('<class-name>');
```

Evidence to record:
- Screenshot
- Exact text content
- Element visibility state
- Any relevant attributes

### URL / Navigation Checks

```javascript
// After action, verify URL
const currentUrl = window.location.href;
const expectedPath = '<expected-path>';
const urlMatches = currentUrl.includes(expectedPath);
```

Evidence to record:
- Full URL before action
- Full URL after action
- Whether redirect matched expectation

### Network Request Checks

For AC points involving API calls (form submission, data save, etc.):

1. Open browser DevTools Network panel before performing action
2. Filter by XHR/Fetch
3. Perform the action
4. Capture:
   - Request URL and method
   - Request payload (body)
   - Response status code
   - Response body (key fields)

Evidence to record:
- Request: `POST /api/v2/feature-endpoint { "field": "value" }`
- Response: `200 OK { "success": true, "id": "..." }`
- Or: `422 Unprocessable Entity { "error": "..." }`

### Error State Checks

For AC points testing error handling:

1. Deliberately trigger the error condition (invalid data, missing required field)
2. Verify error message text matches AC specification
3. Verify error appears in correct location (inline, toast, modal)
4. Verify form state (fields still populated, user can correct and retry)

Evidence:
- Screenshot of error state
- Exact error message text
- Comparison: AC says `"<error text>"` → observed `"<actual text>"`

---

## 5.5 — Cross-Reference with Business Rules

After each AC check, verify against relevant business rules:

```
IF AC involves registration/onboarding:
  → Cross-check QA_REPO/.cursor/business-rules/02-user-registration-onboarding-workflows.md

IF AC involves profile approval:
  → Cross-check .cursor/business-rules/06-profile-approval-system-content-moderation.md

IF AC involves messaging:
  → Cross-check .cursor/business-rules/09-messaging-system-communication-rules.md
```

Note any discrepancies between AC and business rules. These are potential spec conflicts — do not resolve them yourself; surface them in the report.

---

## 5.6 — Confidence Level Assignment

| Confidence | When to Apply |
|-----------|--------------|
| **HIGH** | Expected and actual outcomes match exactly, with screenshot + DOM/network evidence |
| **MEDIUM** | Outcome matches but evidence is partial (screenshot only, no network capture) |
| **LOW** | Outcome appears to match but hard to verify definitively (async effects, delayed state) |
| **INCONCLUSIVE** | AC is ambiguous / precondition failed / feature not accessible |

---

## 5.7 — Common Failure Patterns

### "AC is ambiguous — can't determine pass/fail"
```
AC text: "User should see appropriate feedback"
→ "Appropriate" is not testable as written
→ Mark as INCONCLUSIVE
→ Note in report: "AC is ambiguous — 'appropriate feedback' not defined.
   Observed: <what was seen>. Recommend AC clarification with ticket reporter."
```

### "Behaviour matches but differs from business rules"
```
IF app behaviour matches AC but contradicts business rules doc:
  → Report PASS for the AC check
  → Add a note: "WARNING: Observed behaviour conflicts with business rule
    in [file, section]. AC may reflect a deliberate rule change.
    Verify with product team."
```

### "Feature works but only in one path"
```
IF AC check #3 PASSES via direct URL but FAILS via UI navigation:
  → Report as FAIL
  → Evidence: "Direct URL: PASS. UI navigation: FAIL. Both paths should work."
  → Confidence: HIGH
```

### "Intermittent result"
```
IF check passes on first attempt but fails on second:
  → Retry 3 times total
  → If result is inconsistent: INCONCLUSIVE — Intermittent behaviour
  → Note observation count: "2 PASS / 1 FAIL across 3 attempts"
```

---

## 5.8 — Regression Check

After completing AC checks, perform a quick regression scan on adjacent features:

1. Identify adjacent features from the test plan (Stage 1, Regression Risks section)
2. For each: navigate to the feature, perform the key happy-path action
3. Verify no unexpected errors, broken layouts, or 500 responses

Record regression checks:
```markdown
### Regression Check: <Adjacent Feature>
- URL: <url>
- Action: <what was done>
- Status: ✅ No regression / ❌ REGRESSION DETECTED
- Evidence: <screenshot or observation>
```

---

## 5.9 — Business Logic Summary

After all AC checks:

```markdown
### Business Logic Verification Summary
- Total AC checks: X
- PASS: X
- FAIL: X
- INCONCLUSIVE: X

### Failed AC Checks
| # | AC Statement | Expected | Actual | Confidence |
|---|-------------|---------|--------|-----------|
| 2 | "User sees X" | X visible | Y shown | HIGH |

### Regression Checks
- Checked: X adjacent features
- Regressions: X
```

Include in Stage 7 Report.
