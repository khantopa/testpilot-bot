# Stage 3: Test Data Setup Protocol

> Before starting any setup step, load `memory/selectors.md` for known page selectors and default actions.
> If a selector from memory works, use it. Only scan FE source if the selector fails or is missing.

This stage creates test users through the actual UI flow and brings them to the state required for testing.

**Never create users directly via API or database.** The registration flow itself is part of what we're testing. Use the UI.

---

## Pre-Setup: Campaign Cookie Injection (if applicable)

If the test plan identified a campaign (see Stage 1), inject campaign cookies BEFORE navigating to /join:

```
FOR EACH cookie in rules/campaigns/<campaign>.md:
  document.cookie = "<name>=<value>; domain=.<domain>; path=/"
```

Verify cookies are set before proceeding. If cookie injection fails:
- Note the failure in the report
- Ask the user: "Campaign cookies could not be set. Continue without them or abort?"

---

## 3.0 — Check for Standing Test Accounts

Before creating a new user, check if a standing account can be used:

1. Read memory/standing-accounts.json
2. Match required user type/status from test plan against available accounts
3. If match found:
   - Skip sections 3.1 through 3.15 entirely
   - Go directly to 3.17 (Return to Test Environment)
   - Log in with the standing account email + OTP 000000
   - Note in report: "Used standing account: <email>"
4. If no match: proceed with full registration (3.1 onward)

Standing accounts are for scenarios that need an EXISTING approved user.
New user scenarios MUST go through full registration.

---

## 3.1 — Navigate to Registration

1. Open test environment: `<TEST_ENV_URL>/join`
2. Verify the join page loaded:
   - Page title contains "Join" or "Sign up"
   - Gender selection visible
   - If page doesn't load within 10 seconds → **ENVIRONMENT FAILURE** (see 3.0 Environment Check)

---

## 3.2 — Gender & Account Type Selection

**Default values (override per test plan if needed):**
- Gender: **Man**
- Interest: **Women** (or as required by test scenario)
- Account Type: **Attractive** (or as required — check test plan)

Steps:
1. Click gender button matching the target gender
2. Click interest button (Women / Men / Both)
3. Click account type (Attractive / Successful)
4. Verify the "Next" or "Continue" button becomes enabled
5. Click Continue

**Error: Button doesn't enable**
```
IF Continue still disabled after selections:
  → Take screenshot
  → Check browser console for JS errors
  → Report: "SETUP FAILURE — Registration step 1: Continue button did not enable after gender/account type selection"
  → Abort this user setup attempt
```

---

## 3.3 — Age Verification

Generate a valid date of birth making the user exactly **25 years old**:
```
DOB = today's date - 25 years
Example: If today is 2026-03-15 → DOB = 2001-03-15
```

Steps:
1. Select birth month from dropdown/date picker
2. Select birth day
3. Select birth year
4. Verify no age validation error appears
5. Click Continue

**Error: Age validation fails**
```
IF "You must be at least X years old" error appears:
  → Recalculate DOB — ensure user is at least 25 (use 30 years as fallback)
  → Retry with adjusted DOB
IF error persists:
  → Screenshot + report as SETUP FAILURE
```

---

## 3.4 — Email Registration

Generate a unique test email:
```
Format: testpilot_<timestamp>@seeking-test.com
Example: testpilot_20260315143022@seeking-test.com
```

Steps:
1. Enter the generated email in the email field
2. Verify email format validation passes (no error shown)
3. Click "Send Code" or equivalent CTA
4. Wait for OTP input to appear (up to 5 seconds)

**Error: Email field validation fails**
```
IF "Please enter a valid email address" appears:
  → Verify email format — check for typos in template
  → Try alternative format: testpilot+<timestamp>@gmail.com
```

**Error: OTP input doesn't appear**
```
IF OTP input not visible after 10 seconds:
  → Check if rate limiting triggered ("Are you a robot?" page)
  → If rate limited: wait 5 minutes and retry with a different email
  → If page unresponsive: screenshot + ENVIRONMENT FAILURE
```

---

## 3.5 — OTP Entry

The test environment uses **mock OTP: 000000**

Steps:
1. Paste the full OTP "000000" into the OTP field as a single action
   - Use clipboard paste or setValue — do NOT type digit by digit
   - If the OTP field is split into 6 individual inputs, paste "000000"
     into the first input — the UI should auto-distribute across fields
2. Click Verify or Submit
3. Verify navigation to IPCF Step 1 (Nickname)

This applies to ALL OTP entry points: registration, login, email change.
Always paste as one action, never type individual digits.

**Error: OTP rejected**
```
IF "Please enter the correct code." error appears:
  → Verify Zeus config 'Email OTP Test Code' is enabled in this test environment
  → Ask the user: "OTP 000000 was rejected. Is the test OTP toggle enabled in Zeus for <TEST_ENV>?"
  → Do NOT retry more than 3 times — OTP throttle triggers at 4 failures
```

**Error: OTP expired**
```
IF OTP expiry message appears (OTP expires after 2 minutes):
  → Click "Resend code"
  → Re-enter 000000 immediately
```

---

## 3.6 — IPCF Step 1: Nickname

Generate a unique nickname:
```
Format: testpilot_<timestamp>
Example: testpilot_20260315143022
```

Steps:
1. Clear any pre-filled nickname
2. Enter the generated nickname
3. Wait for real-time uniqueness check (up to 3 seconds)
4. Verify no "That username is already taken" error
5. Verify Continue button enables
6. Click Continue

**Error: Nickname taken**
```
IF "Oops! That username is already taken":
  → Append random 4-digit suffix: testpilot_<timestamp>_<random>
  → Retry immediately
```

---

## 3.7 — IPCF Step 2: Location

Steps:
1. Click the location input
2. Type a city name: **"Singapore"** (or any valid city)
3. Wait for autocomplete dropdown
4. Select the first result
5. Verify location is accepted (no error, Continue enables)
6. Click Continue

**Error: No autocomplete results**
```
IF dropdown doesn't appear after typing "Singapore":
  → Try "New York" or "London"
  → If still no results: screenshot + report as SETUP FAILURE (location service may be down)
```

---

## 3.8 — IPCF Step 3: Physical Attributes

**Fast path**: Check if any valid option is already pre-selected.
IF a value is already selected AND the test plan does NOT require a specific value for this field:
  → Click Continue immediately — do NOT re-select or verify the value
  → This saves 2 interactions per field (select + verify → just Continue)
ONLY select a value if the field is empty/unselected.

Height:
1. Check if a height value is already selected → if yes, skip to Weight
2. Otherwise: open height dropdown, select any valid option (e.g., first item in list)
3. Verify selection registers

Weight:
1. Check if a weight value is already selected → if yes, skip to Continue
2. Otherwise: open weight dropdown, select any valid option (e.g., first item in list)
3. Verify selection registers

4. Verify Continue enables
5. Click Continue

**Error: Dropdown options don't load**
```
IF dropdown is empty or spinner persists > 5 seconds:
  → Refresh the page — IPCF should remember progress
  → If still empty: screenshot + SETUP FAILURE
```

---

## 3.9 — IPCF Step 4: Personal Details

**Fast path** (applies to all fields EXCEPT Relationship):
IF a valid option is already selected AND the test plan does NOT require a specific value:
  → Skip interaction for that field — do NOT re-select or verify

Fill fields as follows:
- **Ethnicity**: Fast path if pre-selected; otherwise select first available option
- **Education**: Fast path if pre-selected; otherwise select first available option
- **Relationship**: ALWAYS select **"Single"** — do NOT use fast path (specific value required)
- **Children**: Fast path if pre-selected; otherwise select first available option
- **Smoking**: Fast path if pre-selected; otherwise select first available option
- **Drinking**: Fast path if pre-selected; otherwise select first available option

Steps:
1. For each field: apply fast path OR click → select value → verify selection registered
2. After all fields filled: verify Continue enables
3. Click Continue

**Error: Relationship field not present**
```
IF relationship dropdown not found:
  → Check if this step is split across multiple sub-pages
  → Scroll down to check for hidden fields
  → Screenshot + note in report if field genuinely absent
```

---

## 3.10 — IPCF Step 5: Tags

**Fast path**: Check if at least 1 tag is already selected.
IF 1 or more tags already selected → Click Continue immediately (minimum is met).
ONLY click a tag if none are selected.

Steps:
1. Wait for tag options to load
2. Check if any tag is already selected → if yes, skip to step 4
3. Otherwise: click any **1** tag to select it (minimum required)
4. Verify Continue enables
5. Click Continue

**Error: Tags don't load**
```
IF tag area is blank or shows spinner > 5 seconds:
  → Refresh page
  → If tags still absent: screenshot + SETUP FAILURE
```

---

## 3.11 — IPCF Step 6: Looking For (Skippable)

**Fast path**: Always check if this step can be skipped first.

Steps:
1. Check if "Skip" link is visible → if yes, click Skip immediately (do NOT fill the field)
2. If not visible (required field):
   - Enter placeholder text (at least 50 chars):
     `"TestPilot verification account placeholder text for looking for section."`
   - Verify character count shows ≥ 50
   - Click Continue

---

## 3.12 — IPCF Step 7: Photo Upload

> **FIRST RUN:** You need to add a real test photo to `testdata/profile-photo-test.jpg` before
> running. Use any clean, non-offensive headshot photo that won't trigger content moderation.
> This file is gitignored for privacy — it must be added manually to each local clone.

Upload the test photo from `testdata/profile-photo-test.jpg`

Steps:
1. Locate the photo upload element (input[type="file"] or drag-drop zone)
2. Upload `testdata/profile-photo-test.jpg`
3. Wait for upload confirmation (up to 30 seconds for processing)
4. Verify at least 1 photo appears in the profile
5. Look for any error messages (rejected for content, format error, size error)
6. If photo editor appears (crop/rotate): accept defaults, confirm
7. Click Continue or Next

**Error: Upload rejected**
```
IF "Photo rejected" or content moderation error:
  → The test photo may have triggered moderation
  → Try a plain solid-color image if available in testdata/
  → Report: "Test photo upload triggered content moderation — consider updating testdata/"
```

**Error: Upload timeout**
```
IF no confirmation after 30 seconds:
  → Check network tab for failed requests
  → Retry upload once
  → If still fails: SETUP FAILURE — photo upload service may be down
```

---

## 3.13 — IPCF Step 8: Profile Content

Heading:
1. Enter: `"TestPilot Verification Account"` (30 chars — meets 4-50 char requirement)
2. Verify character counter updates
3. Verify no validation error

About Me:
1. Enter: `"This is a TestPilotBot automated verification account created for QA testing purposes. This account is safe to delete after verification is complete."` (≥ 50 chars)
2. Verify character counter shows ≥ 50
3. Verify no validation error

4. Click Continue

**Error: Heading validation fails**
```
IF red border or error on heading field:
  → Check character count — must be 4-50 chars
  → Current string "TestPilot Verification Account" is 30 chars — should be valid
  → If invalid: check if content was rejected (profanity filter?)
  → Try: "QA Test Profile Account"
```

**Error: About Me validation fails**
```
IF "You are missing your description." error or red border:
  → Count characters in the entered text
  → Must be ≥ 50 chars
  → Verify text was fully entered (no clipboard truncation)
```

---

## 3.14 — IPCF Step 9: Selfie Verification (URL Bypass)

Append `?qaSimulateLiveness=APPROVE` to the current URL. The selfie step
auto-approves without camera interaction.

Steps:
1. When selfie verification step appears, append `?qaSimulateLiveness=APPROVE`
   to the current page URL
2. Page reloads with liveness auto-approved
3. Click Continue on the success screen
4. Proceed to IPCF completion

Do NOT attempt any other bypass method.

---

## 3.15 — Confirm IPCF Completion

> IPCF completion is required for ALL test user setups — not just campaign tests.
> No test scenario is reachable without the user having completed onboarding.

After the last IPCF step, verify:
- Redirected to dashboard, PAS queue, or profile pending page
- URL is NOT stuck at an IPCF step
- No error messages visible

📌 CAMPAIGN USERS — check for CampaignInfoModal during IPCF:
After the "Tell us about yourself" step (or equivalent mid-IPCF step), a campaign notice modal
may appear for users enrolled via campaign cookie. This is a generic campaign checkpoint — not
specific to BUC. Verify:
- Modal appears with campaign-appropriate title and body (check rules/campaigns/<campaign>.md)
- testid is `campaign-notice-modal` (or campaign-specific testid if overridden)
- Dismiss modal and continue IPCF
- If modal does NOT appear for an enrolled user → enrollment may have failed (check cookie was set before registration)

Record:
```
Test User Created:
- Email: testpilot_<timestamp>@seeking-test.com
- Nickname: testpilot_<timestamp>
- Type: <Attractive / Successful>
- Gender: <Man / Woman>
- IPCF Status: Complete
- PAS Status: Pending approval
```

---

## 3.16 — Admin Approval

Determine admin panel URL and credentials:
```
1. Check .env for ADMIN_URL — use if set
2. If ADMIN_URL not set, fall back to: <TEST_ENV_URL>/admin (common convention)
3. If neither works, ask the user: "What is the admin panel URL for <TEST_ENV>?"

For admin email:
1. Check .env for ADMIN_EMAIL — use if set
2. If not set, ask the user: "What admin email should I use for <TEST_ENV>?"

For admin password:
→ NEVER store in .env — always ask the user or use a secure credential manager
→ "Can you provide the admin password for <ADMIN_EMAIL> on <TEST_ENV>?"
```

Navigate to admin panel URL determined above.

Admin Login:
1. Enter admin email (from .env or user-provided) and password (always ask)
2. Click Login / Submit
3. Verify admin dashboard loaded

**Error: Admin login fails**
```
IF "Invalid credentials" or redirect loop:
  → Ask user: "Admin login failed. Can you provide the correct admin credentials for <TEST_ENV>?"
  → Do NOT retry more than 2 times
```

Search for test user:
1. Navigate to user search / new profile moderation queue
2. Search by email: `testpilot_<timestamp>@seeking-test.com`
3. Locate the profile in results

Approve profile:
1. Open the user's profile in admin
2. Look for Approve button (individual) or checkbox + "Submit Decision for all Above" (bulk)
3. Click Approve
4. Verify profile status changes to "Approved"

⚠️ CAMPAIGN USERS (liveness required for gift/reward redemption):
If the test plan requires reward modals (e.g. gold_redemption_successful, boost_redemption_successful),
simulate liveness BEFORE force-approving:
  1. POST /v3/liveness/qa-callback?is_metadata=0
     Body: { "uid": "<user_uid>", "recommendation": "APPROVE" }  ← uppercase, not lowercase
  2. THEN force-approve via admin or GET /v3/users/<uid>/force-approve-profile

Reason: handleFreeGiftRedemption() (or equivalent) calls canRedeemFreeGift() on EACH event.
Approval before liveness means the liveness event fires when profile is not yet approved → skipped.
Liveness before approval means when approval fires, both conditions are met → gift issued correctly.

**Error: User not found in admin**
```
IF search returns no results:
  → Verify IPCF completion was successful (Step 3.15)
  → Check if at least 1 photo was uploaded (required for PAS queue)
  → Wait 30 seconds and search again (brief propagation delay is normal)
  → If still not found after 60 seconds: report as SETUP FAILURE
```

---

## 3.17 — Return to Test Environment as Approved User

1. Navigate back to test environment: `<TEST_ENV_URL>`
2. Log in as the test user (using email + OTP flow)
3. Enter OTP `000000`
4. Verify:
   - User lands on dashboard (not IPCF, not pending screen)
   - Profile shows "Approved" state
   - Feature under test is accessible

📌 CAMPAIGN USERS — triggering the first campaign modal after approval:
Do NOT navigate separately to /member to trigger the modal.
Instead: click **"View members"** on the IPCF last page after force-approve.
The modal is dispatched on that navigation and appears naturally.
A hard page refresh or separate navigation to /member may miss it.

**Error: User still sees "Pending" screen after approval**
```
IF approval screen still showing:
  → Hard refresh the page (Cmd+Shift+R or Ctrl+Shift+R)
  → If still pending: check admin — was approval saved correctly?
  → Re-do approval step if needed
```

---

## 3.18 — Record Test User Inventory

After each successful setup, record to report:

```markdown
## Test Users Created
| Email | Nickname | Type | Approved | Purpose |
|-------|----------|------|----------|---------|
| testpilot_<ts>@seeking-test.com | testpilot_<ts> | Attractive | Yes | AC #1, #2, #3 |
```

This table appears in the final verification report for cleanup tracking.

---

## Setup Failure Protocol

If any step fails and cannot be recovered:

1. Record exactly which step failed and what was observed
2. Take a screenshot
3. Add `SETUP FAILURE` entry to the report
4. Ask user: "Setup failed at step <N>. Options: (A) Retry from the beginning, (B) Skip this user type and note as untested, (C) Abort verification"
5. Do NOT attempt to verify features that require this user type — mark those checks as `INCONCLUSIVE — Setup failure`
