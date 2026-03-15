# Stage 7: Verification Report Format

Save to: `reports/verification-report-<TICKET_ID>-<timestamp>.md`

---

## Report Template

```markdown
# TestPilotBot Verification Report

**Generated**: <ISO timestamp>
**Jira Ticket**: [<TICKET_ID>](jira_url)
**Feature**: <feature name from Jira summary>
**Test Environment**: <TEST_ENV_URL>
**Figma Reference**: <FIGMA_URL>
**Tested By**: TestPilotBot v1
**Duration**: <start to finish time>

---

## Summary

| Category       | Total | Pass  | Fail  | Inconclusive |
| -------------- | ----- | ----- | ----- | ------------ |
| Visual         | X     | X     | X     | X            |
| Business Logic | X     | X     | X     | X            |
| Responsiveness | X     | X     | X     | X            |
| Regression     | X     | X     | X     | X            |
| **TOTAL**      | **X** | **X** | **X** | **X**        |

**Overall Verdict**: ✅ PASS / ❌ FAIL / ⚠️ PARTIAL

> PASS = 0 failures, all checks complete
> PARTIAL = failures present but no critical AC checks failed
> FAIL = 1+ AC checks failed OR critical visual regression

---

## Test Users Created

| Email                            | Nickname        | Type       | Gender | Approved | Purpose           |
| -------------------------------- | --------------- | ---------- | ------ | -------- | ----------------- |
| testpilot\_<ts>@seeking-test.com | testpilot\_<ts> | Attractive | Man    | ✅ Yes   | AC #1, #2, Visual |

> Note: Delete test users after verification. These accounts are safe to remove.

---

## Visual Verification Results

### 1. <Check Name>

- **Element**: `<selector or description>`
- **Page/State**: <URL or app state>
- **Category**: Visual
- **Status**: ✅ PASS / ❌ FAIL / ⚠️ INCONCLUSIVE
- **Confidence**: HIGH / MEDIUM / LOW
- **Expected (Figma)**: `font-size: 16px; color: #1A1A1A; padding: 16px 24px`
- **Actual (Browser)**: `font-size: 16px; color: #1A1A1A; padding: 16px 20px`
- **Discrepancy**: `padding-right: 24px (Figma) vs 20px (browser)`
- **Evidence**:
  - Figma screenshot: `screenshots/<ticket-id>/<ts>-button-figma.png`
  - Browser screenshot: `screenshots/<ticket-id>/<ts>-button-browser.png`
- **Notes**: Padding is 4px short on the right side only.

---

## Business Logic Results

### 1. AC #<N>: <AC Summary>

- **AC Statement**: "<full AC text from Jira>"
- **Category**: Business Logic
- **Status**: ✅ PASS / ❌ FAIL / ⚠️ INCONCLUSIVE
- **Confidence**: HIGH / MEDIUM / LOW
- **Preconditions**: <app state set up>
- **Action Performed**: <what was done>
- **Expected Outcome**: <what AC says should happen>
- **Actual Outcome**: <what was observed>
- **Evidence**:
  - Screenshot: `screenshots/<ticket-id>/<ts>-ac1-result.png`
  - Network: `POST /api/v2/endpoint → 200 OK { "success": true }`
  - DOM state: `element[data-testid="confirmation"] visible, text: "Success"`
- **Notes**: <any context>

---

## Responsiveness Results

### Breakpoint: 375px (Mobile S)

- **Status**: ✅ PASS / ❌ FAIL
- **Confidence**: HIGH
- **Observations**:
  - No horizontal overflow detected
  - All primary CTAs visible
  - Font sizes ≥ 12px
- **Issues**:
  - (none) / <describe issue>
- **Evidence**: `screenshots/<ticket-id>/<ts>-375px.png`

### Breakpoint: 768px (Tablet)

...

### Breakpoint: 1280px (Desktop)

...

---

## Regression Check Results

### <Adjacent Feature Name>

- **Status**: ✅ No regression / ❌ REGRESSION DETECTED
- **URL**: <url tested>
- **Action**: <what was done>
- **Observation**: <what was seen>
- **Evidence**: `screenshots/<ticket-id>/<ts>-regression-<feature>.png`

---

## Issues Found

> Consolidated list of all failures. Prioritised by severity.

### Critical (blocks release)

- [ ] **<Short description>** — AC #X fails: <expected> vs <actual>. Evidence: <link>

### Major (significant impact)

- [ ] **<Short description>** — Visual: <property> is wrong. Expected <X>, got <Y>.

### Minor (polish / low impact)

- [ ] **<Short description>** — <description>

---

## Spec Conflicts / Ambiguities

> Items where AC, Figma, and/or business rules contradict each other.

| #   | Conflict | AC Says   | Business Rule Says | Figma Says | Recommendation        |
| --- | -------- | --------- | ------------------ | ---------- | --------------------- |
| 1   | <topic>  | <AC text> | <rule text>        | <design>   | Clarify with reporter |

---

## Inconclusive Checks

> Checks that could not be completed due to setup failure, missing spec, or ambiguous AC.

| #   | Check | Reason                                               | What Would Be Needed             |
| --- | ----- | ---------------------------------------------------- | -------------------------------- |
| 1   | AC #3 | Precondition failed — user setup failed at Step 3.12 | Working photo upload in test env |

---

## Recommendations

- <Actionable recommendation 1>
- <Actionable recommendation 2>

---

## Sign-off

| Item                    | Status  |
| ----------------------- | ------- |
| All AC checks attempted | ✅ / ❌ |
| Visual checks complete  | ✅ / ❌ |
| Responsiveness checked  | ✅ / ❌ |
| Regression scan done    | ✅ / ❌ |
| Test users documented   | ✅      |
```

---

## Reporting Rules

### Verdict Assignment

```
IF any AC check is FAIL with HIGH confidence:
  → Overall verdict = FAIL

IF all AC checks PASS but visual checks have FAIL:
  → Overall verdict = PARTIAL (visual issue, logic correct)

IF all checks PASS or INCONCLUSIVE (no failures):
  → Overall verdict = PASS (note inconclusive items)

IF > 30% of checks are INCONCLUSIVE due to setup failure:
  → Overall verdict = INCONCLUSIVE — insufficient test coverage
```

### Confidence Rules

- Never report HIGH confidence without screenshot evidence AND DOM/network data
- Never report FAIL with LOW confidence without a note explaining the uncertainty
- INCONCLUSIVE is not a failure — document what was needed to complete the check

### What Not To Include

- Do NOT include speculation about why a bug exists
- Do NOT include code fix suggestions (this is a QA tool, not a code review tool)
- Do NOT include commentary on code quality
- DO include exact observed values, exact expected values, exact evidence paths

---

## After Saving the Report

Say to the user:

```
✅ Verification report saved: reports/verification-report-<TICKET_ID>-<timestamp>.md

Summary:
- Visual: X pass / X fail / X inconclusive
- Business Logic: X pass / X fail / X inconclusive
- Overall: PASS / FAIL / PARTIAL

Proceeding to feedback capture...
```

Then immediately proceed to Stage 8 (Feedback Capture).
